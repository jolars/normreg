using Random
using Lasso
using LinearAlgebra
using Distributions
using DrWatson
using Statistics
using DataFrames
using Plots
using JSON
using ProjectRoot
using NormReg

function generate_two_binary_features(n::Int, q::Float64; rho::Float64 = 0.0)
  p1 = 0.5
  p2 = q

  p11 = rho * sqrt(p1 * (1 - p1) * p2 * (1 - p2)) + p1 * p2
  p10 = p1 - p11
  p01 = p2 - p11
  p00 = 1.0 - p1 - p2 + p11

  x1 = Array{Bool}(undef, n)
  x2 = Array{Bool}(undef, n)

  if min(p00, p01, p10, p11) < 0
    # error("Desired correlation not feasible for p1=0.5, p2=", p2)
    return hcat(x1, x2), false
  end

  # Convert probabilities to integer counts
  c11 = round(Int, n * p11)
  c10 = round(Int, n * p10)
  c01 = round(Int, n * p01)
  c00 = n - (c11 + c10 + c01)  # ensure total is n

  idx = 1
  # Fill (0,0)
  for _ in 1:c00
    x1[idx] = false
    x2[idx] = false
    idx += 1
  end
  # Fill (0,1)
  for _ in 1:c01
    x1[idx] = false
    x2[idx] = true
    idx += 1
  end
  # Fill (1,0)
  for _ in 1:c10
    x1[idx] = true
    x2[idx] = false
    idx += 1
  end
  # Fill (1,1)
  for _ in 1:c11
    x1[idx] = true
    x2[idx] = true
    idx += 1
  end

  return hcat(x1, x2), true
end

function orthogonality_simulation(q, rho)
  snr = 1
  n = 10000
  p = 2
  alpha = 1.0

  x, ok = generate_two_binary_features(n, q, rho = rho)

  if !ok
    return [NaN, NaN]
  end

  sigma = sqrt(var(x * [1.0, 1.0]) / snr)

  beta = [1.0, 1.0]

  # x, y, beta, sigma =
  #   generate_binary_data(n, 2, 2, "decreasing", "constant", snr, rho, q_end = q)

  y = x * beta + rand(Normal(0, sigma), n)

  x_std, centers, scales = normalize_features(x, 0.0)

  λmax = maximum(abs.(x_std' * (y .- mean(y))))

  λ = λmax * 0.5
  res = elasticnet(x_std, y, α = alpha, λ = [λ]; cyclic = false, screen = false)
  _, beta_hat_it = unstandardize_coefficients(res.β0, res.β, centers, scales)

  return beta_hat_it
end

qs = collect(range(0.5, 0.9, length = 10))
rhos = [0.0, 0.4, 0.6]

param_dict = Dict("it" => collect(1:10), "q" => qs, "rho" => rhos, "beta" => [[0.0, 0.0]])

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack it, q, rho, beta = d

  Random.seed!(it)

  beta = orthogonality_simulation(q, rho)

  d_exp = copy(d)
  d_exp["beta"] = beta

  push!(results, d_exp)
end

outfile = @projectroot("results", "orthogonality.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

# x1, x2 = generate_two_binary_features_deterministic(10000, 0.2, rho=0.5)
# x = hcat(x1, x2)
# mean(x, dims=1)
# cor(x)
