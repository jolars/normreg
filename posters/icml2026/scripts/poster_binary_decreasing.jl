# Poster figure (column 3): the class-balance effect beyond the orthogonal
# theory. A high-dimensional, noisy simulation (p = 1000) where 20 true signals
# have class balance rising from 0.5 to 0.99. Under no scaling (delta = 0) the
# most imbalanced signals are shrunk to zero; variance scaling (delta = 1)
# recovers them. Compact two-panel (delta = 0 vs delta = 1) version of the
# paper's binary_decreasing figure. Data: scripts/experiments/binary_decreasing*.

using DataFrames
using JSON
using LaTeXStrings
using NormReg
using Plots
using StatsBase
using StatsPlots
using ProjectRoot

set_plot_defaults(target = "poster")

json_data = JSON.parsefile(@projectroot("results", "binary_data_decreasing.json"))
df = DataFrame(json_data)
df_subset = subset(df, :rho => r -> r .== 0.0, :delta => d -> d .∈ Ref([0.0, 1.0]))
df_grouped = groupby(df_subset, [:delta], sort = true)

n_cols = length(unique(df_subset.delta))
plots = []

for (i, d) in enumerate(df_grouped)
    b = d.betas
    res = dropdims(mapreduce(permutedims, hcat, b), dims = 1)
    out = Float64.(mapreduce(permutedims, vcat, res))[:, 1:30]

    xvar = 1:size(out, 2)
    yvar = vec(mean(out, dims = 1))
    yerr = vec(std(out, dims = 1))

    delta = d.delta[1]

    yformatter = i == 1 ? :auto : _ -> ""
    ylabel = i == 1 ? L"\hat\beta" : ""

    # error bars (grey) with invisible markers, then the means as black dots
    pl = scatter(
        xvar,
        yvar;
        yerror = yerr,
        legend = false,
        markersize = 0,
        markercolor = :transparent,
        linecolor = :grey,
        markerstrokecolor = :grey,
        title = L"\delta = %$(delta)",
        xlabel = "Feature Index",
        ylabel = ylabel,
        yformatter = yformatter,
        ylims = (-0.5, 2),
    )
    scatter!(pl, xvar, yvar; markercolor = :black, markersize = 3, markerstrokecolor = :black)

    push!(plots, pl)
end

pl = plot(plots..., layout = (1, n_cols), size = (760, 360))

out = @projectroot("posters", "icml2026", "figures", "binary_decreasing.pdf")
mkpath(dirname(out))
save_poster(pl, out)
println("wrote ", out)
