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

function interaction_simulation(β; delta = 1, q = 0.75, mu = 2, center = "both")
  n = 1000

  snr = 1
  sigma = 2

  p = length(β)

  x = zeros(n, p)

  x[:, 1] .= generate_pseudobernoulli(n, q = q)
  x[:, 2] .= generate_pseudonormal(n; μ = mu, σ = sigma)

  if center in ["both", "binary"]
    x[:, 1] .-= mean(x[:, 1])
  end

  if center in ["both", "normal"]
    x[:, 2] .-= mean(x[:, 2])
  end

  σ = √(var(x * β) / snr)
  y = x * β .+ rand(Normal(0, σ), n)

  scales = ones(1, 3)
  centers = mean(x, dims = 1)

  scale_mod = 0.5 / (0.25^delta)
  scales[1] = scale_mod * var(x[:, 1], corrected = false)^delta
  scales[2] = std(x[:, 2], corrected = false)

  scales[scales .== 0] .= 1

  if center == "both"
    scales[3] = sigma * (q - q^2)
  elseif center == "normal"
    scales[3] = q * sigma
  end

  x_std = (Matrix(x) .- centers) ./ scales

  lambda = 0.25 * n

  res = elasticnet(x_std, y, λ = [lambda], α = 1)

  _, coefs_unstandardized = unstandardize_coefficients(res.β0, res.β, centers, scales)

  return coefs_unstandardized, β
end

param_dict = Dict(
  "it" => collect(1:50),
  "beta" => [[1, 1, 1]],
  "center" => ["both", "normal"],
  "delta" => [1],
  "q" => collect(range(0.01, 0.99, 20)),
  "mu" => [0, 2],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, beta, center, delta, q, mu = d

  Random.seed!(it)

  β_est, β_true = interaction_simulation(beta, center = center, delta = delta, q = q, mu = mu)

  d_exp = copy(d)
  d_exp["betas"] = dropdims(β_est, dims = 2)

  push!(results, d_exp)
end

outfile = @projectroot("data", "interactions-centering.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

# include(@projectroot("scripts", "plots", "interactions-classbalance.jl"))
