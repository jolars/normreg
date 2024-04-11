using GLM
using LaTeXStrings
using ProjectRoot
using LIBSVMdata
using Lasso
using Plots
using NormReg

set_plot_defaults()

dataset = "abalone"

x, y = load_dataset(dataset, dense = true, replace = false, verbose = false)

res = fit(LassoPath, x, y, Normal(), α = 0.9)

coefs = Matrix(res.coefs)

n_var = size(coefs, 1)
n_lambda = size(coefs, 2)
x_var = 1:n_lambda

plot(
  res.λ,
  coefs',
  xscale = :log10,
  xflip = true,
  xlabel = L"\lambda",
  ylabel = L"\hat\beta",
  legend = false,
  size = (190, 220),
)

savefig(@projectroot("talks", "uppsala", "figures", "elasticnet_path.pdf"))
