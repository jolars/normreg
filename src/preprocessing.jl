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
      # q = mean(x[:, j])
      # scales[j] = (q - q^2)^delta
      scales[j] = var(x[:, j])^delta
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

function normalize_features_unadjusted(x::AbstractMatrix, method::String = "std")
  p = size(x, 2)
  scales = ones(1, p)

  if method == "std"
    centers = mean(x, dims = 1)
    scales = std(x, dims = 1, corrected = false)
  elseif method == "max_abs"
    centers = zeros(1, p)
    scales = maximum(abs.(x), dims = 1)
  elseif method == "min_max"
    centers = minimum(abs.(x), dims = 1)
    scales = maximum(abs.(x), dims = 1) .- centers
  elseif method == "none"
    centers = zeros(1, p)
    scales = ones(1, p)
  else
    error("Invalid normalization method. See source for options")
  end

  scales[scales .== 0] .= 1

  x_normalized = (Matrix(x) .- centers) ./ scales

  return x_normalized, centers, scales
end

function normalize_features(
  x::AbstractMatrix,
  delta::Real = 0;
  center::Bool = true,
  intersections::Vector{Int} = Int[],
)
  p = size(x, 2)
  scales = ones(1, p)

  binary = find_binary_features(x)

  if center
    centers = mean(x, dims = 1)
  else
    centers = zeros(1, p)
  end

  # always scale continuos features by standard deviation

  for j in 1:p
    if binary[j]
      mod = 0.5 / (0.25^delta)
      # mod = 2^delta
      scales[j] = mod * var(x[:, j], corrected = false)^delta
    else
      # conditionally scale interaction effects
      if j in intersections
        mod = 0.5 / (0.25^delta)
        nz = findall(x[:, j] .!= 0)
        scales[j] =
          std(x[nz, j], corrected = false) * mod * var(x[:, j], corrected = false)^delta
      else
        mod = 0.5 / (0.25^delta)
        scales[j] = std(x[:, j], corrected = false)
      end
    end
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
