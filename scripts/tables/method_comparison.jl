using DataFrames
using CSV
using ProjectRoot

file = @projectroot("results", "method_comparison.csv")

df = CSV.read(file, DataFrame)

sort!(df, [:alpha, :dataset, :method])

df_lasso = subset(df, :alpha => a -> a .== 1.0)

df_ridge = subset(df, :alpha => a -> a .== 0.0)
