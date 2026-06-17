# Poster variant of the noiseless lasso/ridge path figure (column 1).
# Reads the already-computed results and re-renders with the poster profile
# (Fira via pgf/lualatex, no grid, large fonts). Data is produced by
# scripts/experiments/small_path_experiment.jl.

using DataFrames
using JSON
using LaTeXStrings
using NormReg
using Plots
using ProjectRoot

set_plot_defaults(target = "poster")

json_data = JSON.parsefile(@projectroot("results", "small_path_experiment.json"))
df = DataFrame(json_data)

plots = []

normalization_types = unique(df.normalization)
alpha_types = unique(df.alpha)

n_cols = length(normalization_types)
n_rows = length(alpha_types)

labels = [L"\operatorname{Bernoulli}(0.5)" L"\operatorname{Bernoulli}(0.9)"]

for (i, alpha) in enumerate(alpha_types)
    d_alpha = filter(row -> row.alpha == alpha, df)

    for (j, normtype) in enumerate(normalization_types)
        d = filter(row -> row.normalization == normtype, d_alpha)

        betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))

        ylabel = alpha == 0 ? L"\hat{\beta}_j^\text{Ridge}" : L"\hat{\beta}_j^\text{Lasso}"

        ylabel = j == 1 ? ylabel : ""
        xlabel = j == 2 && i == 2 ? "Step" : ""

        yformatter = j == 1 ? :auto : _ -> ""
        xformatter = i == 2 ? :auto : _ -> ""

        legendposition = j == n_cols && i == 1 ? :outerright : :none

        normtype_label = normtype == "std" ? "Std." : normtype == "l1" ? "L1" : "Max–Abs"

        title = i == 1 ? normtype_label : ""

        pl = plot(
            betas,
            xlabel = xlabel,
            ylabel = ylabel,
            legendposition = legendposition,
            title = title,
            yformatter = yformatter,
            xformatter = xformatter,
            xticks = 0:50:100,
            labels = labels,
        )

        push!(plots, pl)
    end
end

pl = plot(
    plots...,
    layout = (n_rows, n_cols),
    size = (1000, 560),
)

out = @projectroot("posters", "icml2026", "figures", "small_path_experiment.pdf")
mkpath(dirname(out))
save_poster(pl, out)
println("wrote ", out)
