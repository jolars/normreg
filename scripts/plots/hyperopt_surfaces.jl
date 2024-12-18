using Plots
using StatsPlots
using LaTeXStrings
using DataFrames
using NormReg
using CSV
using Plots
using ProjectRoot
using Plots.Measures

set_plot_defaults()

file = @projectroot("data", "hyperopt.csv")

df = CSV.read(file, DataFrame)

function plot_hyperopt_surface(df, datasets = ["a1a", "w1a", "rhee2006"])
  plots = []

  df = subset(df, :dataset => d -> d .∈ Ref(datasets))

  df_dataset = groupby(df, [:dataset])

  n_cols = length(unique(df.alpha))
  n_rows = length(df_dataset)

  palette = :viridis

  for (j, d) in enumerate(df_dataset)
    df_alpha = groupby(d, [:alpha])
    for (i, d) in enumerate(df_alpha)
      dataset = d[1, :dataset] * "\n"

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
        j == n_rows && ((n_cols % 2 == 0) || (i == ceil(Int, n_cols / 2))) ?
        L"\lambda/\lambda_{\text{max}}" : ""

      model = d[1, :alpha] == 1.0 ? "Lasso" : "Ridge"
      title = j == 1 ? model : ""

      ylab = i == 1 ? L"%$(dataset)$\delta$" : ""

      pl = StatsPlots.contourf(
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

  return plots
end

plots = plot_hyperopt_surface(df)
plot_output = plot(
  plots...,
  layout = (3, 2),
  right_margin = [-6mm -5mm],
  top_margin = 1mm,
  size = (315, 340),
)
savefig(@projectroot("paper", "plots", "hyperopt_surfaces.pdf"))
