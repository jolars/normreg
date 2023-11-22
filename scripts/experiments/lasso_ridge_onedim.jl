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

function onedim_solution(x, y, c, s, λ, α)
  n = size(x, 1)
  x_norm = (x .- c) / s
  a = x_norm'y - mean(x_norm) * sum(y)
  b = x_norm'x_norm - sum(x_norm)^2 / n + (1 - α) * λ

  unstandardized_beta = softThreshold(a, λ * α) / b

  return unstandardized_beta / s
end

μ = 0.3
σ = 2.3

dist = Normal(μ, σ)

n = 1000

x = rand(dist, n)
β = 2
y = β * x

c = mean(x)
s = std(x, corrected = false)

λ = 0.5 * n
α = 1

res = onedim_solution(x, y, c, s, λ, α)

model = Lasso.fit(
  Lasso.LassoPath,
  reshape(x, (n, 1)),
  y,
  α = α,
  Normal(),
  standardize = true,
  λ = [λ] / n,
  intercept = true,
)

coef(model)

res
