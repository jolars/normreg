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

file = @projectroot("results", "hyperopt.csv")

df = CSV.read(file, DataFrame)

plots = []

df = subset(df, :alpha => a -> a .== 0.0)

df_dataset = groupby(df, [:dataset])

n_cols = length(unique(df.alpha))
n_rows = length(df_dataset)

palette = :viridis

for (j, d) in enumerate(df_dataset)
    dataset = d[1, :dataset]

    dd = select(d, [:delta, :lambda, :err])
    dd_sorted = sort(dd, [:delta, :lambda])

    delta = dd_sorted.delta
    lambda = dd_sorted.lambda
    err = dd_sorted.err

    x = unique(lambda)
    y = unique(delta)

    z = permutedims(reshape(err, length(x), length(y)), [2, 1])

    yformatter = j == 1 ? :auto : _ -> ""

    colorbar_title = j == 3 ? "NMSE" : ""

    xlab = j == 2 ? L"\lambda/\lambda_{\text{max}}" : ""

    title = dataset

    ylab = j == 1 ? L"\delta" : ""

    pl = StatsPlots.contourf(
        x,
        y,
        z,
        xlab = xlab,
        ylab = ylab,
        title = title,
        yformatter = yformatter,
        xscale = :log10,
        ylims = (0.0, 1.0),
        xlims = (1.0e-4, 1),
        xticks = [1.0e-4, 1.0e-2, 1],
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

plot_output =
    plot(plots..., layout = (1, 3), right_margin = [-6mm -6mm -5mm], size = (320, 130))

savefig(@projectroot("plots", "hyperopt_surfaces_small.pdf"))
