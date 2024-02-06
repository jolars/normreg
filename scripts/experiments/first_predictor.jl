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

equivalent_size = function (p::Float64)
  1 / (2.0 * sqrt(p * (1 - p)))
end

equivalent_size(0.01)

function first_preditor_simulation(
  σ = 0.5,
  α = 1,
  normalization = "mean_std";
  n_it = 100,
  n_ps = 10,
  n = 1000,
  seed = 909,
)
  # Random.seed!(seed)

  ps = range(0.5, 0.9, length = n_ps)
  which_first = zeros(2, n_ps)

  for i in 1:n_ps
    # Generate data once to compute lambda_max
    # x = generate_binary_gaussian_features(n, ρ = 0.0, μ = 0, σ = σ, p = 0.5)

    beta2 = equivalent_size(ps[i])

    beta = [1, beta2]

    nonzero = zeros(2)

    for _ in 1:n_it
      x = generate_binary_gaussian_features(n, ρ = 0.0, μ = 0, σ = σ, p = ps[i])
      y = x * beta

      x_std, centers, scales = normalize(x, normalization)

      λmax = maximum(abs.(x_std' * (y .- mean(y))))
      # λ = λmax * 0.99 / n
      λ = λmax / n

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
      nonzero += (beta_hat_it .!= 0) / n_it
    end
    which_first[:, i] = nonzero
  end

  return which_first, ps
end

betas, ps = first_preditor_simulation(0.5, 1, "mean_std", n_it = 10000, n_ps = 10)

display(betas)

# param_dict =
#   Dict("sigma" => 0.5, "alpha" => [0, 0.5], "normalization" => ["none", "mean_std"])
#
# expanded_params = dict_list(param_dict)
#
# for (i, d) in enumerate(expanded_params)
#   @unpack sigma, alpha, normalization = d
#
#   rho = 0.0
#
#   betas, ps = binary_gaussian_simulation(sigma, rho, alpha, normalization)
#
#   d_exp = copy(d)
#   d_exp["betas"] = betas
#   d_exp["ps"] = ps
#
#   safesave(datadir("lasso_ridge_twodim", savename(d, "jld2")), d_exp)
# end
