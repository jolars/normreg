using DataFrames
using NormReg
using StatsBase
using StatsPlots
using JSON
using LaTeXStrings
using Plots
using Distributions
using ProjectRoot

set_plot_defaults();

json_data = JSON.parsefile(@projectroot("data", "binary_data_decreasing.json"));
df = DataFrame(json_data);
groups = groupby(df, [:normalization], sort = true);

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

plots = plot(plots..., layout = (3, 1), size = (450, 350))

file_path = @projectroot("paper", "plots", "binary_decreasing.pdf")
savefig(plots, file_path)
