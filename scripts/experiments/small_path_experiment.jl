using GLM
using DrWatson
using ProjectRoot
using Distributions
using JSON
using Statistics
using NormReg
using Lasso
using Random

using DataFrames
using Plots
using LaTeXStrings

function simple_path_simulation(normalization = "std", α = 1.0)
    n = 1_000
    q1 = 0.5
    q2 = 0.9

    x1 = generate_pseudobernoulli(n, q = q1)
    x2 = generate_pseudobernoulli(n, q = q2)

    x = [x1 x2]

    beta = ones(size(x, 2))

    y = x * beta

    x_norm, centers, scales = normalize_features_unadjusted(Array(x), normalization)

    λminratio = 1.0e-8
    c = x_norm' * (y .- mean(y))
    tmp = abs.(c) ./ (max(1.0e-2, α))
    max_ind = argmax(tmp)
    λmax = tmp[max_ind]

    λ = collect(logspace(λmax, λmax * λminratio, 99))

    push!(λ, 0.0)

    res = elasticnet(
        x_norm,
        y,
        α = α,
        λ = λ,
        cyclic = false,
        screen = false,
        devmax = 1,
        fdev = 0,
    )
    _, betas = unstandardize_coefficients(res.β0, res.β, centers, scales)

    return betas
end

param_dict = Dict{String, Any}(
    "normalization" => ["l1", "std", "max_abs"],
    "alpha" => [0.0, 1.0],
)

param_expanded = dict_list(param_dict)

results = []

for (i, d) in enumerate(param_expanded)
    @unpack normalization, alpha = d

    Random.seed!(909)

    betas = simple_path_simulation(normalization, alpha)

    d_exp = copy(d)
    d_exp["betas"] = betas

    push!(results, d_exp)
end

outfile = @projectroot("results", "small_path_experiment.json")

open(outfile, "w") do f
    write(f, JSON.json(results))
end

set_plot_defaults();

json_data = JSON.parsefile(@projectroot("results", "small_path_experiment.json"));

df = DataFrame(json_data);

plots = []

normalization_types = unique(df.normalization)
alpha_types = unique(df.alpha)

n_cols = length(normalization_types)
n_rows = length(alpha_types)

labels = [L"\operatorname{Bernoulli}(0.5)" L"\operatorname{Bernoulli}(0.9)"]

for (i, alpha) in enumerate(alpha_types)
    d_alpha = filter(row -> row.alpha == alpha, df)

    for (j, normtype) in enumerate(normalization_types)
        d = filter(row -> row.normalization == normtype, d_alpha)

        betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))

        ylabel = alpha == 0 ? L"\hat{\beta}_j^\text{Ridge}" : L"\hat{\beta}_j^\text{Lasso}"

        ylabel = j == 1 ? ylabel : ""
        xlabel = j == 2 && i == 2 ? "Step" : ""

        yformatter = j == 1 ? :auto : _ -> ""
        xformatter = i == 2 ? :auto : _ -> ""

        legendposition = j == n_cols && i == 1 ? :outerright : :none

        normtype_label = normtype == "std" ? "Standardization" : normtype == "l1" ? "L1" : "Max-Abs"

        title = i == 1 ? normtype_label : ""

        pl = plot(
            betas,
            xlabel = xlabel,
            ylabel = ylabel,
            legendposition = legendposition,
            title = title,
            yformatter = yformatter,
            xformatter = xformatter,
            labels = labels,
        )

        push!(plots, pl)
    end
end

pl = plot(
    plots...,
    layout = (n_rows, n_cols),
    size = (FULL_WIDTH, 270),
    link = :both,
)

file_path = @projectroot("plots", "small_path_experiment.pdf");

savefig(pl, file_path)
