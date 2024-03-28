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

lambda_sim = function (dataset, delta, lambda_max, n_lambda)
  Random.seed!(1234)

  x, y = datagrabber(dataset)

  x_train, y_train, x_test, y_test = split_data(x, y, 0.5)

  x_train_std, centers, scales = normalize_features2(x_train, delta, false)

  lambda = collect(logspace(lambda_max, lambda_max * 1e-6, n_lambda))

  model = fit(
    LassoPath,
    x_train_std,
    y_train,
    λ = lambda,
    standardize = false,
    stopearly = false,
  )

  intercept, coefs = unstandardize_coefficients(model.b0, model.coefs, centers, scales)

  err = zeros(n_lambda)

  for i in 1:n_lambda
    y_pred = intercept[i] .+ x_test * coefs[:, i]
    err[i] = get_error(y_pred, y_test, "nmse")
  end

  return err, lambda
end

max_delta = maximum(delta)

param_expanded = dict_list(param_dict);

results = []

grid_size = 100

datasets = ["a1a", "w1a", "rhee2006"]

res = DataFrame(dataset = [], delta = [], lambda = [], err = [])

deltas = collect(range(0, 1, length = grid_size));

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
    err, lambda = lambda_sim(dataset, delta, lambda_max, grid_size)
    df = DataFrame(dataset = dataset, delta = delta, lambda = lambda, err = err)
    res = vcat(res, df)
  end
end

outfile = @projectroot("data", "hyperopt.csv");

open(outfile, "w") do f
  CSV.write(f, res)
end
