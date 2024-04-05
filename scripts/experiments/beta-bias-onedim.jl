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

set_plot_defaults()

function onedim_bias_sim(q::Real, σe::Real, δ::Real, n::Int64, λ::Real = 0.5)
  Random.seed!(852)

  β = 2

  s = (q - q^2)^δ

  λ = λ / (0.5 - 0.5^2)^δ

  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)

  d = binary_d(n, q, s, λ)

  θ = -(μ + λ)
  γ = μ - λ

  eβ = binary_expected_value(θ, γ, σ, d, print_components = false)
  v = binary_variance(θ, γ, σ, d)

  bias = eβ - β
  mse = bias^2 + v

  return bias, v, mse, λ
end

param_dict = Dict{String,Any}(
  "q" => collect(0.5:0.001:0.999),
  "sigma_e" => [0.25, 0.5, 1, 2],
  "delta" => [0, 1 / 4, 1 / 2, 1.0, 1.5],
  "lambda" => [0.2],
)
param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, sigma_e, delta, lambda = d

  n = 100
  lambda = n * lambda

  bias, v, mse, λ = onedim_bias_sim(q, sigma_e, delta, n, lambda)

  d_exp = copy(d)
  d_exp["bias"] = bias
  d_exp["var"] = v
  d_exp["mse"] = mse
  d_exp["lambda"] = λ

  push!(results, d_exp)
end

df = DataFrame(results);
df_long = stack(df, Not([:q, :sigma_e, :delta, :lambda]));

n_delta = length(unique(df.delta))
n_sigma = length(unique(df.sigma_e))

grouped_df = groupby(df_long, [:variable]);

plots = []

pal = :Johnson

variable_map = Dict("mse" => "MSE", "bias" => "Bias", "var" => "Variance")

for (i, d) in enumerate(grouped_df)
  subgrouped_df = groupby(d, [:sigma_e])

  for (j, dd) in enumerate(subgrouped_df)
    sort!(dd, [:delta])

    variable = d.variable[1]

    ylab = if j == 1
      variable_map[variable]
    else
      ""
    end

    title = if i == 1
      title_stump = dd.sigma_e[1]
      L"\sigma_e = %$(title_stump)"
    else
      ""
    end

    xlab = if i > 2
      L"q"
    else
      ""
    end

    xformatter = if i > 2
      x -> round(x, digits = 2)
    else
      x -> ""
    end

    ylims = variable == "var" ? (-0.02, 0.4) : variable == "mse" ? (-0.2, 4.5) : :auto

    yformatter = j == 1 ? :auto : _ -> ""

    pl = @df dd plot(
      :q,
      :value,
      groups = :delta,
      ylabel = ylab,
      xlabel = xlab,
      ylims = ylims,
      xlims = (0.45, 1.05),
      xformatter = xformatter,
      yformatter = yformatter,
      xticks = 0.5:0.25:1,
      title = title,
      legend = false,
      palette = pal,
    )

    # Plot asymptotic limit for standardization case
    if i == 2
      β = 2
      n = 100
      σe = dd.sigma_e[1]
      std_group = subset(dd, :delta => d -> d .== 0.5)
      λ = unique(std_group.lambda)[1]
      lev = 2 * β * cdf(Normal(), -λ / (σe * sqrt(n))) - β
      hline!(pl, [lev], linestyle = :dot, linecolor = :black)
    end

    push!(plots, pl)
  end
end

lab = reshape(sort(unique(df.delta)), 1, n_delta)

legendvals = collect(zeros(n_delta)')

legend = plot(
  legendvals,
  showaxis = false,
  grid = false,
  label = lab,
  legend_position = :topleft,
  legend_title = L"\delta",
  palette = pal,
)

l = @layout[grid(3, n_sigma) a{0.11w}]

plotlist = plot(plots..., legend, layout = l, size = (FULL_WIDTH, 400))

file_path = @projectroot("paper", "plots", "bias-var-onedim.pdf")

savefig(plotlist, file_path)
