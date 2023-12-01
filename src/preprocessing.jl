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

"""
    normalize(matrix::AbstractMatrix, method::String)

Normalizes the given matrix using the specified method.

# Arguments

- `matrix::AbstractMatrix`: The matrix to be normalized.
- `method::String`: The method to be used for standardization. Valid options are "mean_std" and "max_abs".

# Returns

- `normalize::Matrix`: The normalized matrix.
```
"""
function normalize(x::AbstractMatrix, method::String = "mean_std")
  p = size(x, 2)
  centers = zeros(1, p)
  scales = ones(1, p)

  if method == "mean_std"
    centers = mean(x, dims = 1)
    scales = std(x, dims = 1)
  elseif method == "l1"
    centers = mean(x, dims = 1)
    scales = Matrix([norm(x[:, j]) for j in 1:p]')
  elseif method == "mean_var"
    centers = mean(x, dims = 1)
    binary = find_binary_features(x)

    for j in 1:p
      if binary[j]
        scales[j] = var(x[:, j])
      else
        scales[j] = std(x[:, j])
      end
    end
  elseif method == "continuous_mean_std"
    # Center all features
    centers = mean(x, dims = 1)

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
    centers = minimum(x, dims = 1)
    scales = maximum(abs.(x), dims = 1) - centers
  elseif method == "none"
    # No scaling or centering
  else
    error(
      "Invalid method. Choose either 'mean_std', 'continuous_mean_std', 'max_abs', or 'min_max'.",
    )
  end

  scales[scales.==0] .= 1

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
