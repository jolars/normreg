using Random
using LinearAlgebra
using Distributions
using Statistics
using DataFrames
using Lasso
using Plots

include("preprocessing.jl")

function softThreshold(x, λ)
  return sign(x) * max(abs(x) - λ, 0)
end

function fit_lasso(x, y, λ; intercept = true)
  n = size(x, 1)

  model = Lasso.fit(
    Lasso.LassoPath,
    x,
    y,
    Normal(),
    standardize = false,
    λ = λ / n,
    intercept = intercept,
  )

  return model.coefs
end
