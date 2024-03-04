using Distributions
using LinearAlgebra
using QuadGK
using Plots
using LaTeXStrings
using StatsPlots
using Random
using NormReg
using DrWatson
using DataFrames
using ProjectRoot
using SpecialFunctions

# set_plot_defaults()

function st(x, λ)
  return sign(x) * max(abs(x) - λ, 0)
end

function int(f, a, b)
  return quadgk(f, a, b)[1]
end

q = 0.99
β = 1
σe = 2;
n = 100

λ = β * n * 0.9

method = "var"

if method == "var"
  s = q * (1 - q)
elseif method == "std"
  s = sqrt(q * (1 - q))
elseif method == "none"
  s = 1
end

x = zeros(n)
x[1:ceil(Int, n * q)] .= 1

xs = (x .- mean(x)) / s;

y = x * β + rand(Normal(0, σe), n);
z = xs' * y

method = "std"

if method == "var"
  s = q * (1 - q)
elseif method == "std"
  s = sqrt(q * (1 - q))
elseif method == "none"
  s = 1
end

μ = β * n * q * (1 - q) / s

σ2 = σe^2 * n * q * (1 - q) / s^2
σ = sqrt(σ2)

d = n * q * (1 - q) / s

n_z = 100_000

Z = Normal(μ, σ);
z = rand(Z, n_z);

st_z = st.(z, λ) / d;
bias_emp = mean(st_z) - β
var_emp = var(st_z)
mse_emp = mean((st_z .- β) .^ 2) # var_emp + bias_emp^2

# just to check that theoretical results hold
bias_simulation(q, σe, method, n, λ)
