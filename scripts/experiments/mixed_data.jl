using DataFrames
using DrWatson
using Distributions
using JSON
using NormReg
using Random
using ProjectRoot

function sim(n, p, s, normalization, q_type, beta_type, snr)
  x, y, β_true = generate_mixed_data(n, p, s, q_type, beta_type, snr)

  k = 10
  train_size = 0.75

  err, _, β_est = cross_validate(x, y, Normal(), normalization, k, train_size, "nmse")

  return err, β_est, β_true
end

param_dict = Dict(
  "it" => collect(1:20),
  "n" => 400,
  "p" => [1000],
  "s" => [20],
  "normalization" => ["none", "mean_std", "mean_stdvar"],
  # "q_type" => ["linear", "balanced", "imbalanced", "very_imbalanced"],
  "q_type" => ["geometric"],
  "beta_type" => "constant",
  "snr" => 12.0,
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, n, p, s, normalization, q_type, beta_type, snr = d

  Random.seed!(it)

  err, β_est, β_true = sim(n, p, s, normalization, q_type, beta_type, snr)

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas_est"] = β_est
  d_exp["betas_true"] = β_true

  push!(results, d_exp)
end

outfile = @projectroot("data", "mixed_data.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end
