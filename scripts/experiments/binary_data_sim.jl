using NormReg
using JSON
using DataFrames
using Random
using LIBSVMdata
using Lasso
using Statistics
using MLBase
using GLM
using DrWatson

function binary_simulation_varyq_experiment(n, p, s, normalization, q_type)
  x, y, β_true = generate_mixed_data(n, p, s, q_type)

  k = 10
  train_size = 0.5

  err, _, β_est = crossValidate(x, y, Normal(), normalization, k, train_size, "mse")

  return err, β_est, β_true
end

param_dict = Dict(
  "it" => collect(1:50),
  "n" => 100,
  "p" => [300],
  "s" => [20],
  "normalization" => ["none", "mean_std", "mean_stdvar", "max_abs"],
  "q_type" => ["decreasing", "balanced", "imbalanced", "very_imbalanced"],
)

expanded_params = dict_list(param_dict)

results = []

for (i, d) in enumerate(expanded_params)
  @unpack it, n, p, s, normalization, q_type = d

  err, β_est, β_true =
    binary_simulation_varyq_experiment(n, p, s, normalization, q_type)

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas"] = β_est

  push!(results, d_exp)
end

outfile = here("data", "binary_data_sim.json")

open(outfile, "w") do f
  write(f, JSON.json(results))
end
