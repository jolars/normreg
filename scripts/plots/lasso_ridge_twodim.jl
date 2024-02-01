using DataFrames
using NormReg
using JSON
using LaTeXStrings
using Plots
using ProjectRoot
using FileIO

json = JSON.parsefile(@projectroot("data", "lasso_ridge_twodim.json"));
df = DataFrame(json);
df_subset = subset(df, :rho => r -> r .== 0.0);

NormReg.setPlotSettings("pyplot")

df_lasso = subset(df_subset, :alpha => a -> a .== 1.0)
df_ridge = subset(df_subset, :alpha => a -> a .== 0.0)

groups = (groupby(df_subset, [:normalization], sort = true))

function make_plot(df_subset)
  plots = []
  groups = groupby(df_subset, :normalization, sort = true)
  for (i, d) in enumerate(groups)
    p = plot(legend = false)

    labels = ["normal_0.5" "binary" "normal_2"]
    legend = i == 4 ? :outerright : false

    yguide = L"\hat\beta / \beta^*"

    betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))

    plot!(
      d.ps[1],
      betas,
      yguide = i == 1 ? yguide : "",
      yformatter = i == 1 ? :auto : _ -> "",
      legend = legend,
      label = labels,
      xticks = 0.5:0.2:1.0,
    )

    title!(string(d.normalization[1]))

    xlabel!(L"q")

    push!(plots, p)
  end

  plot(plots..., layout = (1, 4), size = (480, 200), ylim = (0, 1))
end

p_lasso = make_plot(df_lasso)
p_ridge = make_plot(df_ridge)

file_path_lasso = @projectroot("paper", "plots", "lasso_twodim.pdf")
file_path_ridge = @projectroot("paper", "plots", "ridge_twodim.pdf")

savefig(p_lasso, file_path_lasso)
savefig(p_ridge, file_path_ridge)
