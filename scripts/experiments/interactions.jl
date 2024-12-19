using DataFrames
using DrWatson
using Lasso
using LinearAlgebra
using JSON
using NormReg
using Distributions
using ProjectRoot
using Random
using Statistics

function interaction_simulation(β, norm_strategy, delta, q, mu, center_before)
  n = 1000

  snr = 1
  sigma = 0.5

  p = length(β)

  x = zeros(n, p)

  x[:, 1] .= generate_pseudobernoulli(n, q = q)
  nz_ind = findall(x[:, 1] .== 0)
  x[:, 2] .= generate_pseudonormal(n; μ = mu, σ = sigma)

  if center_before
    x[:, 1] .-= mean(x[:, 1])
    x[:, 2] .-= mean(x[:, 2])
  end

  x[:, 3] .= x[:, 1] .* x[:, 2]

  σ = √(var(x * β) / snr)
  y = x * β .+ rand(Normal(0, σ), n)

  # cor(hcat(x, y))

  scales = ones(1, 3)
  centers = mean(x, dims = 1)

  q0 = 0.5
  κ = 2

  scale_mod = κ * (q0 - q0^2)^(1 - delta)

  scales[1] = scale_mod * var(x[:, 1], corrected = false)^delta
  scales[2] = std(x[:, 2], corrected = false)

  if norm_strategy == 1
    scales[3] = std(x[:, 3], corrected = false)
  elseif norm_strategy == 2
    scales[3] = (q - q^2) * scales[2]
  elseif norm_strategy == 3
    scales[3] = std(x[nz_ind, 3], corrected = false)
  end

  scales[scales .== 0] .= 1

  x_std = (Matrix(x) .- centers) ./ scales

  lambda = 0.25 * n

  # cor(hcat(x_std, y))

  res = elasticnet(x_std, y, λ = [lambda], α = 1)

  _, coefs_unstandardized = unstandardize_coefficients(res.β0, res.β, centers, scales)

  return coefs_unstandardized, β
end

param_dict = Dict(
  "it" => collect(1:50),
  "beta" => [[1, 1, 0], [1, 1, 1], [1, 0, 1], [0, 1, 1], [0, 0, 1]],
  "norm_strategy" => [1, 2, 3],
  "delta" => [1],
  "q" => collect(range(0.01, 0.99, 20)),
  "mu" => [5],
  "center_before" => [true],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, beta, norm_strategy, delta, q, mu, center_before = d

  Random.seed!(it)

  β_est, β_true = interaction_simulation(beta, norm_strategy, delta, q, mu, center_before)
  β_est

  d_exp = copy(d)
  d_exp["betas"] = dropdims(β_est, dims = 2)

  push!(results, d_exp)
end

outfile = @projectroot("data", "interactions.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

include(@projectroot("scripts", "plots", "interactions-classbalance.jl"))
