using Distributions
using DataFrames
using DrWatson
using StatsBase
using ProjectRoot
using Plots
using StatsPlots
using LaTeXStrings
using NormReg

function binary_selection_prob(β, n, q, delta, lambda, σe)
  X = Normal()

  s = (q - q^2)^delta

  lambda = lambda / (0.5 - 0.5^2)^delta

  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)

  prob = cdf(X, (μ - lambda) / σ) + cdf(X, (-μ - lambda) / σ)

  return prob, lambda
end

function sim_binary_selection(q, delta, lambda, sigma_e)
  beta = 1
  n = 100

  lambda = n * lambda

  prob, lambda = binary_selection_prob(beta, n, q, delta, lambda, sigma_e)

  return prob, lambda
end

set_plot_defaults()


param_dict = Dict{String,Any}(
  "q" => collect(0.5:0.001:0.999),
  "delta" => [0, 1 / 4, 1 / 2, 1.0, 1.5],
  "lambda" => [0.002],
  "sigma_e" => [0.25, 0.5, 2, 4],
)
param_expanded = dict_list(param_dict);

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, delta, lambda, sigma_e = d

  n = 100
  lambda = n * lambda

  prob, lambda = sim_binary_selection(q, delta, lambda, sigma_e)

  d_exp = copy(d)
  d_exp["prob"] = prob
  d_exp["lambda"] = lambda

  push!(results, d_exp)
end

df = DataFrame(results);

n_delta = length(unique(df.delta))
n_sigma = length(unique(df.sigma_e))

plots = []

pal = :Johnson

subgrouped_df = groupby(df, [:sigma_e])

for (j, dd) in enumerate(subgrouped_df)
  sort!(dd, [:delta])

  ylab = if j == 1
    L"\Pr\big(\hat\beta \neq 0\big)"
  else
    ""
  end

  title_stump = unique(dd.sigma_e)[1]

  # xlab = if i > 2
  #   L"q"
  # else
  #   ""
  # end
  
  yformatter = j == 1 ? :auto : _ -> ""

  legend = j == n_sigma ? :outerright : nothing

  # Plot asymptotic limit for standardization case
  β = 1
  n = 100
  σe = unique(dd.sigma_e)[1]
  std_group = subset(dd, :delta => d -> d .== 0.5)
  λ = unique(std_group.lambda)[1]
  lev = 2 * cdf(Normal(), -λ / (σe * sqrt(n)))

  pl = @df dd plot(
    :q,
    :prob,
    groups = :delta,
    legend_title = L"\delta",
    palette = pal,
    title = L"\sigma_e = %$(title_stump)",
    legend = legend,
    xlabel = L"q",
    yformatter = yformatter,
    ylabel = ylab,
    ylims = (-0.05, 1.05),
    xticks = 0.5:0.15:0.95,
  )

  hline!(
    pl,
    [lev],
    linestyle = :dot,
    linecolor = :black,
    z_order = :back,
  )

  push!(plots, pl)
end

plot_output = plot(plots..., layout = (1, n_sigma), size = (550,190))

file_path = @projectroot("paper", "plots", "selection_probability.pdf")
savefig(plot_output, file_path)
