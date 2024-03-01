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

function integrate(f, d, a = -15, b = -15; n = 100_000)
  x = range(a, b, length = n)
  dx = (b - a) / n
  return sum(f.(x) .* pdf.(d, x) * dx)
end

function int(f, a, b)
  return quadgk(f, a, b)[1]
end

snorm = Normal()
ϕ(x) = pdf(Normal(), x)
Φ(x) = cdf(Normal(), x)

q = 0.999
inf = 5
β = 3
σe = 1;
n = 100

x = zeros(n)
x[1:ceil(Int, n * q)] .= 1

xs = (x .- mean(x)) / var(x)

y = x * β + rand(Normal(0, σe), n)
z = xs' * y

s = q * (1 - q)

μ = β * n * q * (1 - q) / s

σ2 = σe^2 * q * (1 - q) / s^2
σ = sqrt(σ2)

Y = Normal()

#
# lo = (-λ - μ) / σ
# up = (λ - μ) / σ
# bias_th =
#   integrate(x -> σ * x + λ + μ, snorm, -inf, lo) +
#   integrate(x -> σ * x - λ + μ, snorm, up, inf) - μ
#
# mua = μ - λ
# mub = -(λ + μ)
#
# (λ + μ) * cdf(snorm, mub / σ) - σ * pdf(snorm, mub / σ) +
# mua * cdf(snorm, mua / σ) +
# σ * pdf(snorm, mua / σ) - μ
method = "var"

q = 0.99

if method == "var"
  s = q * (1 - q)
elseif method == "std"
  s = sqrt(q * (1 - q))
elseif method == "none"
  s = 1
end

μ = β * n * q * (1 - q) / s
σ = sqrt(σe^2 * n * q * (1 - q) / (s^2))

d = n * q * (1 - q) / s

λ = 0.5 * μ

X = Normal()

θ = -(μ + λ)
γ = μ - λ

# BIAS

eee =
  int(x -> (x + λ) * pdf(Normal(μ, σ), x), -Inf, -λ) +
  int(x -> (x - λ) * pdf(Normal(μ, σ), x), λ, Inf)
eee / d

ee = -θ * cdf(X, θ / σ) - σ * pdf(X, θ / σ) + γ * cdf(X, γ / σ) + σ * pdf(X, γ / σ)
bb = ee / d

θ / σ
-θ * cdf(X, θ / σ)
-σ * pdf(X, θ / σ)
γ * cdf(X, γ / σ)
σ * pdf(X, γ / σ)

# Variance
int(x -> (x - λ)^2 * pdf(Normal(μ, σ), x), λ, Inf)

a1 = σ^2 * int(x -> x^2 * pdf(Normal(), x), -(γ / σ), Inf)
a2 = 2 * γ * σ * int(x -> x * pdf(Normal(), x), -(γ / σ), Inf)
a3 = γ^2 * int(x -> pdf(Normal(), x), -(γ / σ), Inf)

a1 + a2 + a3

m = γ / σ
b1 =
  (σ^2 / sqrt(2 * pi)) *
  (sqrt(pi) * erf(m / sqrt(2)) / sqrt(2) - m * exp(-m^2 / 2) + sqrt(pi / 2))
b2 = 2 * γ * σ * pdf(X, γ / σ)
b3 = γ^2 * cdf(X, γ / σ)

b1 + b2 + b3

int(x -> (x + λ)^2 * pdf(Normal(μ, σ), x), -Inf, -λ)

c1 = σ^2 * int(x -> x^2 * pdf(Normal(), x), -Inf, θ / σ)
c2 = -2 * θ * σ * int(x -> x * pdf(Normal(), x), -Inf, θ / σ)
c3 = θ^2 * int(x -> pdf(Normal(), x), -Inf, θ / σ)

c1 + c2 + c3

m2 = θ / σ
d1 =
  (σ^2 / sqrt(2 * pi)) *
  (sqrt(pi) * erf(m2 / sqrt(2)) / sqrt(2) - m2 * exp(-m2^2 / 2) + sqrt(pi / 2))
d2 = 2 * θ * σ * pdf(X, θ / σ)
d3 = θ^2 * cdf(X, θ / σ)

d1 + d2 + d3

# (σ^2 / sqrt(pi)) * gamma(3 / 2, γ^2 / (2 * σ^2))

# Numerical verification
e2n =
  int(x -> (x + λ)^2 * pdf(Normal(μ, σ), x), -Inf, -λ) +
  int(x -> (x - λ)^2 * pdf(Normal(μ, σ), x), λ, Inf)
e2 = e2n / (d^2)

vv = e2 - bb^2

n_z = 100_000

Z = Normal(μ, σ)
z = rand(Z, n_z)

st_z = st.(z, λ) / d;
bias_emp = mean(st_z) - β
var_emp = var(st_z)
mse_emp = mean((st_z .- β) .^ 2) # var_emp + bias_emp^2

# function st_expected_value(μ, σ, λ)
#   X = Normal()
#
#   θ = μ - λ
#   γ = -(λ + μ)
#
#   return -γ * cdf(X, γ / σ) - σ * pdf(X, γ / σ) + θ * cdf(X, θ / σ) + σ * pdf(X, θ / σ)
# end
#
# function bias_simulation(q::Float64, σe::Float64, method::String, λ::Real = 0.5)
#   Random.seed!(852)
#
#   # σe = 4
#   #
#   β = 1
#
#   λ = λ * n
#
#   # x = zeros(n)
#   # x[1:ceil(Int, n * q)] .= 1
#   #
#   # xs = (x .- mean(x)) / var(x)
#   #
#   # y = x * β + rand(Normal(0, σe), n)
#   # z = xs' * y
#   #
#   # s = q * (1 - q)
#   #
#   # μ = β * n * q * (1 - q) / s
#   #
#   # σ2 = σe^2 * q * (1 - q) / s^2
#   # σ = sqrt(σ2)
#   #
#   # Y = Normal()
#   # Z = Normal(μ, σ)
#   #
#   # λ = 0.5 * μ
#
#   if method == "var"
#     s = q * (1 - q)
#   elseif method == "std"
#     s = sqrt(q * (1 - q))
#   elseif method == "none"
#     s = 1
#   end
#
#   μ = β * q * (1 - q) / s
#   σ = sqrt(σe^2 * q * (1 - q) / (n * s^2))
#
#   expected_value = st_expected_value(μ, σ, λ)
#
#   return expected_value
# end
#
# param_dict = Dict{String,Any}(
#   "q" => collect(0.5:0.1:0.9),
#   "sigma_e" => [0.5, 1, 2],
#   "method" => ["std", "var", "none"],
#   "lambda" => [0.1, 0.5, 0.9],
# )
# param_expanded = dict_list(param_dict)
#
# results = []
#
# for (i, d) in enumerate(param_expanded)
#   @unpack q, sigma_e, method, lambda = d
#
#   err = bias_simulation(q, sigma_e, method, lambda)
#
#   # Create a wide data frame
#   # input = [ns betas']
#   # beta_wide = DataFrame([ns betas'], ["n", "Normal", "Bernoulli"])
#   # beta_long = stack(beta_wide, Not(:n))
#
#   d_exp = copy(d)
#   d_exp["bias"] = err
#
#   push!(results, d_exp)
# end
#
# df = DataFrame(results);
#
# df_subset = subset(df, :lambda => l -> l .== 0.1, :sigma_e => s -> s .== 1)
#
# pl = @df df_subset plot(
#   :q,
#   :bias,
#   groups = :method,
#   ylabel = "bias",
#   xlabel = "q",
#   size = (235, 175),
# )

# file_name = "maxabs_n"
# file_path = @projectroot("paper", "plots", "bias.pdf")
#
# savefig(pl, file_path)
