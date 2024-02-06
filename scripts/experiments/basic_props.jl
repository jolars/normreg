using Random
using Distributions
using SpecialFunctions
using StatsBase
using Plots
using LaTeXStrings

using NormReg

function max_abs(n::Int, X::UnivariateDistribution = Normal(0, 1))
  x = rand(X, n)
  maximum(abs.(x))
end

function gev_mean(n, Y)
  b_n = quantile(Y, 1 - 1 / n)
  a_n = 1 / (n * pdf(Y, b_n))

  b_n + gamma * a_n
end

μ = -15
σ = 10

n_n = 100

n = Int.(range(10, 1000, length = n_n))

n_it = 1000

X = Normal(μ, σ)

gamma = -digamma(1)

# Mises
Y = NormReg.FoldedNormal(μ, σ)

y = gev_mean.(n, Ref(Y))

y_true = zeros(n_n)
y_err = zeros(n_n)

for i in 1:n_n
  tmp = [max_abs(n[i], X) for _ in 1:n_it]
  y_true[i] = mean(tmp)
  y_err[i] = std(tmp) / sqrt(n_it)
end

# Calculate the standard error
lo = y_true .- y_err
hi = y_true .+ y_err

plot(n, y_true; ribbon = (y_err, y_err), label = "Empirical")
plot!(n, y, color = :red, label = "Theoretical")
xaxis!(L"n")
yaxis!(L"\max_i |x_i|")
