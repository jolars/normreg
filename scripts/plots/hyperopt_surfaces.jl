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

df_alpha = groupby(df, [:alpha])

n_cols = length(unique(df.dataset))
n_rows = length(df_alpha)

palette = :viridis

for (j, d_alpha) in enumerate(df_alpha)
  df_dataset = groupby(d_alpha, [:dataset])

  for (i, d) in enumerate(df_dataset)
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

    xformatter = j == n_rows ? :auto : _ -> ""

    colorbar_title = i == n_cols ? "NMSE" : ""

    xlab =
      j == n_rows && i == ceil(Int32, n_cols / 2) ? L"\lambda/\lambda_{\text{max}}" : ""

    model = d[1, :alpha] == 1.0 ? "Lasso\n" : "Ridge\n"

    ylab = i == 1 ? L"%$(model)$\delta$" : ""

    title = j == 1 ? dataset : ""

    pl = contourf(
      x,
      y,
      z,
      xlab = xlab,
      ylab = ylab,
      title = title,
      yformatter = yformatter,
      xformatter = xformatter,
      xscale = :log10,
      ylims = (0.0, 1.0),
      xlims = (1e-4, 1),
      xticks = [1e-4, 1e-2, 1],
      grid = false,
      colorbar = true,
      colorbar_title = colorbar_title,
      c = palette,
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
end

l = (n_rows, n_cols)

plot_output = plot(plots..., layout = l, size = (FULL_WIDTH, 300))

savefig(@projectroot("paper", "plots", "hyperopt_surfaces.pdf"))

# plot_talk = plot(plots..., layout = l, size = (FULL_WIDTH, 300))
#
# savefig(@projectroot("paper", "plots", "hyperopt_surfaces.pdf"))
