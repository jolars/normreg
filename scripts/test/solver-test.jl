using Lasso
using LinearAlgebra
using Random
using NormReg
using Plots
using LIBSVMdata

dataset = "leukemia"

x, y = load_dataset(dataset, dense = true, replace = false, verbose = false);

n, p = size(x)

fit_intercept = true
λminratio = 1e-4

intercept = mean(y) * fit_intercept
residual = y .- intercept

α = 0

w1 = ones(Float64, p)
w2 = ones(Float64, p)

tmp = abs.(x'residual) ./ (max(1e-3, α) * w1)
max_ind = argmax(tmp)
λmax = tmp[max_ind]

λ = λmax * 0.5

lambda1 = w1 .* α * λ
lambda2 = w2 .* (1 - α) * λ

working_set = collect(1:p)

L = vec(sum(x .^ 2, dims = 1))
beta = zeros(p)

beta, intercept, primals, duals, gaps = cdsolver(
  x,
  y,
  lambda1,
  lambda2,
  L,
  intercept,
  beta,
  working_set;
  fit_intercept = fit_intercept,
)

res =
  elasticnet(x, y, 0.001, nothing, w1, w2, fit_intercept = fit_intercept, verbose = true)
