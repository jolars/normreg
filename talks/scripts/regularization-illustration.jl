using StatsBase
using ColorSchemes
using PythonPlot
using Random
using Lasso
using LaTeXStrings
using Plots
using Distributions
using ProjectRoot
using Statistics

function set_plot_defaults(backend = "pyplot")
  # theme(:wong2)
  default(framestyle = :box, label = nothing, tick_direction = :in, palette = :tableau_10)
  if backend == "gr"
    gr()
  else
    default(
      titlefontsize = 11,
      thickness_scaling = 0.9,
      background_color_outside = :transparent,
      legend_background_color = :transparent,
    )
    pythonplot()
    matplotlib.rcParams["text.usetex"] = true
    matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}\\usepackage{amsfonts}\\usepackage{amssymb}\\usepackage{mathtools}"
  end
end
set_plot_defaults("pyplot");

# Set seed for reproducibility
Random.seed!(1234)

# Generate synthetic data
n = 100
x = reshape(10 * rand(n), n, 1)
y = vec(2 * x .+ 5 .+ randn(n).*2)

path = fit(LassoPath, x, y, Normal())

# Extract coefficients
ind1 = length(path.λ)
ind2 = 10
ind3 = 1

coef1 = coef(path)[:, ind1]
coef2 = coef(path)[:, ind2]
coef3 = coef(path)[:, ind3]

lam1 = path.λ[ind1]
lam2 = path.λ[ind2]
lam3 = path.λ[ind2]

# Define the fitted lines
y_fit1 = coef1[1] .+ coef1[2] .* x
y_fit2 = coef2[1] .+ coef2[2] .* x
y_fit3 = coef3[1] .+ coef3[2] .* x

# Plot the original data and the fits
# Assuming lam1 and lam2 are defined somewhere in your script

# Round the values
rounded_lam1 = round(lam1, digits=2)
rounded_lam2 = round(lam2, digits=2)

# Update the plot titles with rounded values
p1 = scatter(vec(x), y, title=L"\lambda_1 = %$rounded_lam1", markerstrokecolor = :white, markercolor = :grey)
plot!(x, y_fit1)

p2 = scatter(x, y, title=L"\lambda_1 = %$rounded_lam2", markerstrokecolor = :white, markercolor = :grey)
plot!(x, y_fit2)

p3 = scatter(x, y, title=L"\lambda_1 \rightarrow \infty", markerstrokecolor = :white, markercolor = :grey)
plot!(x, y_fit3)

# Combine plots

plot_output = plot(p1, p2, p3, layout=(1, 3), legend=false, size = (450, 150))
file_path = @projectroot("talks", "dsts", "figures", "regularization-illustration.pdf")
savefig(plot_output, file_path)
