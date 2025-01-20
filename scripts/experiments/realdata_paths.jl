using GLM
using DrWatson
using ProjectRoot
using LIBSVMdata
using JSON
using Statistics
using NormReg

function path_simulation(dataset, normalization, model = "gaussian")
  if model == "gaussian"
    dist = Normal()
  elseif model == "binomial"
    dist = Binomial()
  else
    error("Model not supported")
  end

  x, y = load_dataset(dataset, dense = true, replace = false, verbose = false)

  x_norm, centers, scales = normalize_features_unadjusted(Array(x), normalization)

  betas, intercepts, λ = elasticnet(x_norm, y)

  _, betas = unstandardize_coefficients(intercepts, betas, centers, scales)

  return betas
end

param_dict = Dict{String,Any}(
  "dataset" => ["housing", "leukemia", "triazines", "w1a"],
  "normalization" => ["std", "max_abs"],
  "model" => ["gaussian"],
  "alpha" => 1.0,
)

param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack dataset, normalization, model, alpha = d

  betas = path_simulation(dataset, normalization, model)

  d_exp = copy(d)
  d_exp["betas"] = betas

  push!(results, d_exp)
end

outfile = @projectroot("results", "realdata_paths.json")

open(outfile, "w") do f
  write(f, JSON.json(results))
end
