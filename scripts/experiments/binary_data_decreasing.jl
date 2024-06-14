using DataFrames
using DrWatson
using LinearAlgebra
using JSON
using NormReg
using Distributions
using ProjectRoot
using Random

function binary_decreasingq_simulation(n, p, s, delta, q_type, snr, rho)
  x, y, β_true, σ = generate_binary_data(n, p, s, q_type, "constant", snr, rho)

  x, centers, scales = normalize_features2(x, delta, true)

  σ = √(var(x * β_true) / snr)

  λ = 2 * σ * sqrt(2 * log(p))

  res = elasticnet(x, y, λ = [λ])

  _, coefs_unstandardized = unstandardize_coefficients(res.β0, res.β, centers, scales)

  return 0, coefs_unstandardized, β_true
end

param_dict = Dict(
  "it" => collect(1:50),
  "n" => 500,
  "p" => [1000],
  "s" => [20],
  "snr" => [2],
  "delta" => [0, 0.5, 1],
  "q_type" => ["decreasing"],
  "rho" => [0, 0.5, 0.9],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, n, p, s, snr, delta, q_type, rho = d

  Random.seed!(it)

  err, β_est, β_true = binary_decreasingq_simulation(n, p, s, delta, q_type, snr, rho)

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas"] = β_est

  push!(results, d_exp)
end

outfile = @projectroot("data", "binary_data_decreasing.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end
