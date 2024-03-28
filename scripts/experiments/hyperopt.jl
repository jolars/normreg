using LIBSVMdata
using Random
using Lasso
using NormReg
using LaTeXStrings
using CSV
using DataFrames
using ProjectRoot

datagrabber = function (dataset)
  if dataset in ["rhee2006"]
    xy = CSV.read(@projectroot("data", "$(dataset).csv"), DataFrame)
    y = xy[:, 1]
    x = Matrix(xy[:, 2:end])
  else
    x, y = load_dataset(dataset, dense = false, replace = false, verbose = false)
  end

  return x, y
end

lambda_sim = function (alpha, dataset, delta, lambda_max, n_lambda)
  Random.seed!(1234)

  x, y = datagrabber(dataset)

  x_train, y_train, x_test, y_test = split_data(x, y, 0.5)

  x_train_std, centers, scales = normalize_features2(x_train, delta, false)

  lambda = collect(logspace(lambda_max, lambda_max * 1e-5, n_lambda))

  model = fit(
    LassoPath,
    x_train_std,
    y_train,
    λ = lambda,
    standardize = false,
    stopearly = false,
    α = alpha,
  )

  intercept, coefs = unstandardize_coefficients(model.b0, model.coefs, centers, scales)

  err = zeros(n_lambda)
  support_size = zeros(n_lambda)

  for i in 1:n_lambda
    y_pred = intercept[i] .+ x_test * coefs[:, i]
    err[i] = get_error(y_pred, y_test, "nmse")

    support_size[i] = sum(coefs[:, i] .!= 0)
  end

  return err, lambda, support_size
end

max_delta = maximum(delta)

param_expanded = dict_list(param_dict);

results = []

grid_size = 100

datasets = ["a1a", "w1a", "rhee2006"]

res =
  DataFrame(alpha = [], dataset = [], delta = [], lambda = [], err = [], support_size = [])

deltas = collect(range(0, 1, length = grid_size));

alphas = [0, 1]

for alpha in alphas
  for dataset in datasets
    lambda_max = 0

    for delta in deltas
      Random.seed!(1234)

      x, y = datagrabber(dataset)

      x_train, y_train, x_test, y_test = split_data(x, y, 0.5)

      x_train_std, centers, scales = normalize_features2(x_train, delta, false)

      n = size(x_train, 1)
      tmp = maximum(abs.(x_train_std' * (y_train .- mean(y_train)))) / n

      lambda_max = max(lambda_max, tmp)
    end

    for delta in deltas
      err, lambda, support_size = lambda_sim(alpha, dataset, delta, lambda_max, grid_size)
      df = DataFrame(
        alpha = alpha,
        dataset = dataset,
        delta = delta,
        lambda = lambda,
        err = err,
        support_size = support_size,
      )
      res = vcat(res, df)
    end
  end
end

outfile = @projectroot("data", "hyperopt.csv");

open(outfile, "w") do f
  CSV.write(f, res)
end
