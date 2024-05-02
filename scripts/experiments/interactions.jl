using DataFrames
using DrWatson
using Lasso
using LinearAlgebra
using JSON
using NormReg
using Distributions
using ProjectRoot
using Random

function interaction_simulation(β, norm_strategy, delta, q)
  n = 1000
  mu = 0

  snr = 1

  p = length(β)

  x = zeros(n, p)

  x[:, 1] .= generate_pseudobernoulli(n, q = q)
  x[:, 2] .= generate_pseudonormal(n; μ = mu, σ = 0.5)
  x[:, 3] .= x[:, 1] .* x[:, 2]

  σ = √(var(x * β) / snr)
  y = x * β .+ rand(Normal(0, σ), n)

  if norm_strategy == 1
    x_std, centers, scales = normalize_features(x, delta, center = true)
  elseif norm_strategy == 2
    intersections = [3]
    x_std, centers, scales =
      normalize_features(x, delta, center = true, intersections = intersections)
  end

  lambda = 0.25

  res =
    fit(LassoPath, x_std, y, Normal(), standardize = false, λ = [lambda], intercept = true)

  _, coefs_unstandardized = unstandardize_coefficients(res.b0, res.coefs, centers, scales)

  return coefs_unstandardized, β
end

param_dict = Dict(
  "it" => collect(1:50),
  "beta" => [[1, 1, 0], [1, 1, 1], [1, 0, 1], [0, 1, 1], [0, 0, 1]],
  "norm_strategy" => [1, 2],
  "delta" => [0, 0.5, 1],
  "q" => [0.5, 0.7, 0.9],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, beta, norm_strategy, delta, q = d

  Random.seed!(it)

  β_est, β_true = interaction_simulation(beta, norm_strategy, delta, q)
  β_est

  d_exp = copy(d)
  d_exp["betas"] = dropdims(β_est, dims = 2)

  push!(results, d_exp)
end

outfile = @projectroot("data", "interactions.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

include(@projectroot("scripts", "plots", "interactions.jl"))
