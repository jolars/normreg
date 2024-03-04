using Distributions
using Plots
using Random
using LaTeXStrings
using StatsPlots
using NormReg
using DrWatson
using DataFrames
using ProjectRoot
using Plots.PlotMeasures

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
  "sigma_e" => [0.1, 0.5, 1, 2],
  "method" => ["std", "var", "none"],
  "lambda" => [0.5, 0.9],
)
param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, sigma_e, method, lambda = d

  n = 100

  bias, var, mse = bias_simulation(q, sigma_e, method, n, lambda)

  d_exp = copy(d)
  d_exp["bias"] = bias
  d_exp["var"] = var
  d_exp["mse"] = mse

  push!(results, d_exp)
end

df = DataFrame(results);
df_long = stack(df, Not([:q, :sigma_e, :method, :lambda]))

n_rows = length(unique(df.method))
n_cols = length(unique(df.sigma_e))

df_subset = subset(df_long, :lambda => l -> l .== 0.9)

grouped_df = groupby(df_subset, [:variable])

plots = []

for (i, d) in enumerate(grouped_df)
  subgrouped_df = groupby(d, [:sigma_e])

  for (j, dd) in enumerate(subgrouped_df)
    ylab = if j == 1
      unique(d.variable)[1]
    else
      ""
    end

    title_stump = unique(dd.sigma_e)[1]

    title = if i == 1
      L"\sigma_e = %$(title_stump)"
    else
      ""
    end

    xlab = if i > 2
      L"q"
    else
      ""
    end

    legend = if i == 1 && j == 4
      true
    else
      false
    end

    pl = @df dd plot(
      :q,
      :value,
      groups = :method,
      ylabel = ylab,
      xlabel = xlab,
      title = title,
      legend = legend,
    )

    push!(plots, pl)
  end
end

# lab = reshape(unique(df.method), 1, 3)

# legend = plot([0 0 0], showaxis = false, grid = false, label = lab, left_margin = 0mm)

plotlist =
  plot(plots..., layout = (3, 4), size = (390, 350), left_margin = [10mm 1mm 1mm 1mm])

file_name = "maxabs_n"
file_path = @projectroot("paper", "plots", "bias-var-onedim.pdf")

savefig(plotlist, file_path)
