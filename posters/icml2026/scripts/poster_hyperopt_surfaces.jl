# Poster variant of the hyperparameter-optimization surfaces (column 3).
# Lasso only, across three real datasets, rendered with the poster profile.
# Each panel is the hold-out NMSE over (lambda, delta); the white dot marks the
# tuned optimum and the dotted line the best delta at each lambda. Shows that the
# optimal delta is interior and differs by dataset -- motivating tuning delta.
# Data is produced by scripts/experiments/hyperopt.jl.

using CSV
using DataFrames
using LaTeXStrings
using NormReg
using Plots
using Plots.Measures
using ProjectRoot
using StatsPlots

set_plot_defaults(target = "poster")

df = CSV.read(@projectroot("results", "hyperopt.csv"), DataFrame)
df = subset(df, :alpha => a -> a .== 1.0)   # lasso

df_dataset = groupby(df, [:dataset])
n_cols = length(df_dataset)

palette = :viridis

plots = []

for (i, d) in enumerate(df_dataset)
    dataset = d[1, :dataset]

    dd_sorted = sort(select(d, [:delta, :lambda, :err]), [:delta, :lambda])

    delta = dd_sorted.delta
    lambda = dd_sorted.lambda
    err = dd_sorted.err

    x = unique(lambda)
    y = unique(delta)
    z = permutedims(reshape(err, length(x), length(y)), [2, 1])

    ylab = i == 1 ? L"\delta" : ""
    yformatter = i == 1 ? :auto : _ -> ""
    xlab = i == ceil(Int, n_cols / 2) ? L"\lambda/\lambda_{\text{max}}" : ""
    # label NMSE only on the last colorbar (as in the paper), not all three
    colorbar_title = i == n_cols ? "NMSE" : ""

    pl = StatsPlots.contourf(
        x,
        y,
        z,
        xlab = xlab,
        ylab = ylab,
        title = dataset,
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

    # best delta at each lambda
    gdf = groupby(dd_sorted, :lambda)
    result = combine(gdf) do sdf
        sdf[argmin(sdf.err), :delta]
    end
    plot!(pl, result.lambda, result.x1, color = :lightgrey, linestyle = :dot)

    # tuned optimum
    best_ind = argmin(err)
    scatter!(
        pl,
        [lambda[best_ind]],
        [delta[best_ind]],
        color = :white,
        xscale = :log10,
        legend = false,
    )

    push!(plots, pl)
end

pl = plot(plots..., layout = (1, n_cols), size = (900, 320))

out = @projectroot("posters", "icml2026", "figures", "hyperopt_surfaces.pdf")
mkpath(dirname(out))
save_poster(pl, out)
println("wrote ", out)
