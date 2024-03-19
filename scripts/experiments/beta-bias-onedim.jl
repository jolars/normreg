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

  β = 1

  s = (q - q^2)^δ

  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)

  d = binary_d(n, q, s, λ)

  θ = -(μ + λ)
  γ = μ - λ

  eβ = binary_expected_value(θ, γ, σ, d, print_components = false)
  v = binary_variance(θ, γ, σ, d)

  # std_level = 2 * β * λ * pdf(Normal(), λ / (σe * sqrt(n))) / (σe * sqrt(n))
  std_level = 2 * β * cdf(Normal(), -β * sqrt(n) / σe)
  

  bias = eβ - β
  mse = bias^2 + v

  return bias, v, mse
end

param_dict = Dict{String,Any}(
  "q" => collect(0.5:0.01:0.99),
  "sigma_e" => [0.1, 0.5, 1, 4],
  "delta" => [0, 1/4, 1/2, 1, 2],
  "lambda" => [0.2],
)
param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, sigma_e, delta, lambda = d

  n = 100
  lambda = n * lambda

  bias, var, mse = onedim_bias_sim(q, sigma_e, delta, n, lambda)

  d_exp = copy(d)
  d_exp["bias"] = bias
  d_exp["var"] = var
  d_exp["mse"] = mse

  push!(results, d_exp)
end

df = DataFrame(results);
df_long = stack(df, Not([:q, :sigma_e, :delta, :lambda]))

n_delta = length(unique(df.delta))
n_sigma = length(unique(df.sigma_e))

grouped_df = groupby(df_long, [:variable])

plots = []

pal = :Johnson

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

    xformatter = if i > 2
      x -> round(x, digits = 2)
    else
      x -> ""
    end

    pl = plot(xlims = (0.45, 1.05))

    if i == 2
      β = 1
      n = 100
      σe = unique(dd.sigma_e)[1]
      λ = 0.2 * n
      lev = 2 * β * cdf(Normal(), -λ / (σe * sqrt(n))) - β
      println("lev:", lev)
      hline!(pl, [lev], linestyle = :dot, linecolor = :black)
    end

    @df dd plot!(
      pl,
      :q,
      :value,
      groups = :delta,
      ylabel = ylab,
      xlabel = xlab,
      xformatter = xformatter,
      xticks = 0.5:0.25:1,
      title = title,
      legend = false,
      palette=pal,
    )

    push!(plots, pl)
  end
end

lab = reshape(sort(unique(df.delta)), 1, n_delta)

legendvals = collect(zeros(n_delta)')

legend =
  plot(
    legendvals,
    showaxis = false,
    grid = false,
    label = lab,
    legend_position = :topleft,
    legend_title = L"\delta",
    palette=pal,
  )

l = @layout[grid(3, n_sigma) a{0.15w}]

plotlist = plot(plots..., legend, layout = l, size = (575, 400))

file_path = @projectroot("paper", "plots", "bias-var-onedim.pdf")

savefig(plotlist, file_path)
