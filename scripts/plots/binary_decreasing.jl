using DataFrames
using NormReg
using StatsBase
using StatsPlots
using JSON
using LaTeXStrings
using Plots
using ProjectRoot
using Statistics

NormReg.setPlotSettings("pyplot");

json_data = JSON.parsefile(@projectroot("data", "binary_data_decreasing.json"));
df = DataFrame(json_data);

groups = groupby(df, [:normalization, :snr], sort = true)
avg_value = combine(groups, :err .=> [mean, confidence_error]);

pl = @df avg_value plot(
  :snr,
  :err_mean,
  group = :normalization,
  xlabel = "SNR",
  ylabel = "Normalized Mean-Squared Error",
  legend = :topright,
  xaxis = :log,
  size = (450, 240),
  ribbon = :err_confidence_error,
)

file_path = @projectroot("paper", "plots", "binary_decreasing_snr.pdf")
savefig(pl, file_path)
