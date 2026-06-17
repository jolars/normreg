# Poster variant of the bias/variance/MSE figure (column 3), lasso only.
# Reads the already-computed results and renders with the poster profile.
# Reduced from four noise levels to two for legibility at poster scale.
# Data is produced by scripts/experiments/binary_onedim_bias_var.jl.

using DataFrames
using Distributions
using JSON
using LaTeXStrings
using NormReg
using Plots
using Plots.PlotMeasures
using ProjectRoot
using StatsPlots

set_plot_defaults(target = "poster")

results = JSON.parsefile(@projectroot("results", "binary_onedim_bias_var.json"))
df = DataFrame(results)

function plot_binary_bias_var(
        df,
        α = 0,
        sigma_e = [0.25, 1.0],
        fig_width = 820,
        fig_height = 640,
    )
    df_subset = subset(df, :α => a -> a .== α, :sigma_e => s -> s .∈ Ref(sigma_e))
    df_long = stack(df_subset, Not([:q, :sigma_e, :delta, :lambda, :α]))

    n_delta = length(unique(df_subset.delta))
    n_sigma = length(unique(df_subset.sigma_e))

    grouped_df = groupby(df_long, [:variable])

    plots = []

    pal = :Johnson

    variable_map = Dict("mse" => "MSE", "bias" => "Bias", "var" => "Variance")

    for (i, d) in enumerate(grouped_df)
        subgrouped_df = groupby(d, [:sigma_e])

        for (j, dd) in enumerate(subgrouped_df)
            sort!(dd, [:delta])

            variable = d.variable[1]

            ylab = if j == 1
                variable_map[variable]
            else
                ""
            end

            title = if i == 1
                title_stump = dd.sigma_e[1]
                L"\sigma_e = %$(title_stump)"
            else
                ""
            end

            xlab = if i > 2
                L"q"
            else
                ""
            end

            xformatter = if i > 2
                x -> round(x, digits = 2)
            else
                x -> ""
            end

            ylims = variable == "var" ? (-0.02, 0.4) : variable == "mse" ? (-0.2, 4.5) : :auto

            yformatter = j == 1 ? :auto : _ -> ""

            pl = @df dd plot(
                :q,
                :value,
                groups = :delta,
                ylabel = ylab,
                xlabel = xlab,
                ylims = ylims,
                xlims = (0.45, 1.05),
                xformatter = xformatter,
                yformatter = yformatter,
                xticks = 0.5:0.25:1,
                title = title,
                legend = false,
                palette = pal,
            )

            # Plot asymptotic limit for standardization case
            if variable == "bias" && dd.α[1] == 1
                β = 2
                n = 100
                σe = dd.sigma_e[1]
                std_group = subset(dd, :delta => d -> d .== 0.5)
                λ = std_group.lambda[1] * std_group.α[1]
                lev = 2 * β * cdf(Normal(), -λ / (σe * sqrt(n))) - β
                hline!(pl, [lev], linestyle = :dot, linecolor = :black)
            end

            if variable == "var" && α == 0
                β = 2
                n = 100
                σe = dd.sigma_e[1]
                group = subset(dd, :delta => d -> d .== 0.25)
                λ = group.lambda[1] * (1 - α)
                lev = σe^2 * n / λ^2
                hline!(pl, [lev], linestyle = :dot, linecolor = :black)
            end

            if variable == "bias" && α > 0 && α < 1
                β = 2
                n = 100
                group = subset(dd, :delta => d -> d .== 1)
                λ2 = group.lambda[1] * (1 - group.α[1])
                lev = β * n / (n + λ2) - β
                hline!(pl, [lev], linestyle = :dot, linecolor = :black)
            end

            push!(plots, pl)
        end
    end

    lab = reshape(sort(unique(df.delta)), 1, n_delta)

    legendvals = collect(zeros(n_delta)')

    legend_title = α > 0 && α < 1 ? L"\omega" : L"\delta"

    legend = plot(
        legendvals,
        showaxis = false,
        grid = false,
        label = lab,
        legend_position = :left,
        legend_title = legend_title,
        palette = pal,
        background_color_subplot = :transparent,
        framestyle = :none,
    )

    l = @layout[grid(3, n_sigma) a{0.2w}]

    plotlist = plot(plots..., legend, layout = l, size = (fig_width, fig_height))

    return plotlist
end

lasso_plot = plot_binary_bias_var(df, 1, [0.25, 1.0], 820, 640)

out = @projectroot("posters", "icml2026", "figures", "binary_onedim_bias_var_lasso.pdf")
mkpath(dirname(out))
save_poster(lasso_plot, out)
println("wrote ", out)
