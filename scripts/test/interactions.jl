using NormReg
using DataFrames
using Statistics
using LinearAlgebra
using Random
using Distributions
using GLM

n = 10000
q = 0.9
mu = 0
sigma = 2

x1 = generate_pseudobernoulli(n, q = q);
x2 = generate_pseudonormal(n, μ = mu, σ = sigma);
x1 .-= mean(x1)
x2 .-= mean(x2)

cor(x1 .* x2, x1)
mu * q * (1 - q)
cor(x1 .* x2, x2)

# x3 = (x1 .- mean(x1)) .* (x2 .- mean(x2));
x3 = x1 .* x2

var(x3)
q * (sigma^2 + mu^2 * (1 - q))

(sigma^2 + mu^2) * q * (1 - q)

x = hcat(x1, x2, x3);

beta = [1, 1, 1]

y = x * beta + rand(Normal(0, 0.9), n);

cor(hcat(x, y))

# x1 .-= mean(x1)
x2 .-= mean(x2)
x3 = x1 .* x2

x = hcat(x1, x2, x3);

cor(hcat(x, y))

df = DataFrame(y = y, x1 = x1, x2 = x2, x3 = x3);

res = lm(@formula(y ~ x1 + x2 + x3), df)

x2a = x2[x1 .== 0]
x2b = x2[x1 .== 1]
ya = y[x1 .== 0]
yb = y[x1 .== 1]

plot(x2a, ya, seriestype = :scatter, label = "a")
plot!(x2b, yb, seriestype = :scatter, label = "b")
