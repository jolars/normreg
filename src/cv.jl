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
  elseif target == "accuracy"
    class_pred = y_pred .> 0.5
    return mean(class_pred .== y_true)
  else
    error("Target not supported")
  end
end

function holdout_validation(
  x::Array{Float64,2},
  y::Array{Float64,1},
  dist = Normal(),
  delta::Real = 0,
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
  x_train_norm, _, _ = normalize_features(x_train, delta)
  res = fit(LassoPath, x_train_norm, y_train, dist, standardize = false)
  lambda = res.λ
  n_lambda = length(lambda)

  x_val_norm, _, _ = normalize_features(x_val, delta)

  pred_array = predict(res, x_val_norm; select = AllSeg())

  err = zeros(n_lambda)

  for j in 1:n_lambda
    err[j] = get_error(pred_array[:, j], y_val)
  end

  best_lambda = lambda[argmin(err)]

  x_test_norm, centers_test, scales_test = normalize_features(x_test, delta)

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
  x::AbstractMatrix,
  y::AbstractVector,
  dist = Normal(),
  normalization::String = "mean_std",
  alpha::Real = 1.0,
  delta = [0.0, 0.5, 1.0],
  k::Int = 10,
  target::String = "nmse";
  seed::Int = nothing,
  repeats::Int = 1,
  binarize::Bool = false,
)
  n, p = size(x)

  n_delta = if normalization == "ours"
    length(delta)
  else
    1
  end

  delta = if normalization == "ours"
    delta
  else
    [NaN]
  end

  # Set random seed if provided
  if !isnothing(seed)
    Random.seed!(seed)
  end

  x_train, y_train = x, y

  lambda_max = []

  for d in delta
    x_train_norm, _, _ =
      normalize_features_unadjusted(x_train, normalization, d, binarize = binarize)
    n = size(x_train, 1)
    tmp = maximum(abs.(x_train_norm' * (y_train .- mean(y_train)))) / n

    # lambda_max = max(lambda_max, tmp)
    push!(lambda_max, tmp)
  end

  lambda_min_ratio = if n > p
    1e-4
  else
    1e-2
  end

  n_lambda = 100

  # Initialize error array with an additional dimension for repeats
  err = zeros(n_lambda, k, n_delta, repeats)

  # Repeated k-fold cross-validation
  for r in 1:repeats
    # Generate a new random permutation for each repeat
    perm_r = randperm(size(x_train, 1))
    x_train = x_train[perm_r, :]
    y_train = y_train[perm_r]

    folds = Kfold(size(x_train, 1), k)

    for (i, fold) in enumerate(folds)
      x_train_fold = x_train[fold, :]
      y_train_fold = y_train[fold]
      x_val = x_train[setdiff(1:size(x_train, 1), fold), :]
      y_val = y_train[setdiff(1:size(y_train, 1), fold)]

      for d in 1:n_delta
        lambda =
          collect(logspace(lambda_max[d], lambda_max[d] * lambda_min_ratio, n_lambda))

        x_train_fold_norm, _, _ =
          normalize_features_unadjusted(x_train_fold, normalization, delta[d])

        res = fit(
          LassoPath,
          x_train_fold_norm,
          y_train_fold,
          dist,
          standardize = false,
          λ = lambda,
          stopearly = false,
          α = alpha,
          maxncoef = p,
        )

        x_val_norm, _, _ = normalize_features_unadjusted(x_val, normalization, delta[d])

        pred_array = predict(res, x_val_norm; select = AllSeg())

        for j in 1:n_lambda
          err[j, i, d, r] = get_error(pred_array[:, j], y_val, target)
        end
      end
    end
  end

  # Average error across folds and repeats
  avg_error = dropdims(mean(err, dims = (2, 4)), dims = (2, 4))

  std_error = dropdims(std(err, dims = (2, 4)), dims = (2, 4))

  best_cv_error = minimum(avg_error)
  best_ind = argmin(avg_error)

  best_delta = delta[best_ind[2]]

  lambda = collect(
    logspace(lambda_max[best_ind[2]], lambda_max[best_ind[2]] * lambda_min_ratio, n_lambda),
  )
  best_lambda = lambda[best_ind[1]]

  ci_low = best_cv_error - 1.96 * std_error[best_ind] / sqrt(k * repeats)
  ci_high = best_cv_error + 1.96 * std_error[best_ind] / sqrt(k * repeats)

  return best_cv_error, ci_low, ci_high, best_delta, best_lambda, avg_error
end
