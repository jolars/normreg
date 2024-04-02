using DataFrames
using NormReg
using JSON
using LaTeXStrings
using Plots
using ProjectRoot

json_data = JSON.parsefile(@projectroot("data", "lasso_ridge_twodim.json"));
df = DataFrame(json_data);
df_subset = subset(df);

set_plot_defaults()

df_lasso = subset(df_subset, :alpha => a -> a .== 1.0);
df_ridge = subset(df_subset, :alpha => a -> a .== 0.0);

df_grouped = (groupby(df_subset, [:alpha], sort = true));

norm_map = Dict(
  "none" => "None",
  "mean_std" => "Std",
  "mean_stdvar" => "Adapt",
  "max_abs" => "Max-Abs",
);

plots = []

for (j, dd) in enumerate(df_grouped)
  groups = groupby(dd, :normalization, sort = true)
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

    title = if j == 1
      norm_map[string(d.normalization[1])]
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
  [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" L"\operatorname{Normal}(0, 2)" L"\operatorname{Bernoulli}(q) \times \operatorname{Normal}(0,0.2)"]

legend = plot(
  [0 0 0 0],
  showaxis = false,
  grid = false,
  label = labels,
  legend_position = :topleft,
)

l = @layout[grid(2, 4) a{0.35w}]

pl = plot(plots..., legend, layout = l, size = (FULL_WIDTH, 300))

file_path = @projectroot("paper", "plots", "lassoridge_twodim.pdf");

savefig(pl, file_path)
