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

function normalize_features_unadjusted(
  x::AbstractMatrix,
  method::String = "std",
  delta::Real = 0;
  binarize = false,
  adjust = false,
)
  p = size(x, 2)
  scales = ones(1, p)

  if binarize
    binary = find_binary_features(x)

    for j in 1:p
      if !binary[j]
        x[:, j] .= Int.(x[:, j] .> mean(x[:, j]))
      end
    end
  end

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
  elseif method == "l1"
    centers = mean(x, dims = 1)
    scales = sum(abs.(Matrix(x) .- centers), dims = 1)
  elseif method == "ours"
    return normalize_features(x, delta, adjust = adjust)
  else
    error("Invalid normalization method. See source for options")
  end

  scales[scales .== 0] .= 1

  x_normalized = (Matrix(x) .- centers) ./ scales

  return x_normalized, centers, scales
end

function scaling_factors(
  x::AbstractMatrix,
  delta::Real = 0;
  intersections::Vector{Int} = Int[],
  adjust = true,
)
  p = size(x, 2)
  scales = ones(1, p)

  binary = find_binary_features(x)

  # always scale continuos features by standard deviation
  for j in 1:p
    if binary[j]
      mod = adjust ? 0.5 / (0.25^delta) : 1
      scales[j] = mod * var(x[:, j], corrected = false)^delta
    else
      # conditionally scale interaction effects
      if j in intersections
        nz = findall(x[:, j] .!= 0)
        scales[j] = std(x[nz, j], corrected = false)
      else
        scales[j] = std(x[:, j], corrected = false)
      end
    end
  end

  scales[scales .== 0] .= 1

  return scales
end

function normalize_features(
  x::AbstractMatrix,
  delta::Real = 0;
  center::Bool = true,
  adjust = true,
)
  _, p = size(x)
  scales = ones(1, p)

  if center
    centers = mean(x, dims = 1)
  else
    centers = zeros(1, p)
  end

  scales = scaling_factors(x, delta, adjust = adjust)

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
