using GLM
using DrWatson
using ProjectRoot
using JSON
using Statistics
using NormReg
using Lasso

function path_simulation(dataset, normalization)
    x, y = datagrabber(dataset)

    x_norm, centers, scales = normalize_features_unadjusted(Array(x), normalization)

    res_full = fit(LassoPath, x_norm, y, dist, standardize = false)

    _, betas = unstandardize_coefficients(res_full.b0, res_full.coefs, centers, scales)

    seed = 1234

    deltas = [1]

    x_train, y_train, x_test, y_test = split_data(x, y, 0.5)

    _, _, _, _, best_lambda, _ = cross_validate(
        x_train,
        y_train,
        Normal(),
        normalization,
        1,
        deltas,
        5,
        "nmse",
        seed = seed,
        repeats = 5,
    )

    x_norm_test, centers, scales = normalize_features_unadjusted(Array(x_test), normalization)

    res_test =
        fit(LassoPath, x_norm_test, y_test, Normal(), standardize = false, λ = [best_lambda])

    beta_unstd = res_test.coefs[:, 1]
    ind = sortperm(abs.(beta_unstd), rev = true)[1:5]

    _, beta_cv = unstandardize_coefficients(res_test.b0, res_test.coefs, centers, scales)

    return betas, beta_cv, ind
end

param_dict = Dict{String, Any}(
    "dataset" => ["housing", "a1a", "triazines", "w1a"],
    "normalization" => ["std", "max_abs"],
    "alpha" => 1.0,
)

param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
    @unpack dataset, normalization, alpha = d

    betas, beta_cv, ind = path_simulation(dataset, normalization)

    d_exp = copy(d)
    d_exp["betas"] = betas
    d_exp["beta_cv"] = beta_cv
    d_exp["ind"] = ind

    push!(results, d_exp)
end

outfile = @projectroot("results", "realdata_paths.json")

open(outfile, "w") do f
    write(f, JSON.json(results))
end
