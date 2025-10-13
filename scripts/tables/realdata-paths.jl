using DataFrames
using NormReg
using JSON
using ProjectRoot

json_data = JSON.parsefile(@projectroot("results", "realdata_paths.json"));

df = DataFrame(json_data);

plots = [];
n_rows = length(unique(df.normalization));
n_cols = length(unique(df.dataset));

dy = groupby(df, :dataset)
dd = dy[1]

results = []

df_grouped = groupby(df, :dataset)

for (j, dd) in enumerate(df_grouped)
    dataset = unique(dd.dataset)[1]

    b_std = dd.beta_cv[1][1]
    b_maxabs = dd.beta_cv[2][1]
    ind = dd.ind[1]

    res = Dict{String, Any}("dataset" => dataset, "beta" => [b_std[ind] b_maxabs[ind]])

    push!(results, res)
end

drf = DataFrame(results)

[drf[1, :beta] drf[2, :beta] drf[3, :beta] drf[4, :beta]]
