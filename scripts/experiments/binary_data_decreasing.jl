using DataFrames
using DrWatson
using Lasso
using LinearAlgebra
using JSON
using NormReg
using Distributions
using ProjectRoot
using Random

function binary_simulation_varyq_experiment(n, p, s, normalization, q_type, snr)
  x, y, β_true, _ = generate_binary_data(n, p, s, q_type, "constant", snr)

  k = 10
  train_size = 0.75

  err, _, β_est = cross_validate(x, y, Normal(), normalization, k, train_size, "nmse")

  return err, β_est, β_true
end

function binary_simulation_varyq_experiment2(n, p, s, normalization, q_type, snr)
  x, y, β_true, σ = generate_binary_data(n, p, s, q_type, "constant", snr)

  x, centers, scales = normalize_features(x, normalization)

  σ = √(var(x * β_true) / snr)

  lambda = σ * sqrt(2 * log(p)) / n

  res = fit(LassoPath, x, y, Normal(), standardize = false, λ = [lambda], maxncoef = p)

  _, coefs_unstandardized = unstandardize_coefficients(res.b0, res.coefs, centers, scales)

  return 0, coefs_unstandardized, β_true
end

param_dict = Dict(
  "it" => collect(1:50),
  "n" => 500,
  "p" => [1000],
  "s" => [20],
  "snr" => [2],
  "normalization" => ["none", "mean_std", "mean_stdvar"],
  "q_type" => ["decreasing"],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, n, p, s, snr, normalization, q_type = d

  Random.seed!(it * 2)

  err, β_est, β_true =
    binary_simulation_varyq_experiment2(n, p, s, normalization, q_type, snr)

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas"] = β_est

  push!(results, d_exp)
end

outfile = @projectroot("data", "binary_data_decreasing.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

include(@projectroot("scripts", "plots", "binary_decreasing.jl"))
