using DataFrames
using NormReg
using StatsBase
using StatsPlots

using JSON
using LaTeXStrings
using Plots
using Distributions
using ProjectRoot
using Statistics

set_plot_defaults("pyplot");

json = JSON.parsefile(@projectroot("data", "binary_data_sim.json"));
df = DataFrame(json);
df_filtered = select(df, [:it, :normalization, :q_type, :snr, :err]);
df_subset = subset(df_filtered)

groups = groupby(df_subset, [:q_type], sort = true);
dd = groups[1]

plots = []

qtypes = unique(df.q_type)
n_qtypes = length(qtypes)

for (i, dd) in enumerate(groups)
  title = unique(dd.q_type)[1]

  groups = groupby(dd, [:normalization, :snr], sort = true)
  avg = combine(groups, :err .=> [mean, confidence_error])

  legend = i == 3 ? :outerright : nothing

  # yformatter = i == 1 ? :auto : nothing
  yformatter = i == 1 ? :auto : _ -> ""

  pl = @df avg plot(
    :snr,
    :err_mean,
    group = :normalization,
    title = title,
    legend = legend,
    xaxis = :log,
    ribbon = :err_confidence_error,
    yformatter = yformatter,
  )

  if i == 1
    ylabel!("Normalized Mean-Squared Error")
  end

  if i == 2
    xlabel!("Signal-to-Noise Ratio")
  end

  push!(plots, pl)
end

plot_output = plot(plots..., layout = (1, n_qtypes), size = (570, 220))

file_path = @projectroot("paper", "plots", "binary_data_sim.pdf")
savefig(plot_output, file_path)
