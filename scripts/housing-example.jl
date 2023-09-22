using DrWatson
@quickactivate "standreg"

include(srcdir("preprocessing.jl"))
include(srcdir("plotting.jl"))
include(srcdir("compare_standardizations.jl"))


using LIBSVMdata, Lasso, Statistics, Plots
x, y = load_dataset("housing",
  dense=true,
  replace=false,
  verbose=true,
)

compare_standardizations(x, y)

x, y = load_dataset("triazines",
  dense=true,
  replace=false,
  verbose=true,
)

compare_standardizations(x, y)

x, y = load_dataset("leukemia",
  dense=true,
  replace=false,
  verbose=true,
)

y[y.==-1] .= 0

compare_standardizations(x, y, dist=GLM.Binomial())
