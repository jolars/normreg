using DataFrames
using NormReg
using StatsBase
using StatsPlots
using ColorSchemes
using JSON
using LaTeXStrings
using Plots
using Distributions
using ProjectRoot
using Statistics

set_plot_defaults("pyplot");

jsondata = JSON.parsefile(@projectroot("data", "binary_data_sim.json"));
df = DataFrame(jsondata);
df_filtered = select(df, [:it, :delta, :q, :snr, :err]);
df_subset = subset(df_filtered)

groups = groupby(df_subset, [:q], sort = true);
dd = groups[1]

plots = []

qtypes = unique(df.q)
n_qtypes = length(qtypes)

ymin = minimum(df.err)
ymax = maximum(df.err)

for (i, dd) in enumerate(groups)
  q = dd.q[1]

  title = L"q = %$(q)"

  groups = groupby(dd, [:delta, :snr], sort = true)
  avg = combine(groups, :err .=> [mean, confidence_error])

  legend = i == n_qtypes ? :bottomleft : false

  yformatter = i == 1 ? :auto : _ -> ""

  avg.delta = string.(avg.delta)

  pl = @df avg plot(
    :snr,
    :err_mean,
    group = :delta,
    title = title,
    legend = legend,
    legend_title = L"\delta",
    xaxis = :log,
    ribbon = :err_confidence_error,
    yformatter = yformatter,
    ylims = (ymin, ymax),
    color = delta_palette([1, 3, 4]),
  )

  if i == 1
    ylabel!("NMSE")
  end

  if i == 2
    xlabel!("Signal-to-Noise Ratio")
  end

  push!(plots, pl)
end

plot_output = plot(plots..., layout = (1, n_qtypes), size = (320, 180))

file_path = @projectroot("paper", "plots", "binary_data_sim.pdf")
savefig(plot_output, file_path)
