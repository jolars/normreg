using DrWatson

@quickactivate "normreg"

using DataFrames
using StatsPlots

include(srcdir("plot_settings.jl"))

res = collect_results(datadir("maxabs_n"))

df = res.data[1]

pl = @df df plot(
  :n,
  :value,
  groups = :variable,
  ylabel = L"\beta",
  xlabel = L"n",
  size = (230, 175),
)

file_name = "maxabs_n"

savefig(pl, plotsdir(file_name * ".pdf"))
