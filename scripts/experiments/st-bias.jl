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
σe = 4;
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
Z = Normal(μ, σ)

λ = 0.5 * μ

# # Numerical verification
# n_z = 10_000
#
# z = rand(Z, n_z)
#
# st_z = st.(z, λ);
# bias_emp = mean(st_z) - μ
# var_emp = var(st_z)
# mse_emp = mean((st_z .- μ) .^ 2) # var_emp + bias_emp^2
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

function st_expected_value(μ, σ, λ)
  X = Normal()

  θ = μ - λ
  γ = -(λ + μ)

  return -γ * cdf(X, γ / σ) - σ * pdf(X, γ / σ) + θ * cdf(X, θ / σ) + σ * pdf(X, θ / σ)
end

function bias_simulation(q::Float64, σe::Float64, method::String, λ::Real = 0.5)
  Random.seed!(852)

  # σe = 4
  #
  β = 1

  λ = λ * n

  # x = zeros(n)
  # x[1:ceil(Int, n * q)] .= 1
  #
  # xs = (x .- mean(x)) / var(x)
  #
  # y = x * β + rand(Normal(0, σe), n)
  # z = xs' * y
  #
  # s = q * (1 - q)
  #
  # μ = β * n * q * (1 - q) / s
  #
  # σ2 = σe^2 * q * (1 - q) / s^2
  # σ = sqrt(σ2)
  #
  # Y = Normal()
  # Z = Normal(μ, σ)
  #
  # λ = 0.5 * μ

  if method == "var"
    s = q * (1 - q)
  elseif method == "std"
    s = sqrt(q * (1 - q))
  elseif method == "none"
    s = 1
  end

  μ = β * q * (1 - q) / s
  σ = sqrt(σe^2 * q * (1 - q) / (n * s^2))

  expected_value = st_expected_value(μ, σ, λ)

  return err
end

param_dict = Dict{String,Any}(
  "q" => collect(0.5:0.1:0.9),
  "sigma_e" => [0.5, 1, 2],
  "method" => ["std", "var", "none"],
  "lambda" => [0.1, 0.5, 0.9],
)
param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, sigma_e, method, lambda = d

  err = bias_simulation(q, sigma_e, method, lambda)

  # Create a wide data frame
  # input = [ns betas']
  # beta_wide = DataFrame([ns betas'], ["n", "Normal", "Bernoulli"])
  # beta_long = stack(beta_wide, Not(:n))

  d_exp = copy(d)
  d_exp["bias"] = err

  push!(results, d_exp)
end

df = DataFrame(results);
# df_flat = DataFrames.flatten(df, [:n, :beta, :distribution]);
#
df_subset = subset(df, :lambda => l -> l .== 0.1, :sigma_e => s -> s .== 1)

pl = @df df_subset plot(
  :q,
  :bias,
  groups = :method,
  ylabel = "bias",
  xlabel = "q",
  size = (235, 175),
)

# file_name = "maxabs_n"
# file_path = @projectroot("paper", "plots", "bias.pdf")
#
# savefig(pl, file_path)
