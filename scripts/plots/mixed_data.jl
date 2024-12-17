using ColorSchemes
using DataFrames
using JSON
using LaTeXStrings
using NormReg
using PlotThemes
using Plots
using ProjectRoot
using Plots.PlotMeasures

using PythonPlot: matplotlib

set_plot_defaults()

json_data = JSON.parsefile(@projectroot("data", "mixed_data.json"));
df = DataFrame(json_data);
df_subset = subset(df, :alpha => a -> a .== 1.0 .|| a .== 0.0);

df_grouped = (groupby(df_subset, [:alpha], sort = true));

n_rows = length(unique(df_subset.alpha))
n_cols = length(unique(df_subset.delta))
n_groups = 2

plots = []

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)"]

for (j, dd) in enumerate(df_grouped)
  groups = groupby(dd, :delta, sort = true)
  for (i, d) in enumerate(groups)
    alpha = d.alpha[1]
    model = alpha == 1 ? "Lasso" : "Ridge"

    yguide = i == 1 ? L"\hat{\beta}_j^\text{%$(model)}" : ""

    yformatter = i == 1 ? :auto : _ -> ""

    xformatter = if j == n_rows
      x -> round(x, digits = 2)
    else
      x -> ""
    end

    delta = d.delta[1]

    title = if j == 1
      L"\delta = %$(delta)"
    else
      ""
    end

    xlabel = j == n_rows && i == 2 ? L"q" : ""

    betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))
    yerr = Float64.(mapreduce(permutedims, vcat, d.betas_std[1]))

    pl = plot(
      d.qs[1],
      betas,
      yguide = yguide,
      ribbon = yerr,
      yformatter = yformatter,
      xformatter = xformatter,
      xlabel = xlabel,
      title = title,
      xticks = 0.5:0.2:0.9,
      ylim = (-0.1, 1.1),
      legendposition = j == 2 && i == 2 ? :outertop : :none,
      legend_columns = 2,
      labels = labels,
    )

    push!(plots, pl)
  end
end

l = (n_rows, n_cols)

pl = plot(
  plots...,
  layout = l,
  size = (320, 250),
  left_margin = [0mm 2mm 2mm],
  bottom_margin = 1mm,
)

file_path = @projectroot("paper", "plots", "mixed_data.pdf");

savefig(pl, file_path)
