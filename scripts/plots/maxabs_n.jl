using DataFrames
using StatsPlots
using Plots
using NormReg
using LaTeXStrings
using JSON
using ProjectRoot

NormReg.setPlotSettings()

json_data = JSON.parsefile(@projectroot("data", "maxabs_n.json"));
df = DataFrame(json_data);
df_flat = DataFrames.flatten(df, [:n, :beta, :distribution]);

pl = @df df_flat plot(
  :n,
  :beta,
  groups = :distribution,
  ylabel = L"\beta",
  xlabel = L"n",
  size = (235, 175),
)

file_name = "maxabs_n"
file_path = @projectroot("paper", "plots", "maxabs_n.pdf")

savefig(pl, file_path)
