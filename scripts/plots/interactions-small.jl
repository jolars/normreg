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

df_subset = subset(
  df,
  :beta => b -> map(x -> x == [1, 1, 1], b),
  :center_before => c -> c .== true,
  :delta => d -> d .== 1,
  :norm_strategy => n -> n .∈ Ref([1, 2]),
);

df_grouped = @chain df_subset begin
  select([:betas, :it, :norm_strategy, :q, :beta])
  groupby([:norm_strategy], sort = true)
end;

n_rows = 1
n_cols = length(unique(df_subset.norm_strategy))
n_groups = 3

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" "Interaction"]

plots = []

for (i, df_subgroup) in enumerate(df_grouped)
  df_subgroup_subset = select(df_subgroup, [:betas, :it, :q])
  n_q = length(unique(df_subgroup.q))
  n_it = length(unique(df_subgroup.it))
  df_wide = reduce(hcat, df_subgroup_subset.betas)
  df_wide_cut = reshape(df_wide, (3, n_it, n_q))
  df_final = permutedims(df_wide_cut, [2, 3, 1])

  ylabel = i == 1 ? L"\hat{\beta}_j" : ""
  title = L"\text{Strategy %$(df_subgroup.norm_strategy[1])}"

  xlabel = L"q"

  yformatter = i == 1 ? :auto : _ -> ""

  y = dropdims(mean(df_final, dims = 1), dims = 1)

  y_err = dropdims(std(df_final, dims = 1), dims = 1)

  q = unique(df_subgroup.q)

  pl = plot(
    q,
    y,
    ribbon = (y_err, y_err),
    labels = labels,
    legendposition = i == n_cols ? :outerright : :none,
    title = title,
    xticks = [0.2, 0.5, 0.8],
    xlabel = xlabel,
    yformatter = yformatter,
    ylabel = ylabel,
    ylims = (-0.1, 1.1),
  )

  push!(plots, pl)
end

layout = (1, 2)

plots = plot(plots..., layout = layout, size = (320, 150))

file_path = @projectroot("paper", "plots", "interactions-classbalance-small.pdf")
savefig(plots, file_path)
