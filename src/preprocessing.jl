using LinearAlgebra
using Statistics

function find_binary_features(x)
  p = size(x, 2)
  binary = zeros(Bool, p)

  for j in 1:p
    binary[j] = length(unique(x[:, j])) == 2
  end

  return binary
end

function normalize_features2(x::AbstractMatrix, delta::Real = 0, center::Bool = false)
  p = size(x, 2)
  scales = ones(1, p)

  if center
    centers = mean(x, dims = 1)
  else
    centers = zeros(1, p)
  end

  binary = find_binary_features(x)

  for j in 1:p
    if binary[j]
      q = mean(x[:, j])
      scales[j] = (q - q^2)^delta
    else
      scales[j] = std(x[:, j])
    end
  end

  scales[scales .== 0] .= 1

  if center
    x_normalized = (Matrix(x) .- centers) ./ scales
  else
    x_normalized = Matrix(x) ./ scales
  end

  return x_normalized, centers, scales
end

function normalize_features(
  x::AbstractMatrix,
  method::String = "mean_std",
  center::Bool = true,
)
  p = size(x, 2)
  scales = ones(1, p)

  if center
    centers = mean(x, dims = 1)
  else
    centers = zeros(1, p)
  end

  # TODO: Add l1 and l2 norm methods too.
  if method == "mean_std"
    scales = std(x, dims = 1)
  elseif method == "mean_var"
    scales = var(x, dims = 1)
  elseif method == "mean_stdvar"
    # Center all features. 
    # Scale binary features by their variance and
    # continuous features by their standard deviation.
    binary = find_binary_features(x)

    for j in 1:p
      if binary[j]
        scales[j] = 2 * var(x[:, j])
      else
        scales[j] = std(x[:, j])
      end
    end
  elseif method == "mean_2std"
    # Only scale continuous features
    binary = find_binary_features(x)

    for j in 1:p
      if !binary[j]
        scales[j] = 2 * std(x[:, j])
      end
    end
  elseif method == "max_abs"
    scales = maximum(abs.(x), dims = 1)
  elseif method == "min_max"
    scales = maximum(abs.(x), dims = 1) - centers
  elseif method == "none"
    # Do nothing
  else
    error("Invalid normalization method. See source for options")
  end

  scales[scales .== 0] .= 1

  x_normalized = (Matrix(x) .- centers) ./ scales

  return x_normalized, centers, scales
end

function unstandardize_coefficients(
  beta0::AbstractVector,
  beta::AbstractMatrix,
  centers::AbstractMatrix,
  scales::AbstractMatrix,
)
  beta_out = deepcopy(beta)
  beta0_out = deepcopy(beta0)

  for m in axes(beta, 2)
    x_bar_beta_sum = 0.0
    for j in axes(beta, 1)
      beta_out[j, m] = beta[j, m] / scales[j]
      x_bar_beta_sum += beta_out[j, m] * centers[j]
    end
    beta0_out[m] -= x_bar_beta_sum
  end

  return beta0_out, beta_out
end
