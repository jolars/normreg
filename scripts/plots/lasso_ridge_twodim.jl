using DrWatson

@quickactivate "normreg"

using DataFrames

include(srcdir("plot_settings.jl"))

default(titlefontsize = 12)

df = collect_results(datadir("lasso_ridge_twodim"))
df_subset =
  subset(df, :rho => r -> r .== 0.0, :normalization => norm -> norm .== "mean_std")

plots = []
for d in groupby(df_subset, :alpha)
  lasso = d.alpha[1] == 1
  title = lasso ? "lasso" : "ridge"
  plot_legend = copy(lasso)
  p = plot(d.ps[1], d.betas[1][1, :], legend = plot_legend)
  plot!(d.ps[1], d.betas[1][2, :], legend = plot_legend)
  xlabel!(L"q")
  if !lasso
    ylabel!(L"\beta")
  end
  title!(title)
  push!(plots, p)
end

plot_output = plot(plots..., layout = 2, ylim = (0, 0.9), size = (400, 180))

file_name = "lasso_ridge_twodim"

savefig(plot_output, plotsdir(file_name * ".pdf"))
