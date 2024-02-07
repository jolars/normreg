using DataFrames
using DrWatson
using JSON
using NormReg
using ProjectRoot
using Random

function binary_simulation_varyq_experiment(n, p, s, normalization, q_type, snr)
  x, y, β_true = generate_binary_data(n, p, s, q_type, "constant", snr)

  k = 10
  train_size = 0.75

  err, _, β_est = cross_validate(x, y, Normal(), normalization, k, train_size, "nmse")

  return err, β_est, β_true
end

snr = collect(logspace(0.05, 6, 5))

param_dict = Dict(
  "it" => collect(1:30),
  "n" => 300,
  "p" => [500],
  "s" => [20],
  "snr" => snr,
  "normalization" => ["none", "mean_std", "mean_stdvar"],
  "q_type" => ["decreasing"],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, n, p, s, snr, normalization, q_type = d

  Random.seed!(it)

  err, β_est, β_true =
    binary_simulation_varyq_experiment(n, p, s, normalization, q_type, snr)

  d_exp = copy(d)
  d_exp["err"] = err
  d_exp["betas"] = β_est

  push!(results, d_exp)
end

outfile = @projectroot("data", "binary_data_decreasing_snr.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end
