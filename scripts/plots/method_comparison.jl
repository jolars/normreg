using Plots
using StatsPlots
using LaTeXStrings
using DataFrames
using CSV
using Plots
using ProjectRoot
using NormReg

set_plot_defaults()

file = @projectroot("results", "method_comparison.csv")

df_raw = CSV.read(file, DataFrame)

df_lasso = subset(df_raw, :alpha => a -> a .== 1.0)
df_ridge = subset(df_raw, :alpha => a -> a .== 0.0)

function plot_comparison(df, type)
    # Sort by dataset, then method
    sort!(df, [:dataset, :method])

    xval = string.(df.dataset)
    groups = string.(df.method)

    n_xval = length(unique(xval))
    n_groups = length(unique(groups))

    yval = float.(reshape(df.err, n_groups, n_xval))
    yerr = float.(reshape(df.hi - df.err, n_groups, n_xval))

    ylims = type == "lasso" ? (0.0, 1.1) : (0.0, 1.7)

    return groupedbar(
        xval,
        yval,
        group = groups,
        yerr = yerr,
        ylims = ylims,
        size = (660, 300),
        legend = :outerright,
        ylab = "NMSE",
    )
end

plot_comparison(df_lasso, "lasso")
savefig(@projectroot("plots", "method_comparison_lasso.pdf"))

plot_comparison(df_ridge, "ridge")
savefig(@projectroot("plots", "method_comparison_ridge.pdf"))
