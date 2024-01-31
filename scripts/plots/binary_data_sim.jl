using DataFrames
using NormReg
using StatsBase
using StatsPlots
using JSON
using LaTeXStrings
using Plots
using Distributions
using ProjectRoot

using Statistics

function confidence_interval(x, level = 0.95)
  n = length(x)

  q = quantile(TDist(n - 1), 1 - level / 2)
  se = std(x) / sqrt(n)

  return (mean(x) - q * se, mean(x) + q * se)
end

function confidence_error(x, level = 0.95)
  n = length(x)

  q = quantile(TDist(n - 1), 1 - level / 2)
  se = std(x) / sqrt(n)

  return q * se
end

json = JSON.parsefile(@projectroot("data", "binary_data_sim.json"))

df = DataFrame(json)

df_subset = df

plots = []

groups = groupby(df_subset, [:q_type, :normalization], sort = true)

NormReg.setPlotSettings()

d = groups[1]

sublevels = groupby(d, [:normalization], sort = true)

avg_value = combine(groups, :err .=> [mean, confidence_error])

plot_output = @df avg_value groupedbar(
  :q_type,
  :err_mean,
  group = :normalization,
  yerror = :err_confidence_error,
  ylabel = "Mean-Squared Error",
  xlabel = "Class Balance of Signals",
  size = (450, 240),
)

file_path = @projectroot("paper", "plots", "binary_data_sim.pdf")
savefig(plot_output, file_path)
