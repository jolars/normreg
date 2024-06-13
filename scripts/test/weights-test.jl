using Statistics
using LinearAlgebra
using Random
using NormReg
using Plots
using LIBSVMdata
using Distributions

function generate_mgaussian(n::Int, correlation::Float64)
    μ = [0.0, 0.0] 
    Σ = [1.0 correlation; correlation 0.25]
    dist = MvNormal(μ, Σ)
    rand(dist, n)'
end

# Usage
x = generate_mgaussian(1000, 0.0)
# x, y, β = generate_binary_data(10000, 2, 2, "decreasing", "constant", 5, 0.5)

beta = [0.5, 1]
y = x * beta

δ = 0.5

s = vec(var(x, dims = 1)) .^ δ;

x_std = x * Diagonal(1 ./ s);

λ = [8000]

α = 0

fit1 = elasticnet(x_std, y, λ = λ, α = α);
fit2 = elasticnet(x, y, λ = λ, w1 = s, w2 = s, α = α);
# fit = elasticnet(x, y, 0.5, nothing, ones(size(x, 2)), ones(size(x, 2)))


coef1 = fit1[1] ./ s
coef2 = fit2[1]
