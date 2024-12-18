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
  # df_subgroup = df_subgrouped[1]
  df_subgroup_subset = select(df_subgroup, [:betas, :it, :q])
  n_q = length(unique(df_subgroup.q))
  n_it = length(unique(df_subgroup.it))
  df_wide = reduce(hcat, df_subgroup_subset.betas)
  df_wide_cut = reshape(df_wide, (3, n_it, n_q))
  df_final = permutedims(df_wide_cut, [2, 3, 1])
  # d = flatten(df_subgroup_subset, [:betas])
  # d.var = repeat(1:3, size(df_subgroup_subset)[1])

  ylabel = i == 1 ? L"\hat{\beta}_j" : ""
  title = L"\text{Strategy %$(df_subgroup.norm_strategy[1])}"

  # xlabel = i == n_rows ? L"\delta" : ""
  xlabel = i == 2 ? L"q" : ""

  # delta = df_subgroup.delta[1]

  # title = i == 1 ? L"$\beta^*=[%$(beta)]^\intercal$" : ""
  # title = i == 1 ? L"$\delta = %$(delta)$" : ""

  # delta = string.(dd.delta)

  # xformatter = i == n_rows ? :auto : _ -> ""

  yformatter = i == 1 ? :auto : _ -> ""

  y = dropdims(mean(df_final, dims = 1), dims = 1)

  y_err = dropdims(std(df_final, dims = 1), dims = 1)

  q = unique(df_subgroup.q)

  pl = plot(
    q,
    y,
    ribbon = (y_err, y_err),
    labels = labels,
    # legendposition = i == n_cols ? :outerright : :none,
    legendposition = :none,
    title = title,
    # xformatter = xformatter,
    xticks = [0.2, 0.5, 0.8],
    xlabel = xlabel,
    yformatter = yformatter,
    ylabel = ylabel,
    ylims = (-0.1, 1.1),
  )

  push!(plots, pl)
end

# layout = (1, n_cols)
labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" "Interaction"]
legendvals = collect(zeros(3)')

legend = plot(
  legendvals,
  showaxis = false,
  ribbon = (1, 1),
  grid = false,
  label = labels,
  legend_position = :bottom,
  # legend_title = legend_title,
  # palette = pal,
  legendcolumns = 1,
  background_color_subplot = :transparent,
  framestyle = :none,
)
layout = @layout[a{0.35h}; grid(1, 3)]

plots = plot(legend, plots..., layout = layout, size = (320, 200))

file_path = @projectroot("paper", "plots", "interactions-classbalance-small.pdf")
savefig(plots, file_path)
