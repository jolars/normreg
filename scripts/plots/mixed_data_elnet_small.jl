using ColorSchemes
using DataFrames
using JSON
using LaTeXStrings
using NormReg
using PlotThemes
using Plots
using ProjectRoot
using Plots.PlotMeasures

set_plot_defaults()

json_data = JSON.parsefile(@projectroot("results", "mixed_data.json"));
df = DataFrame(json_data);
df_subset = subset(df, :alpha => a -> a .== 0.5);

n_rows = 1
n_cols = length(unique(df_subset.delta))
n_groups = 2

plots = []

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)"]

dd = df_subset
groups = groupby(dd, :delta, sort = true)
for (i, d) in enumerate(groups)
    alpha = d.alpha[1]

    yguide = i == 1 ? L"\hat{\beta}_j" : ""

    yformatter = i == 1 ? :auto : _ -> ""

    xformatter = x -> round(x, digits = 2)

    omega = d.delta[1]

    title = L"\omega = %$(omega)"

    xlabel = i == 2 ? L"q" : ""

    betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))
    yerr = Float64.(mapreduce(permutedims, vcat, d.betas_std[1]))

    pl = plot(
        d.qs[1],
        betas,
        yguide = yguide,
        ribbon = yerr,
        yformatter = yformatter,
        xformatter = xformatter,
        xlabel = xlabel,
        title = title,
        xticks = 0.5:0.2:0.9,
        ylim = (-0.1, 1.1),
        legendposition = :none,
        # legendposition = i == 2 ? :top : :none,
        # legend_background_color = :white,
        legendcolumns = 1,
        labels = labels,
    )

    push!(plots, pl)
end

l = (n_rows, n_cols)

labvals = zeros(1, length(labels))
legend = plot(
    labvals,
    showaxis = false,
    grid = false,
    label = labels,
    ribbon = 1,
    legend_position = :top,
    frametitle = :none,
    background_color_subplot = :transparent,
    legendcolumns = -1,
)

l = @layout[a{0.18h}; grid(n_rows, n_cols)]

pl = plot(
    legend,
    plots...,
    layout = l,
    size = (320, 160),
)

file_path = @projectroot("plots", "mixed_data_elnet_small.pdf");

savefig(pl, file_path)
