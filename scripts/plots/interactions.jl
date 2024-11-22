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
  :q => q -> q .== 0.9,
  :norm_strategy => n -> n .== 1,
  :mu => m -> m .== 0,
  :center_before => c -> c .== true,
);

df_grouped = @chain df_subset begin
  select([:betas, :norm_strategy, :it, :q, :delta, :beta])
  groupby([:norm_strategy], sort = true)
end;

n_rows = length(unique(df_subset.norm_strategy))
n_cols = length(unique(df_subset.beta))
n_groups = 3

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" "Interaction"]

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

    # ylabel = j == 1 ? "Strategy " * string(d.norm_strategy[1]) : ""
    ylabel = j == 1 ? L"\hat{\beta}_j" : ""
    # xlabel = i == n_rows ? L"\delta" : ""
    xlabel = j == 3 ? L"\delta" : ""

    beta = join(d.beta[1], "\\;")

    title = i == 1 ? L"$\beta^*=[%$(beta)]^\intercal$" : ""

    delta = string.(dd.delta)

    xformatter = i == 1 ? :auto : _ -> ""

    yformatter = j == 1 ? :auto : _ -> ""

    pl = groupedbar(
      delta,
      dd.mean_betas,
      group = dd.var,
      labels = labels,
      # legend = j == n_cols ? true : :none,
      legendposition = j == n_cols ? :outerright : :none,
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

# layout = @layout[grid(n_rows, n_cols) a{0.20w}]
layout = (n_rows, n_cols)

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" "Interaction"]

# legend = bar(
#   zeros(1, n_groups),
#   showaxis = false,
#   grid = false,
#   linecolor = :white,
#   label = labels,
#   framestyle = :none,
#   legend_position = :topleft,
#   background_color_subplot = :transparent,
# )

# plots = plot(plots..., legend, layout = layout, size = (FULL_WIDTH, 160))
plots = plot(plots..., layout = layout, size = (FULL_WIDTH, 160))

file_path = @projectroot("paper", "plots", "interactions.pdf")
savefig(plots, file_path)
