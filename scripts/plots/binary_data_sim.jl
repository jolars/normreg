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

function confidence_interval(x, level = 0.95)
  n = length(x)

  alpha = 1 - level

  q = quantile(TDist(n - 1), 1 - alpha / 2)
  se = std(x) / sqrt(n)

  return (mean(x) - q * se, mean(x) + q * se)
end

function confidence_error(x, level = 0.95)
  n = length(x)

  alpha = 1 - level

  q = quantile(TDist(n - 1), 1 - alpha / 2)
  se = std(x) / sqrt(n)

  return q * se
end

NormReg.setPlotSettings("pyplot");

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
  ylabel = "Mean-Squared Error",
  xlabel = "Class Balance of Signals",
  size = (450, 240),
)

file_path = @projectroot("paper", "plots", "binary_data_sim.pdf")
savefig(plot_output, file_path)

# subset(df, :normalization .=> n -> n .== "mean_std", :q_type .=> q -> q .== "imbalanced")
# subset(df, :normalization .=> n -> n .== "mean_stdvar", :q_type .=> q -> q .== "imbalanced")
