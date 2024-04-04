using DataFrames
using DataFramesMeta
using JSON
using LaTeXStrings
using NormReg
using Plots
using ProjectRoot
using StatsBase
using StatsPlots

set_plot_defaults();

json_data = JSON.parsefile(@projectroot("data", "interactions.json"));
df = DataFrame(json_data);

df_grouped = @chain df begin
  subset(:center => x -> x .== "yes", :q => q -> q .== 0.9)
  select([:betas, :norm_strategy, :it, :q, :delta, :beta])
  groupby([:norm_strategy], sort = true)
end;

n_rows = length(unique(df.norm_strategy))
n_cols = length(unique(df.beta))

plots = []

for (i, df_group) in enumerate(df_grouped)
  # df_group = df_grouped[1]
  df_subgrouped = groupby(df_group, [:beta], sort = false)

  for (j, df_subgroup) in enumerate(df_subgrouped)
    # df_subgroup = df_subgrouped[1]
    d = flatten(df_subgroup, [:betas])
    d.var = repeat(1:3, size(df_subgroup)[1])

    dd =
      combine(groupby(d, [:var, :delta]), :betas => (x -> mean(x, dims = 1)) => :mean_betas)

    ylabel = j == 1 ? "Strategy " * string(d.norm_strategy[1]) : ""
    xlabel = i == n_rows ? L"\delta" : ""

    beta = join(d.beta[1], "\\;")

    title = i == 1 ? L"$\beta^*=[%$(beta)]^\intercal$" : ""

    delta = string.(dd.delta)

    xformatter = i == 1 ? :auto : _ -> ""

    yformatter = j == 1 ? :auto : _ -> ""

    pl = groupedbar(
      delta,
      dd.mean_betas,
      group = dd.var,
      legend = false,
      title = title,
      xformatter = xformatter,
      xlabel = xlabel,
      yformatter = yformatter,
      ylabel = ylabel,
      ylims = (0, 1.6),
    )

    push!(plots, pl)
  end
end

layout = (n_rows, n_cols)

plots = plot(plots..., layout = layout, size = (FULL_WIDTH, 350))

file_path = @projectroot("paper", "plots", "interactions.pdf")
savefig(plots, file_path)
