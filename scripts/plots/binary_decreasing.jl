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

function confidence_interval(x, level = 0.05)
  n = length(x)

  q = quantile(TDist(n - 1), 1 - level / 2)
  se = std(x) / sqrt(n)

  return (mean(x) - q * se, mean(x) + q * se)
end

function confidence_error(x, level = 0.05)
  n = length(x)

  q = quantile(TDist(n - 1), 1 - level / 2)
  se = std(x) / sqrt(n)

  return q * se
end

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
