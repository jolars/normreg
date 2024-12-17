using DataFrames
using NormReg
using StatsBase
using StatsPlots
using JSON
using LaTeXStrings
using Plots
using Distributions
using ProjectRoot

set_plot_defaults();

json_data = JSON.parsefile(@projectroot("data", "binary_data_decreasing.json"));
df = DataFrame(json_data);

function plot_binary_decreasing(
  df;
  rho_choice = [0.0, 0.5, 0.9],
  fig_width = NormReg.FULL_WIDTH,
  fig_height = 350,
)
  df_subset = subset(df, :rho => rho -> rho .∈ Ref(rho_choice))
  df_grouped = groupby(df_subset, [:delta], sort = true)

  n_rows = length(unique(df_subset.delta))
  n_cols = length(unique(df_subset.rho))

  plots = []

  for (i, df_group) in enumerate(df_grouped)
    df_subgrouped = groupby(df_group, [:rho], sort = true)

    for (j, d) in enumerate(df_subgrouped)
      b = d.betas
      res = dropdims(mapreduce(permutedims, hcat, b), dims = 1)
      out = Float64.(mapreduce(permutedims, vcat, res))[:, 1:30]

      xvar = 1:size(out, 2)
      yvar = mean(out, dims = 1)'
      yerror = std(out, dims = 1)'

      rho = d.rho[1]
      delta = d.delta[1]

      title = i == 1 ? L"\rho = %$(rho)" : ""

      yformatter = j == 1 ? :auto : _ -> ""
      xformatter = i == n_rows ? :auto : _ -> ""

      xlabel =
        i == n_rows && ((n_cols % 2 == 0) || (j == ceil(Int, n_cols / 2))) ?
        "Feature Index" : ""

      ylabel = if j == 1
        L"\hat\beta"
      elseif j == n_cols
        L"\delta = %$(delta)"
      else
        ""
      end

      yguideposition = if j == n_cols
        :right
      else
        :left
      end

      pl = scatter(
        xvar,
        yvar;
        legend = false,
        markercolor = :transparent,
        markersize = 0,
        title = title,
        xformatter = xformatter,
        xlabel = xlabel,
        yformatter = yformatter,
        ylabel = ylabel,
        ylims = (-0.5, 2),
        yguideposition = yguideposition,
      )

      yerror!(
        1:size(out, 2),
        yvar;
        yerror = yerror,
        markercolor = :transparent,
        markerstrokecolor = :grey,
      )

      scatter!(1:size(out, 2), yvar; markercolor = :black, markersize = 2)

      push!(plots, pl)
    end
  end

  layout = (n_rows, n_cols)

  plots = plot(plots..., layout = layout, size = (fig_width, fig_height))

  return plots
end

plots = plot_binary_decreasing(df)
file_path = @projectroot("paper", "plots", "binary_decreasing.pdf")
savefig(plots, file_path)

plots_small =
  plot_binary_decreasing(df; rho_choice = [0.0, 0.9], fig_width = 320, fig_height = 300)
file_path_small = @projectroot("paper", "plots", "binary_decreasing_small.pdf")
savefig(plots_small, file_path_small)
