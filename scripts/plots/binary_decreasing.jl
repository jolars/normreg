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

NormReg.setPlotSettings("pyplot");

json = JSON.parsefile(@projectroot("data", "binary_data_sim.json"));

df = DataFrame(json);

df_subset = subset(df, :q_type .=> q -> q .== "decreasing");

groups = groupby(df_subset, [:normalization], sort = true)

plots = []

for (i, d) in enumerate(groups)
  b = d.betas
  res = dropdims(mapreduce(permutedims, hcat, b), dims = 1)
  out = Float64.(mapreduce(permutedims, vcat, res))[:, 1:40]
  pl = boxplot(
    1:size(out, 1),
    out,
    fillcolor = :lightgrey,
    markercolor = :black,
    markersize = 1,
    legend = false,
    xformatter = i == length(groups) ? :auto : _ -> "",
  )
  title!(pl, d.normalization[1], ylims = (-0.5, 2))
  ylabel!(pl, L"\hat\beta")

  if i == length(groups)
    xlabel!(pl, "Feature Index")
  end

  push!(plots, pl)
end

plots = plot(plots..., layout = (4, 1), size = (450, 400))

file_path = @projectroot("paper", "plots", "binary_decreasing.pdf")
savefig(plots, file_path)
