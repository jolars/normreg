using DrWatson

@quickactivate "normreg"

using DataFrames

include(srcdir("plot_settings.jl"))

df = collect_results(datadir("dummy-variables"))

df_subset = subset(df, :rho => r -> r .== 0.0)
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

plot_output = plot(plots..., layout = 2, ylim = (0, 1), size=(400,170))

savefig(plot_output, plotsdir("dummy-plot.pdf"))
savefig(plot_output, plotsdir("dummy-plot.png"))

# d1 = subset(df_subset, :alpha => a -> a .== 1)
#
# p1 = plot(collect(d1.ps[1]), d1.betas[1][1, :])
# plot!(d1.ps[1], d1.betas[1][2, :])
#
# show(plots)
# plots
# display(plots)

# savefig(plots)
# # @df df_subset plot(:ps, group = :alpha, layout = 2)
#
# #
# # wsave(plotsdir("dummy-plot.png"), p)
# # wsave(plotsdir("dummy-plot.pdf"), p)
# # Generate some plots
# plot1 = plot(rand(10), title = "Plot 1")
# plot2 = plot(rand(10), title = "Plot 2")
# plot3 = plot(rand(10), title = "Plot 3")
# # Create a vector of plots
# plots = [plot1, plot2, plot3]
# # Display the vector of plots
# display(plots)
