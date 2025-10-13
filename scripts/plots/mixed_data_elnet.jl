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
df_subset = subset(df, :alpha => a -> a .∈ Ref([0.25, 0.5, 0.75]));
df_grouped = (groupby(df_subset, [:alpha], sort = true));

n_rows = length(unique(df_subset.alpha))
n_cols = length(unique(df_subset.delta))
n_groups = 2

plots = []

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)"]

for (j, dd) in enumerate(df_grouped)
    groups = groupby(dd, :delta, sort = true)
    for (i, d) in enumerate(groups)
        alpha = d.alpha[1]

        yguide = i == 1 ? L"\hat{\beta}_j\; (\alpha = %$(alpha))" : ""

        yformatter = i == 1 ? :auto : _ -> ""

        xformatter = if j == n_rows
            x -> round(x, digits = 2)
        else
            x -> ""
        end

        omega = d.delta[1]

        title = if j == 1
            L"\omega = %$(omega)"
        else
            ""
        end

        xlabel = j == n_rows && i == 2 ? L"q" : ""

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
            legendposition = j == 2 && i == 3 ? :outerright : :none,
            labels = labels,
        )

        push!(plots, pl)
    end
end

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)"]

l = (n_rows, n_cols)

pl = plot(
    plots...,
    layout = l,
    size = (0.9 * FULL_WIDTH, 370),
    left_margin = [0mm 2mm 2mm],
    bottom_margin = 1mm,
)

file_path = @projectroot("plots", "mixed_data_elnet.pdf");

savefig(pl, file_path)
