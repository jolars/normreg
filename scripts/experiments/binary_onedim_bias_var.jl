using JSON
using NormReg
using DrWatson
using ProjectRoot

function onedim_bias_sim(q::Real, σe::Real, δ::Real, n::Int64, λ::Real = 0.5, α::Real = 1)
  Random.seed!(852)

  β = 2

  s = (q - q^2)^δ

  if α == 1
    λ = λ / 0.25^δ
  elseif α == 0
    λ = λ / 0.25^(2*δ)
  else
    λ = λ / 0.25^(1.31*δ)
  end

  λ1 = λ * α

  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)

  d = binary_d(n, q, s, λ, α)

  θ = -(μ + λ1)
  γ = μ - λ1

  eβ = binary_expected_value(θ, γ, σ, d, print_components = false)
  v = binary_variance(θ, γ, σ, d)

  bias = eβ - β
  mse = bias^2 + v

  return bias, v, mse, λ
end

param_dict = Dict{String,Any}(
  "q" => collect(0.5:0.001:0.999),
  "sigma_e" => [0.25, 0.5, 1, 2],
  "delta" => [0, 1 / 4, 1 / 2, 1.0, 1.5],
  "lambda" => [0.2],
  "α" => [0, 0.5, 1],
)
param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  # d = param_expanded[1]
  @unpack q, sigma_e, delta, lambda, α = d

  n = 100
  lambda = n * lambda

  bias, v, mse, λ = onedim_bias_sim(q, sigma_e, delta, n, lambda, α)

  d_exp = copy(d)
  d_exp["bias"] = bias
  d_exp["var"] = v
  d_exp["mse"] = mse
  d_exp["lambda"] = λ

  push!(results, d_exp)
end

outfile = @projectroot("data", "binary_onedim_bias_var.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

