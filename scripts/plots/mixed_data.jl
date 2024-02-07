using DataFrames
using JSON
using LaTeXStrings
using NormReg
using Plots
using ProjectRoot
using StatsBase
using StatsPlots

set_plot_defaults();

json_data = JSON.parsefile(@projectroot("data", "mixed_data.json"));
df = DataFrame(json_data);

groups = groupby(df, [:normalization], sort = true)

plots = []

for (i, d) in enumerate(groups)
  b_est = dropdims(mapreduce(permutedims, hcat, d.betas_est), dims = 1)
  b_true = d.betas_true[1][1:20]
  b_est_subset = Float64.(mapreduce(permutedims, vcat, b_est))[:, 1:40]

  n = size(b_est_subset, 1)

  type = vcat(fill("Normal", 10), fill("Binary", 10), fill("Noise", 20))
  types = repeat(type, inner = n)
  tmp = stack(DataFrame(b_est_subset, string.(1:40)))

  tmp.x_type = types
  tmp.variable = parse.(Int8, tmp.variable)

  pl = @df tmp boxplot(
    :variable,
    :value,
    group = :x_type,
    fillcolor = [:orange :white :lightgrey],
    markercolor = :black,
    markersize = 1,
    legend = i == 1 ? :topright : false,
    legend_column = 4,
    xformatter = i == length(groups) ? :auto : _ -> "",
  )

  plot!(pl, 1:20, b_true, color = :black, linestyle = :dot, label = L"\beta^*")

  title!(pl, d.normalization[1], ylims = (-0.5, 2))
  ylabel!(pl, L"\hat\beta")

  if i == length(groups)
    xlabel!(pl, "Feature Index")
  end

  push!(plots, pl)
end

plots = plot(plots..., layout = (3, 1), size = (450, 400))

file_path = @projectroot("paper", "plots", "mixed_data.pdf")
savefig(plots, file_path)
