using Lasso
using LinearAlgebra
using Random
using NormReg
using Plots
using LIBSVMdata

dataset = "housing"

x, y = load_dataset(dataset, dense = true, replace = false, verbose = false);

n, p = size(x)

α = 0.9

Random.seed!(1234)

# w = abs.(rand(Float64, p));
# w = w * p / sum(w);

λ = 750

# lambda1 = w .* λ .* α;
# lambda2 = w .* λ .* (1 - α);

# beta, intercept = ridge(x, y, lambda2)

w1 = ones(Float64, p)
w2 = ones(Float64, p)

α = 1.0

betas, intercepts = elasticnet(x, y, α, fit_intercept = true)

# res = Lasso.fit(
#   Lasso.LassoPath,
#   x,
#   y,
#   Normal(),
#   λ = [λ / n],
#   intercept = false,
#   standardize = false,
#   penalty_factor = w,
#   α = α,
#   standardizeω = false,
#   cd_tol = 1e-12,
# )
#
# # plot(gaps, yaxis = :log)
# # plot(primals .- last(primals) .+ 1e-11, yaxis = :log)
