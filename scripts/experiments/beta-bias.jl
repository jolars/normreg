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

set_plot_defaults("gr")

function bias_simulation(q::Real, σe::Real, method::String, n::Int64, λ::Real = 0.5)
  Random.seed!(852)

  β = 1

  if method == "var"
    s = q * (1 - q)
  elseif method == "std"
    s = sqrt(q * (1 - q))
  elseif method == "none"
    s = 1
  end

  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)
  d = binary_d(n, q, s, λ)

  θ = -(μ + λ)
  γ = μ - λ

  eβ = binary_expected_value(θ, γ, σ, d)
  var = binary_variance(θ, γ, σ, d)

  bias = eβ - β
  mse = bias^2 + var

  return bias, var, mse
end

param_dict = Dict{String,Any}(
  "q" => collect(0.5:0.01:0.99),
  "sigma_e" => [0.1, 0.5, 1, 2, 4],
  "method" => ["std", "var", "none"],
  "lambda" => [0.1, 0.5, 0.9, 0.95],
)
param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, sigma_e, method, lambda = d

  n = 100

  bias, var, mse = bias_simulation(q, sigma_e, method, n, lambda)

  # Create a wide data frame
  # input = [ns betas']
  # beta_wide = DataFrame([ns betas'], ["n", "Normal", "Bernoulli"])
  # beta_long = stack(beta_wide, Not(:n))

  d_exp = copy(d)
  d_exp["bias"] = bias
  d_exp["var"] = var
  d_exp["mse"] = mse

  push!(results, d_exp)
end

df = DataFrame(results);

df_long = stack(df, Not([:q, :sigma_e, :method, :lambda]))

df_subset = subset(df_long, :lambda => l -> l .== 0.9, :sigma_e => s -> s .== 0.5)

grouped_df = groupby(df_subset, [:variable])

plots = []

for (i, d) in enumerate(grouped_df)
  ylab = unique(d.variable)[1]

  pl =
    @df d plot(:q, :value, groups = :method, ylabel = ylab, xlabel = "q", size = (235, 175))

  push!(plots, pl)
end

plot(plots..., layout = (3, 1), size = (450, 400))

# file_name = "maxabs_n"
# file_path = @projectroot("paper", "plots", "bias.pdf")
#
# savefig(pl, file_path)
