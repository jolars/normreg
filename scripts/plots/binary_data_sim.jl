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
groups = groupby(df, [:q_type, :normalization], sort = true);

avg_value = combine(groups, :err .=> [mean, confidence_error]);

plot_output = @df avg_value groupedbar(
  :q_type,
  :err_mean,
  group = :normalization,
  yerror = :err_confidence_error,
  legend = :outerright,
  ylabel = "Normalized Mean-Squared Error",
  xlabel = "Class Balance of Signals",
  size = (450, 240),
)

file_path = @projectroot("paper", "plots", "binary_data_sim.pdf")
savefig(plot_output, file_path)
