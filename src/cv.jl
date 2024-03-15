using Random
using Lasso
using MLBase
using Distributions

function split_data(x, y, train_size = 0.75)
  n = size(x, 1)
  idx = randperm(n)
  n_train = round(Int, train_size * n)

  train_idx = idx[1:n_train]
  test_idx = idx[(n_train + 1):end]

  x_train = x[train_idx, :]
  y_train = y[train_idx]

  x_test = x[test_idx, :]
  y_test = y[test_idx]

  return x_train, y_train, x_test, y_test
end

function get_error(y_pred, y_true, target = "mse")
  if target == "mse"
    return mean((y_pred .- y_true) .^ 2)
  elseif target == "nmse"
    return mean((y_pred .- y_true) .^ 2) / var(y_true)
  elseif target == "mae"
    return mean(abs.(y_pred .- y_true))
  else
    error("Target not supported")
  end
end

function holdout_validation(
  x::Array{Float64,2},
  y::Array{Float64,1},
  dist = Normal(),
  normalization = "mean_std",
  target = "nmse",
  train_size = 2 / 3,
  validation_size = 0.5,
)
  n, p = size(x)

  # First shuffle the data set.
  perm = randperm(n)
  x = x[perm, :]
  y = y[perm]

  x_tmp, y_tmp, x_test, y_test = split_data(x, y, train_size)
  x_val, y_val, x_train, y_train = split_data(x_tmp, y_tmp, validation_size)

  # fit once to obtain lambas for path
  x_train_norm, _, _ = normalize_features(x_train, normalization)
  res = fit(LassoPath, x_train_norm, y_train, dist, standardize = false)
  lambda = res.λ
  n_lambda = length(lambda)

  x_val_norm, _, _ = normalize_features(x_val, normalization)

  pred_array = predict(res, x_val_norm; select = AllSeg())

  err = zeros(n_lambda)

  for j in 1:n_lambda
    err[j] = get_error(pred_array[:, j], y_val)
  end

  # err = mapslices(yhat -> get_error(yhat, y_val), pred_array; dims = 2)

  best_lambda = lambda[argmin(err)]

  x_test_norm, centers_test, scales_test = normalize_features(x_test, normalization)

  res_test = fit(
    LassoPath,
    x_test_norm,
    y_test,
    dist,
    standardize = false,
    λ = [best_lambda],
    maxncoef = p,
  )

  beta0_unstandardized, coefs_unstandardized =
    unstandardize_coefficients(res_test.b0, res_test.coefs, centers_test, scales_test)

  y_pred = beta0_unstandardized .+ x_test * coefs_unstandardized

  test_error = get_error(y_pred, y_test, target)

  return test_error, beta0_unstandardized, coefs_unstandardized
end

function cross_validate(
  x::Array{Float64,2},
  y::Array{Float64,1},
  dist = Normal(),
  normalization = "mean_std",
  k = 10,
  train_size = 0.75,
  target = "mse",
)
  n, p = size(x)

  # First shuffle the data set.
  perm = randperm(n)
  x = x[perm, :]
  y = y[perm]

  # Next, split the data set into a training an
  x_train, y_train, x_test, y_test = split_data(x, y, train_size)

  # fit once to obtain lambas for path
  x_train_norm, _, _ = normalize_features(x_train, normalization)
  res_full = fit(LassoPath, x_train_norm, y_train, dist, standardize = false)
  lambda = res_full.λ
  n_lambda = length(lambda)

  err = zeros(n_lambda, k)
  folds = Kfold(n, k)

  for (i, fold) in enumerate(folds)
    x_train_fold = x[fold, :]
    y_train_fold = y[fold]
    x_val = x[setdiff(1:n, fold), :]
    y_val = y[setdiff(1:n, fold)]

    x_train_fold_norm, _, _ = normalize_features(x_train_fold, normalization)

    res = fit(
      LassoPath,
      x_train_fold_norm,
      y_train_fold,
      dist,
      standardize = false,
      λ = lambda,
      stopearly = false,
      maxncoef = p,
    )

    x_val_norm, _, _ = normalize_features(x_val, normalization)

    pred_array = predict(res, x_val_norm; select = AllSeg())

    for j in 1:n_lambda
      err[j, i] = get_error(pred_array[:, j], y_val)
    end
  end

  avg_error = dropdims(mean(err, dims = 2), dims = 2)
  best_ind = argmin(avg_error)
  best_lambda = lambda[best_ind]

  x_test_norm, centers_test, scales_test = normalize_features(x_test, normalization)

  res_test = fit(
    LassoPath,
    x_test_norm,
    y_test,
    dist,
    standardize = false,
    λ = [best_lambda],
    maxncoef = p,
  )

  beta0_unstandardized, coefs_unstandardized =
    unstandardize_coefficients(res_test.b0, res_test.coefs, centers_test, scales_test)

  y_pred = beta0_unstandardized .+ x_test * coefs_unstandardized

  test_error = get_error(y_pred, y_test, target)

  return test_error, beta0_unstandardized, coefs_unstandardized
end
