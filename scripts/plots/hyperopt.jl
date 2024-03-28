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

n_plots = length(df_grouped)

for (i, d) in enumerate(df_grouped)
  dataset = d[1, :dataset]

  dd = select(d, [:delta, :lambda, :err])
  dd_sorted = sort(dd, [:delta, :lambda])

  delta = dd_sorted.delta
  lambda = dd_sorted.lambda
  err = dd_sorted.err

  x = unique(lambda)
  y = unique(delta)

  # z = Matrix(unstack(dd, :delta, :lambda, :err))

  z = reshape(err, length(x), length(y))

  legend = i == n_plots ? true : false

  yformatter = i == 1 ? :auto : _ -> ""

  xlab = i == ceil(Int32, n_plots / 2) ? L"\lambda" : ""
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
    legend = true,
  )

  push!(plots, pl)
end

l = (1, 3)

plot(plots..., layout = l, size = (FULL_WIDTH, 200))
