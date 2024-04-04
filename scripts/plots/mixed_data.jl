using DataFrames
using NormReg
using JSON
using LaTeXStrings
using Plots
using ProjectRoot

json_data = JSON.parsefile(@projectroot("data", "mixed_data.json"));
df = DataFrame(json_data);
df_subset = subset(df);

set_plot_defaults()

df_lasso = subset(df_subset, :alpha => a -> a .== 1.0);
df_ridge = subset(df_subset, :alpha => a -> a .== 0.0);

df_grouped = (groupby(df_subset, [:alpha], sort = true));

n_rows = length(unique(df.alpha))
n_cols = length(unique(df.delta))
n_groups = 4

plots = []

for (j, dd) in enumerate(df_grouped)
  groups = groupby(dd, :delta, sort = true)
  for (i, d) in enumerate(groups)
    p = plot(legend = false)

    model = d.alpha[1] == 1 ? "Lasso\n" : "Ridge\n"

    yguide = i == 1 ? model * L"\hat\beta / \beta^*" : ""

    yformatter = i == 1 ? :auto : _ -> ""

    xformatter = if j > 1
      x -> round(x, digits = 2)
    else
      x -> ""
    end

    delta = d.delta[1]

    title = if j == 1
      L"\delta = %$(delta)"
      # norm_map[string(d.normalization[1])]
    else
      ""
    end

    xlabel = j == 2 ? L"q" : ""

    betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))

    plot!(
      d.qs[1],
      betas,
      yguide = yguide,
      yformatter = yformatter,
      xformatter = xformatter,
      xlabel = xlabel,
      title = title,
      xticks = 0.5:0.2:0.9,
      ylim = (-0.1, 1.1),
    )

    push!(plots, p)
  end
end

labels =
  [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" L"\operatorname{Normal}(0, 2)" L"\operatorname{Bernoulli}(q) \times \operatorname{Normal}(0,0.5)"]

legend = plot(
  zeros(1, n_groups),
  showaxis = false,
  grid = false,
  label = labels,
  legend_position = :topleft,
)

l = @layout[grid(n_rows, n_cols) a{0.35w}]

pl = plot(plots..., legend, layout = l, size = (FULL_WIDTH, 300))

file_path = @projectroot("paper", "plots", "mixed_data.pdf");

savefig(pl, file_path)
