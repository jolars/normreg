using Plots
using StatsPlots
using LaTeXStrings
using DataFrames
using CSV
using Plots
using ProjectRoot
using NormReg

set_plot_defaults()

file = @projectroot("results", "method_comparison.csv")

df_raw = CSV.read(file, DataFrame)

df_lasso = subset(df_raw, :alpha => a -> a .== 1.0)
df_ridge = subset(df_raw, :alpha => a -> a .== 0.0)

function plot_comparison(df)
  xval = string.(df.dataset)
  groups = string.(df.method)

  yval = float.(reshape(df.err, length(unique(xval)), length(unique(groups))))
  yerr = float.(reshape(df.hi - df.lo, length(unique(xval)), length(unique(groups))))

  groupedbar(xval, yval, group = groups, yerr = yerr, size = (500, 240))
end

plot_comparison(df_lasso)
savefig(@projectroot("plots", "method_comparison_lasso.pdf"))

plot_comparison(df_ridge)
savefig(@projectroot("plots", "method_comparison_ridge.pdf"))
