using DrWatson
@quickactivate "normreg"

include(srcdir("preprocessing.jl"))
include(srcdir("fit_lasso.jl"))

using Random
using Distributions
using Statistics
using Lasso
using Plots

allparams = Dict(
    "a" => [1, 2], # it is inside vector. It is expanded.
    "b" => [3, 4],
    "v" => [rand(5)],     # single element inside vector; no expansion
    "method" => "linear", # not in vector = not expanded, even if naturally iterable
)

dicts = dict_list(allparams)

function expvalue_gev(n)
  γ = 0.57721566490153286060651209008240243 # Euler-Mascheroni constant

  return sqrt(log(n^2 / (2 * π * log(n^2 / (2 * π))))) * (1 + γ / log(n))
end

n_ns = 100

ns = Int64.(round.(range(10, 500, length = 100)))

Random.seed!(1234)

sigma = 0.5
prob = 0.5

d_normal = Normal(0, sigma)
d_binary = Bernoulli(prob)

betas = zeros(p, length(ns))

beta = [1.0, 1.0]
lambda = [0.2]

n_iter = 100

for i in eachindex(ns)
  n = ns[i]
  beta_std_means = zeros(2)

  for it in 1:n_iter
    x1 = rand(d_normal, n)
    x2 = rand(d_binary, n)

    x = [x1 x2]

    y = x * beta + rand(Normal(0, 1), n)

    x_std, centers, scales = normalize(x, "max_abs")

    model =
      Lasso.fit(Lasso.LassoPath, x_std, y, Normal(), standardize = false, λ = lambda)
    beta0_hat = model.b0
    beta_hat = model.coefs

    beta0_std, beta_std =
      unstandardize_coefficients(beta0_hat, beta_hat, centers, scales)

    beta_std_means .+= beta_std / n_iter
  end

  betas[:, i] = beta_std_means
end

plot(ns, betas[1, :], label = "normal")
plot!(ns, betas[2, :], label = "binary")

wsave(savename("maxabs-n"))
