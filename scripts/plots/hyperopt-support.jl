using Plots
using StatsPlots
using LaTeXStrings
using CSV
using Plots
using ProjectRoot

set_plot_defaults()

file = @projectroot("data", "hyperopt.csv")

df = CSV.read(file, DataFrame)

plots = []

df_grouped = groupby(subset(df, :alpha => a -> a .== 1), [:dataset])

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
    sdf[argmin(sdf.err), [:support_size, :err]]
  end

  ylab = i == 1 ? "Support size" : ""

  pl = plot(
    result.lambda,
    result.support_size,
    xscale = :log10,
    ylab = ylab,
    linetype = :steppre,
    color = :black,
    title = dataset,
    xformatter = _ -> "",
  )

  optim = result[argmin(result.err), [:lambda, :err]]

  vline!(pl, [optim.lambda], linestyle = :dot, color = :darkorange)

  push!(plots, pl)

  ylab = i == 1 ? "NMSE" : ""

  xlab = i == ceil(Int32, n_cols / 2) ? L"\lambda" : ""

  pl = plot(
    result.lambda,
    result.err,
    xscale = :log10,
    ylab = ylab,
    color = :black,
    xlab = xlab,
  )

  optim = result[argmin(result.err), [:lambda, :err]]

  scatter!(pl, [optim.lambda], [optim.err], color = :darkorange)

  push!(plots, pl)
end

l = (2, n_cols)

plots = permutedims(reshape(plots, 2, n_cols), [2, 1])

plot(plots..., layout = l, size = (FULL_WIDTH, 280))

savefig(@projectroot("paper", "plots", "hyperopt-support.pdf"))
