using Random
using Lasso
using NormReg
using LaTeXStrings
using CSV
using DataFrames
using ProjectRoot
using Base.Threads

lambda_sim = function (alpha, dataset, delta, lambda_max, n_lambda)
  Random.seed!(1234)

  x, y = datagrabber(dataset)

  x_train, y_train, x_test, y_test = split_data(x, y, 0.5)

  n, p = size(x_train)

  x_train_std, centers, scales = normalize_features2(x_train, delta, false)

  lambda_min_ratio = p > n ? 1e-2 : 1e-4

  lambda = collect(logspace(lambda_max, lambda_max * lambda_min_ratio, n_lambda))

  # model = elasticnet(x_train_std, y_train, λ = lambda, α = alpha, tol = 1e-3)
  # lambda = model.λ
  # b0 = model.β0
  # b = model.β

  model = fit(
    LassoPath,
    x_train_std,
    y_train,
    λ = lambda,
    standardize = false,
    stopearly = false,
    α = alpha,
  )

  b0 = model.b0
  b = model.coefs

  intercept, coefs = unstandardize_coefficients(b0, b, centers, scales)

  err = zeros(n_lambda)
  support_size = zeros(n_lambda)

  for i in 1:n_lambda
    y_pred = intercept[i] .+ x_test * coefs[:, i]
    err[i] = get_error(y_pred, y_test, "nmse")

    support_size[i] = sum(coefs[:, i] .!= 0)
  end

  lambda_out = lambda ./ lambda_max

  return err, lambda_out, support_size
end

results = []
grid_size = 11
datasets = ["covtype.binary"]
res =
  DataFrame(alpha = [], dataset = [], delta = [], lambda = [], err = [], support_size = [])
deltas = collect(range(0, 1, length = grid_size));
alpha = 1

for dataset in datasets
  lambda_max = 0

  println("Grabbing data for dataset: ", dataset)

  x, y = datagrabber(dataset)

  for delta in deltas
    Random.seed!(1234)

    x_train, y_train, x_test, y_test = split_data(x, y, 0.5)
    x_train_std, centers, scales = normalize_features2(x_train, delta, false)

    n = size(x_train, 1)
    tmp = maximum(abs.(x_train_std' * (y_train .- mean(y_train)))) / n

    lambda_max = max(lambda_max, tmp)
  end

  all_results = Vector{DataFrame}(undef, length(deltas))

  Threads.@threads for i in eachindex(deltas)
    delta = deltas[i]

    println(
      "\tThread $(Threads.threadid()) processing - Alpha: ",
      alpha,
      " | Dataset: ",
      dataset,
      " | Delta: ",
      delta,
    )

    err, lambda, support_size = lambda_sim(alpha, dataset, delta, lambda_max, grid_size)

    all_results[i] = DataFrame(
      alpha = alpha,
      dataset = dataset,
      delta = delta,
      lambda = lambda,
      err = err,
      support_size = support_size,
    )
  end

  # Combine all results
  for df in all_results
    res = vcat(res, df)
  end

  outfile = @projectroot("results", "hyperopt-big/$dataset.csv")

  open(outfile, "w") do f
    CSV.write(f, res)
  end
end
