using DataFrames
using CSV
using ProjectRoot

file = @projectroot("results", "method_comparison.csv")

df = CSV.read(file, DataFrame)

sort!(df, [:alpha, :dataset, :method])

df_lasso = subset(df, :alpha => a -> a .== 1.0)

df_ridge = subset(df, :alpha => a -> a .== 0.0)

# function create_comp_table(df, type)
#   # Sort by dataset, then method
#   sort!(df, [:dataset, :method])
#
#   xval = string.(df.dataset)
#   groups = string.(df.method)
#
#   n_xval = length(unique(xval))
#   n_groups = length(unique(groups))
# end
#
# create_comp_table(df_lasso, "lasso")
