using LaTeXStrings
using DataFrames
using NormReg
using CSV
using ProjectRoot

hyperopt_dir = @projectroot("results", "hyperopt-big")
df_list = []
for file in readdir(hyperopt_dir, join = true)
    if endswith(file, ".csv")
        push!(df_list, CSV.read(file, DataFrame))
    end
end

df = reduce(vcat, df_list)

df_dataset = groupby(df, [:dataset])

output = []

for (j, d) in enumerate(df_dataset)
    dataset = d[1, :dataset]

    dd = select(d, [:dataset, :delta, :lambda, :err])
    dd_sorted = sort(dd, [:delta, :lambda])

    err = dd_sorted.err

    best_ind = argmin(err)

    ddd = dd_sorted[best_ind, :]
    push!(output, ddd)
end

res = DataFrame(reduce(vcat, output))
