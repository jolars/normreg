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

df_grouped = groupby(df, [:dataset])

n_cols = length(df_grouped)

for (i, d) in enumerate(df_grouped)
  dataset = d[1, :dataset]

  dd = select(d, [:delta, :lambda, :err])
  dd_sorted = sort(dd, [:delta, :lambda])

  delta = dd_sorted.delta
  lambda = dd_sorted.lambda
  err = dd_sorted.err

  x = unique(lambda)
  y = unique(delta)

  z = permutedims(reshape(err, length(x), length(y)), [2, 1])

  legend = i == n_cols ? true : false

  yformatter = i == 1 ? :auto : _ -> ""

  colorbar_title = i == n_cols ? "NMSE" : ""

  xlab = i == ceil(Int32, n_cols / 2) ? L"\lambda" : ""
  ylab = i == 1 ? L"\delta" : ""

  pl = contourf(
    x,
    y,
    z,
    xlab = xlab,
    ylab = ylab,
    title = dataset,
    yformatter = yformatter,
    xscale = :log10,
    ylims = (0.0, 1.0),
    colorbar = true,
    colorbar_title = colorbar_title,
  )

  gdf = groupby(dd_sorted, :lambda)
  result = combine(gdf) do sdf
    sdf[argmin(sdf.err), :delta]
  end

  plot!(pl, result.lambda, result.x1, color = :lightgrey, linestyle = :dot)

  best_ind = argmin(err)

  best_delta, best_lambda = delta[best_ind], lambda[best_ind]

  scatter!(
    pl,
    [best_lambda],
    [best_delta],
    label = "Best",
    color = :white,
    xscale = :log10,
    legend = false,
  )

  push!(plots, pl)
end

l = (1, n_cols)

plot(plots..., layout = l, size = (FULL_WIDTH, 200))

savefig(@projectroot("paper", "plots", "hyperopt.pdf"))
