using DataFrames
using DrWatson
using Lasso
using LinearAlgebra
using JSON
using NormReg
using Distributions
using ProjectRoot
using Random

function interaction_simulation(beta, norm_strategy, delta, q, center)
  n = 1000
  mu = 0

  center = center == "yes"

  x, y, β_true, centers, scales =
    generate_interaction_data(beta, norm_strategy, delta, q, mu, center; n = n, snr = 1)

  lambda = 0.2

  res = fit(LassoPath, x, y, Normal(), standardize = false, λ = [lambda], intercept = true)

  _, coefs_unstandardized = unstandardize_coefficients(res.b0, res.coefs, centers, scales)

  return 0, coefs_unstandardized, β_true
end

param_dict = Dict(
  "it" => collect(1:50),
  "beta" => [[1, 1, 1], [1, 0, 1], [0, 1, 1], [0, 0, 1]],
  "norm_strategy" => [1, 2, 3],
  "delta" => [0, 0.5, 1],
  "q" => [0.5, 0.7, 0.9],
  "center" => ["yes", "no"],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, beta, norm_strategy, delta, q, center = d

  Random.seed!(it)

  err, β_est, β_true = interaction_simulation(beta, norm_strategy, delta, q, center)
  β_est

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas"] = dropdims(β_est, dims = 2)

  push!(results, d_exp)
end

outfile = @projectroot("data", "interactions.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

include(@projectroot("scripts", "plots", "interactions.jl"))
