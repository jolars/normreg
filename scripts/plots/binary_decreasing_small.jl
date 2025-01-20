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

json_data = JSON.parsefile(@projectroot("results", "binary_data_decreasing.json"));
df = DataFrame(json_data);
df_subset = subset(df, :rho => rho -> rho .== 0.5, :delta => d -> d .∈ Ref([0.0, 1.0]))
df_grouped = groupby(df_subset, [:delta], sort = true)

n_rows = 1
n_cols = length(unique(df_subset.delta))

plots = []

for (i, df_group) in enumerate(df_grouped)
  d = df_group

  b = d.betas
  res = dropdims(mapreduce(permutedims, hcat, b), dims = 1)
  out = Float64.(mapreduce(permutedims, vcat, res))[:, 1:30]

  xvar = 1:size(out, 2)
  yvar = mean(out, dims = 1)'
  yerror = std(out, dims = 1)'

  rho = d.rho[1]
  delta = d.delta[1]

  title = L"\delta = %$(delta)"

  yformatter = i == 1 ? :auto : _ -> ""
  xformatter = :auto

  xlabel = "Feature Index"

  ylabel = if i == 1
    L"\hat\beta"
  else
    ""
  end

  yguideposition = if i == n_cols
    :right
  else
    :left
  end

  pl = scatter(
    xvar,
    yvar;
    legend = false,
    markercolor = :transparent,
    markersize = 0,
    title = title,
    xformatter = xformatter,
    xlabel = xlabel,
    yformatter = yformatter,
    ylabel = ylabel,
    ylims = (-0.5, 2),
    yguideposition = yguideposition,
  )

  yerror!(
    1:size(out, 2),
    yvar;
    yerror = yerror,
    markercolor = :transparent,
    markerstrokecolor = :grey,
  )

  scatter!(1:size(out, 2), yvar; markercolor = :black, markersize = 2)

  push!(plots, pl)
end

layout = (n_rows, n_cols)

fig_width = 320
fig_height = 140
plots = plot(plots..., layout = layout, size = (fig_width, fig_height))

file_path = @projectroot("plots", "binary_decreasing_small.pdf")
savefig(plots, file_path)
