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
df_grouped = groupby(df, [:delta], sort = true);

n_rows = length(unique(df.delta))
n_cols = length(unique(df.rho))

plots = []

for (i, df_group) in enumerate(df_grouped)
  df_subgrouped = groupby(df_group, [:rho], sort = true)

  for (j, d) in enumerate(df_subgrouped)
    b = d.betas
    res = dropdims(mapreduce(permutedims, hcat, b), dims = 1)
    out = Float64.(mapreduce(permutedims, vcat, res))[:, 1:30]

    xvar = 1:size(out, 2)
    yvar = mean(out, dims = 1)'
    yerror = std(out, dims = 1)'

    rho = d.rho[1]
    delta = d.delta[1]

    title = i == 1 ? L"\rho = %$(rho)" : ""

    yformatter = j == 1 ? :auto : _ -> ""
    xformatter = i == n_rows ? :auto : _ -> ""

    xlabel = i == n_rows && j == 2 ? "Feature Index" : ""

    ylabel = if j == 1
      L"\hat\beta"
    elseif j == n_cols
      L"\delta = %$(delta)"
    else
      ""
    end

    yguideposition = if j == n_cols
      :right
    else
      :left
    end

    pl = scatter(
      xvar,
      yvar;
      legend = false,
      markercolor = :black,
      markersize = 2,
      title = title,
      xformatter = xformatter,
      xlabel = xlabel,
      yformatter = yformatter,
      ylabel = ylabel,
      ylims = (-0.5, 2),
      yguideposition = yguideposition,
    )

    yerror!(1:size(out, 2), yvar; yerror = yerror, markercolor = :transparent)

    push!(plots, pl)
  end
end

layout = (n_rows, n_cols)

plots = plot(plots..., layout = layout, size = (FULL_WIDTH, 350))

file_path = @projectroot("paper", "plots", "binary_decreasing.pdf")
savefig(plots, file_path)
