using DrWatson

@quickactivate "normreg"

using Random
using LinearAlgebra
using Distributions
using Statistics
using DataFrames
using Lasso
using Plots

using Convex
using SCS
using GLPK
using COSMO

include(srcdir("preprocessing.jl"))
include(srcdir("lasso_utils.jl"))
include(srcdir("generate_twodim_data.jl"))

function orthogonalSolution(x, y, λ, centers, scales)
  p = size(x, 2)
  out = zeros(size(x, 2))

  for j in 1:p
    x_tilde = x[:, j] .- centers[j]
    xty = x_tilde'y
    out[j] = scales[j] * softThreshold(xty, scales[j] * λ) / norm(x_tilde)^2
  end

  out
end

Random.seed!(12345)

p = 2
n = 10000
m = 20

sigma = 0.5
d_normal = Normal(0, sigma)

lambda = [4500.0]

betas = zeros(p + 1, m)
std_betas = zeros(p + 1, m)
ols_betas = zeros(p + 1, m)
orth_betas = zeros(p + 1, m)
ps = range(0.01, 0.5, length = m)

x1 = rand(d_normal, n)
noise = rand(Normal(0, 1), n)

cov = zeros(m)
s = zeros(m)
p_real = zeros(m)

for i in 1:m
  x = generate_twodim_data(n, ρ = 0, μ = 0, σ = 1, p = ps[i])
  beta = [2, 1.0]

  y = x * beta

  ols_fit = lm(x, y)

  x_std, centers, scales = normalize(x, "mean_var")

  ols_fit = lm(x_std, y)

  ols_betas = coef(ols_fit)

  p_real[i] = mean(x[:, 2])

  # covs = (x .- mean(x, dims = 1))'y / n
  #
  # for j in 1:p
  #   x_std[:, j] = x_std[:, j] * covs[j]
  # end

  cov[i] = x_std[:, 2]'y
  s[i] = scales[2]

  model = Lasso.fit(
    Lasso.LassoPath,
    x_std,
    y,
    α = 1,
    Normal(),
    standardize = false,
    λ = lambda / n,
    intercept = true,
  )

  # λlist = 0:0.5:10
  # βpath = zeros(p + 1, length(λlist))
  # βhat are optimization variables
  # β = Variable(size(x, 2))
  # β0 = Variable(1)
  # problem = minimize(norm(y - x_std * β - β0) + lambda * norm(β, 1))
  # solve!(problem, COSMO.Optimizer)
  # betas[:, i] = [β0.value; β.value]

  betas[:, i] = [model.b0; model.coefs]
  intercept, std_beta = unstandardize_coefficients([0.0], model.coefs, centers, scales)
  # intercept, std_beta = unstandardize_coefficients([0.0], β.value, centers, scales)
  std_betas[:, i] = [intercept; std_beta]
end

p1 = plot(ps, betas[2, :], label = "normal", ylims = [0, 1.1], title = "Lasso")
plot!(ps, betas[3, :], label = "binary")

p2 = plot(
  ps,
  std_betas[2, :],
  label = "normal",
  ylims = [0, 1.1],
  title = "Lasso (original scale)",
)
plot!(ps, std_betas[3, :], label = "binary")

plot(p1, p2, layout = (2, 2))

# plot(ps, cov)
# plot(ps, s)
# pa = plot(ps, cov)
# pb = plot(ps, s)
#
# plot(pa, pb)
