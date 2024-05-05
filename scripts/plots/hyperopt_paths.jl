using Plots
using StatsPlots
using LaTeXStrings
using DataFrames
using CSV
using Plots
using ProjectRoot
using NormReg

set_plot_defaults()

colors = [:black delta_palette([1, 3, 4])]
linestyles = [:dash :solid :solid :solid]

file = @projectroot("data", "hyperopt.csv")

df = CSV.read(file, DataFrame);

plots = []

df_grouped = groupby(subset(df, :alpha => a -> a .== 1), [:dataset]);

n_rows = 2
n_cols = length(df_grouped)

for (i, d) in enumerate(df_grouped)
  dataset = d[1, :dataset]

  dd = select(d, [:delta, :lambda, :support_size, :err])
  dd_sorted = sort(dd, [:delta, :lambda])

  delta = dd_sorted.delta
  lambda = dd_sorted.lambda
  support_size = dd_sorted.support_size

  gdf = groupby(dd_sorted, :lambda)
  result = combine(gdf) do sdf
    sdf[argmin(sdf.err), [:support_size, :err, :delta]]
  end

  result_0 = combine(gdf) do sdf
    sdf[sdf.delta .== 0, [:support_size, :err, :delta]]
  end

  minind = argmin(abs.(unique(result.delta) .- 0.5))
  delta_05 = unique(result.delta)[minind]

  result_05 = combine(gdf) do sdf
    sdf[sdf.delta .== delta_05, [:support_size, :err]]
  end

  result_1 = combine(gdf) do sdf
    sdf[sdf.delta .== 1, [:support_size, :err]]
  end

  ylab = i == 1 ? "Support Size" : ""

  pl = plot(
    result.lambda,
    [result.support_size result_0.support_size result_05.support_size result_1.support_size],
    xscale = :log10,
    ylab = ylab,
    linetype = :steppre,
    title = dataset,
    xformatter = _ -> "",
    legend = false,
    color = colors,
    linestyle = linestyles,
  )

  optim = result[argmin(result.err), [:lambda, :err]]

  vline!(pl, [optim.lambda], linestyle = :dot, color = :grey)

  push!(plots, pl)

  ylab = i == 1 ? "NMSE" : ""

  xlab = i == ceil(Int32, n_cols / 2) ? L"\lambda/\lambda_{\text{max}}" : ""

  pl2 = plot(
    result.lambda,
    [result.err result_0.err result_05.err result_1.err],
    xscale = :log10,
    ylab = ylab,
    xlab = xlab,
    legendposition = i == 1 ? :topleft : :none,
    labels = ["Optimal" "0" "0.5" "1"],
    legend_title = L"\delta",
    legend_background_color = :transparent,
    color = colors,
    linestyle = linestyles,
  )

  optim = result[argmin(result.err), [:lambda, :err]]

  scatter!(pl2, [optim.lambda], [optim.err], color = :white)

  push!(plots, pl2)
end

l = (n_rows, n_cols)

plots = permutedims(reshape(plots, n_rows, n_cols), [2, 1])

plot(plots..., layout = l, size = (FULL_WIDTH, 320))

savefig(@projectroot("paper", "plots", "hyperopt_paths.pdf"))
