using DrWatson

@quickactivate "normreg"

using GLM
using LIBSVMdata
using Lasso
using Statistics

include("preprocessing.jl")

function path_simulation(dataset, normalization, model = "gaussian")
  if model == "gaussian"
    dist = Normal()
  elseif model == "binomial"
    dist = Binomial()
  else
    error("Model not supported")
  end

  x, y = load_dataset(dataset, dense = true, replace = false, verbose = false)

  x_norm, centers, scales = normalize(Array(x), normalization)

  res = fit(LassoPath, x_norm, y, dist, standardize = false)

  _, betas = unstandardize_coefficients(res.b0, res.coefs, centers, scales)

  return betas
end

param_dict = Dict{String,Any}(
  "dataset" => ["housing", "leukemia", "triazines"],
  "normalization" => ["mean_std", "max_abs"],
  "model" => ["gaussian"],
  "alpha" => 1.0
)

# betas, ns = maxabs_n_simulation(0.5, 0.5)
param_expanded = dict_list(param_dict)

# betas = path_simulation("housing", "mean_std", "gaussian")

for (i, d) in enumerate(param_expanded)
  @unpack dataset, normalization, model, alpha = d

  betas = path_simulation(dataset, normalization, model)

  d_exp = copy(d)
  d_exp["betas"] = betas

  wsave(datadir("realdata_paths", savename(d, "jld2")), d_exp)
end
