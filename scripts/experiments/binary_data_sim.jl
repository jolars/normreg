using NormReg
using JSON
using DataFrames
using Random
using LIBSVMdata
using ProjectRoot
using Lasso
using Statistics
using GLM
using DrWatson

function binary_simulation_varyq_experiment(n, p, s, normalization, q_type, snr)
  beta_type = "constant"

  x, y, β_true, _ = generate_binary_data(n, p, s, q_type, beta_type, snr)

  err, _, β_est = holdout_validation(x, y, Normal(), normalization, "nmse")

  return err, β_est, β_true
end

snr = collect(NormReg.logspace(0.05, 6, 10))

param_dict = Dict(
  "it" => collect(1:100),
  "n" => 300,
  "p" => 1000,
  "s" => 10,
  "normalization" => ["none", "mean_std", "mean_stdvar"],
  "q_type" => ["balanced", "imbalanced", "very_imbalanced"],
  "snr" => snr,
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, n, p, s, normalization, q_type, snr = d

  Random.seed!(it)

  err, β_est, β_true =
    binary_simulation_varyq_experiment(n, p, s, normalization, q_type, snr)

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas"] = β_est

  push!(results, d_exp)
end

outfile = @projectroot("data", "binary_data_sim.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

include(@projectroot("scripts", "plots", "binary_data_sim.jl"))
