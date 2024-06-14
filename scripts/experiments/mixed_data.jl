using Random
using LinearAlgebra
using Distributions
using DrWatson
using Statistics
using DataFrames
using Plots
using JSON
using ProjectRoot
using NormReg

function binary_gaussian_simulation(
  α = 1,
  delta = 0.5,
  snr = 1,
  n_it = 50,
  n_qs = 100,
  n = 1000,
  seed = 909,
)
  Random.seed!(seed)

  p = 2

  beta = [1, 1]
  betas = zeros(p, n_qs)
  betas_std = zeros(p, n_qs)
  qs = range(0.5, 0.99, length = n_qs)

  for i in 1:n_qs
    beta_hat = zeros(n_it, p)
    for k in 1:n_it
      # println("Iteration: $k, q: $(qs[i])\r")
      x1 = generate_pseudobernoulli(n, q = qs[i])
      x2 = generate_pseudonormal(n; μ = 0, σ = 0.5)
      # x3 = generate_pseudonormal(n; μ = 0, σ = 2)

      x = [x1 x2]
      # x = [x1 x2 x3]

      σe = √(var(x * beta) / snr)

      y = x * beta + rand(Normal(0, σe), n)

      if α == 0 || α == 1
        x_std, centers, scales = normalize_features(x, delta)

        λmax = maximum(abs.(x_std' * (y .- mean(y))))

        λ = α == 0 ? λmax * 2 : λmax * 0.5
        res = elasticnet(x_std, y, α = α, λ = [λ])
        _, beta_hat_it = unstandardize_coefficients(res.β0, res.β, centers, scales)
      else
        w = vec(scaling_factors(x, delta))
        λmax = maximum(abs.(x' * (y .- mean(y))))

        λ = λmax * 0.5
        beta_hat_it, _, _ = elasticnet(x, y, α = α, λ = [λ], w1 = w, w2 = w)
      end

      # model = Lasso.fit(
      #   Lasso.LassoPath,
      #   x_std,
      #   y,
      #   Normal(),
      #   α = α,
      #   standardize = false,
      #   λ = [λ/n],
      #   intercept = true,
      # )

      # Compute the average across the iterations
      beta_hat[k, :] = beta_hat_it
    end
    betas[:, i] = mean(beta_hat, dims = 1)
    betas_std[:, i] = std(beta_hat, dims = 1)
  end

  return betas, betas_std, qs
end

param_dict =
  Dict("alpha" => [0, 0.5, 1], "delta" => [0, 0.5, 1], "snr" => [0.5], "dummy" => "dummy")

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack alpha, delta, snr = d

  betas, betas_std, qs = binary_gaussian_simulation(alpha, delta, snr)

  d_exp = copy(d)
  d_exp["betas"] = betas
  d_exp["betas_std"] = betas_std
  d_exp["qs"] = qs

  push!(results, d_exp)
end

outfile = @projectroot("data", "mixed_data.json");

open(outfile, "w") do f
  write(f, JSON.json(results))
end

# include(@projectroot("scripts", "plots", "mixed_data.jl"))
