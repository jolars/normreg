using DataFrames
using JSON
using LaTeXStrings
using NormReg
using Plots
using Plots.PlotMeasures
using ProjectRoot
using StatsPlots

set_plot_defaults();

results = JSON.parsefile(@projectroot("data", "binary_onedim_bias_var.json"));

df = DataFrame(results);

function plot_binary_bias_var(df, α = 0)
  df_subset = subset(df, :α => a -> a .== α)
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
        # legend = i == 1 && j == 4,
        # legend_position = :outerright,
        c,
      )

      # Plot asymptotic limit for standardization case
      if i == 2 && dd.α[1] > 0
        β = 2
        n = 100
        σe = dd.sigma_e[1]
        std_group = subset(dd, :delta => d -> d .== 0.5)
        λ = std_group.lambda[1] * std_group.α[1]
        lev = 2 * β * cdf(Normal(), -λ / (σe * sqrt(n))) - β
        hline!(pl, [lev], linestyle = :dot, linecolor = :black)
      end

      if variable == "var" && dd.α[1] == 0
        β = 2
        n = 100
        σe = dd.sigma_e[1]
        std_group = subset(dd, :delta => d -> d .== 0.25)
        λ = std_group.lambda[1] * (1 - std_group.α[1])
        # lev = 2 * β * cdf(Normal(), -λ / (σe * sqrt(n))) - β
        lev = σe^2 * n / λ^2
        hline!(pl, [lev], linestyle = :dot, linecolor = :black)
      end

      push!(plots, pl)
    end
  end

  lab = reshape(sort(unique(df.delta)), 1, n_delta)

  legendvals = collect(zeros(n_delta)')

  legend = plot(
    legendvals,
    showaxis = false,
    grid = false,
    label = lab,
    legend_position = :left,
    legend_title = L"\delta",
    palette = pal,
    background_color_subplot = :transparent,
    framestyle = :none,
  )

  l = @layout[grid(3, n_sigma) a{0.12w}]

  plotlist = plot(plots..., legend, layout = l, size = (FULL_WIDTH, 400))

  return plotlist
end

lasso_plot = plot_binary_bias_var(df, 1)
ridge_plot = plot_binary_bias_var(df, 0)
elnet_plot = plot_binary_bias_var(df, 0.5)

savefig(lasso_plot, @projectroot("paper", "plots", "binary_onedim_bias_var_lasso.pdf"))
savefig(ridge_plot, @projectroot("paper", "plots", "binary_onedim_bias_var_ridge.pdf"))
savefig(elnet_plot, @projectroot("paper", "plots", "binary_onedim_bias_var_elnet.pdf"))