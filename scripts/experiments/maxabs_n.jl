using DataFrames
using Random
using Distributions
using Statistics
using Lasso
using ProjectRoot
using DrWatson
using JSON
using NormReg

function maxabs_n_simulation(σ, q; n_min = 10, n_max = 500, n_ns = 100, n_iter = 100)
  ns = Int64.(round.(range(n_min, n_max, length = n_ns)))

  Random.seed!(1234)

  d_normal = Normal(0, σ)
  d_binary = Bernoulli(q)

  betas = zeros(2, length(ns))

  beta = [1.0, 1.0]

  x1 = rand(d_normal, 500)
  x2 = rand(d_binary, 500)
  x = [x1 x2]
  y = x * beta
  x_std, _, _ = normalize_features(x, "max_abs")

  λmax = get_lambdamax(x_std, y)

  lambda = λmax * 0.9

  for i in eachindex(ns)
    n = ns[i]
    beta_hat_avg = zeros(2)

    for _ in 1:n_iter
      x1 = rand(d_normal, n)
      x2 = rand(d_binary, n)

      x = [x1 x2]

      y = x * beta + rand(Normal(0, 1), n)

      x_std, centers, scales = normalize_features(x, "max_abs")

      model =
        Lasso.fit(Lasso.LassoPath, x_std, y, Normal(), standardize = false, λ = [lambda])

      _, beta_hat = unstandardize_coefficients(model.b0, model.coefs, centers, scales)

      beta_hat_avg .+= beta_hat / n_iter
    end

    betas[:, i] = beta_hat_avg
  end

  return betas, ns
end

param_dict = Dict{String,Any}("sigma" => 0.5, "q" => 0.5, "model" => "lasso")

param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack sigma, q, model = d

  betas, ns = maxabs_n_simulation(sigma, q, n_iter = 700)

  # Create a wide data frame
  input = [ns betas']
  beta_wide = DataFrame([ns betas'], ["n", "Normal", "Bernoulli"])
  beta_long = stack(beta_wide, Not(:n))

  d_exp = copy(d)
  d_exp["n"] = beta_long.n
  d_exp["distribution"] = beta_long[:, 2]
  d_exp["beta"] = beta_long[:, 3]

  push!(results, d_exp)
end

outfile = @projectroot("data", "maxabs_n.json")

open(outfile, "w") do f
  write(f, JSON.json(results))
end
