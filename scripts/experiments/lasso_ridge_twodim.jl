using Random
using LinearAlgebra
using Distributions
using DrWatson
using Statistics
using DataFrames
using Lasso
using Plots
using JSON
using ProjectRoot
using NormReg

function binary_gaussian_simulation(
  σ = 0.5,
  ρ = 0,
  α = 1,
  normalization = "mean_std";
  n_it = 100,
  n_ps = 100,
  n = 1000,
  seed = 909,
)
  Random.seed!(seed)

  beta = [1, 1, 0.25]
  betas = zeros(3, n_ps)
  ps = range(0.5, 0.99, length = n_ps)

  for i in 1:n_ps
    beta_hat = zeros(3)
    for _ in 1:n_it
      x = generate_binary_gaussian_features(n, ρ = ρ, μ = 0, σ = σ, p = ps[i])
      x3 = rand(Normal(0, 2), n)
      x = [x x3]

      y = x * beta
      # y = x * beta .+ rand(Normal(0, 1))

      x_std, centers, scales = normalize_features(x, normalization)

      λmax = maximum(abs.(x_std' * (y .- mean(y))))

      λ = α == 0 ? λmax * 0.25 / n : λmax * 0.15 / n

      model = Lasso.fit(
        Lasso.LassoPath,
        x_std,
        y,
        Normal(),
        α = α,
        standardize = false,
        λ = [λ],
        intercept = true,
      )

      _, beta_hat_it =
        unstandardize_coefficients(model.b0, model.coefs, centers, scales)

      # Compute the average across the iterations
      beta_hat += beta_hat_it / n_it
    end
    betas[:, i] = beta_hat ./ beta
  end

  return betas, ps
end

param_dict = Dict(
  "sigma" => 0.5,
  "rho" => [0],
  "alpha" => [0, 1],
  "normalization" => ["none", "mean_std", "mean_stdvar", "max_abs"],
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack sigma, rho, alpha, normalization = d

  betas, ps = binary_gaussian_simulation(sigma, rho, alpha, normalization)

  d_exp = copy(d)
  d_exp["betas"] = betas
  d_exp["ps"] = ps

  push!(results, d_exp)
end

outfile = @projectroot("data", "lasso_ridge_twodim.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end
