using DrWatson

@quickactivate "normreg"

include(srcdir("preprocessing.jl"))
include(srcdir("lasso_utils.jl"))

using Random
using Distributions
using Statistics
using Lasso
using Plots

# function expvalue_gev(n)
#   γ = 0.57721566490153286060651209008240243 # Euler-Mascheroni constant
#
#   return sqrt(log(n^2 / (2 * π * log(n^2 / (2 * π))))) * (1 + γ / log(n))
# end

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
  x_std, _, _ = normalize(x, "max_abs")

  λmax = get_lambdamax(x_std, y)

  lambda = λmax * 0.5

  for i in eachindex(ns)
    n = ns[i]
    beta_hat_avg = zeros(2)

    for _ in 1:n_iter
      x1 = rand(d_normal, n)
      x2 = rand(d_binary, n)

      x = [x1 x2]

      y = x * beta + rand(Normal(0, 1), n)

      x_std, centers, scales = normalize(x, "max_abs")

      model = Lasso.fit(
        Lasso.LassoPath,
        x_std,
        y,
        Normal(),
        standardize = false,
        λ = [lambda],
      )

      _, beta_hat = unstandardize_coefficients(model.b0, model.coefs, centers, scales)

      beta_hat_avg .+= beta_hat / n_iter
    end

    betas[:, i] = beta_hat_avg
  end

  return betas, ns
end

param_dict = Dict{String,Any}(
  "sigma" => 0.5,
  "q" => 0.5,
  "model" => "lasso"
)

betas, ns = maxabs_n_simulation(0.5, 0.5)
param_expanded = dict_list(param_dict)

for (i, d) in enumerate(param_expanded)
  @unpack sigma, q, model = d

  betas, ns = maxabs_n_simulation(sigma, q)

  d_exp = copy(d)
  d_exp["ns"] = ns
  d_exp["beta1"] = betas[1, :]
  d_exp["beta2"] = betas[2, :]

  wsave(datadir("maxabs_n", savename(d, "jld2")), d_exp)
end
