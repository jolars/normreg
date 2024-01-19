using DrWatson

@quickactivate "normreg"

include(srcdir("preprocessing.jl"))
include(srcdir("lasso_utils.jl"))
include(srcdir("generate_data.jl"))

using Random
using LinearAlgebra
using Distributions
using Statistics
using DataFrames
using Lasso
using Plots

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

  beta = [1, 1]

  # Generate data once to compute lambda_max
  x = generate_binary_gaussian_features(n, ρ = ρ, μ = 0, σ = σ, p = 0.5)
  y = x * beta
  x_std, _, _ = normalize(x, normalization)
  λmax = maximum(abs.(x_std' * (y .- mean(y))))
  λ = λmax * 0.75 / n

  betas = zeros(2, n_ps)
  ps = range(0.5, 0.99, length = n_ps)

  for i in 1:n_ps
    beta_hat = zeros(2)
    for _ in 1:n_it
      x = generate_binary_gaussian_features(n, ρ = ρ, μ = 0, σ = σ, p = ps[i])

      y = x * beta
      # y = x * beta .+ rand(Normal(0, 1))

      x_std, centers, scales = normalize(x, normalization)

      model = Lasso.fit(
        Lasso.LassoPath,
        x_std,
        y,
        α = α,
        Normal(),
        standardize = false,
        λ = [λ],
        intercept = true,
      )

      _, beta_hat_it =
        unstandardize_coefficients(model.b0, model.coefs, centers, scales)

      # Compute the average across the iterations
      beta_hat += beta_hat_it / n_it
    end
    betas[:, i] = beta_hat
  end

  return betas, ps
end

param_dict = Dict(
  "sigma" => 0.5,
  "rho" => [0],
  "alpha" => [0, 1],
  "normalization" => ["none", "mean_std", "mean_var", "mean_stdvar"],
)

expanded_params = dict_list(param_dict)

for (i, d) in enumerate(expanded_params)
  @unpack sigma, rho, alpha, normalization = d

  betas, ps = binary_gaussian_simulation(sigma, rho, alpha, normalization)

  d_exp = copy(d)
  d_exp["betas"] = betas
  d_exp["ps"] = ps

  safesave(datadir("lasso_ridge_twodim", savename(d, "jld2")), d_exp)
end
