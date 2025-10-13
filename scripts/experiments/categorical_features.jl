using GLM
using DrWatson
using ProjectRoot
using Distributions
using Statistics
using NormReg
using Lasso
using Random

using Plots
using LaTeXStrings

# An experiment with categorical features, using
# one-hot encoding but changing the reference level
# from first to last to show the effect of the
# normalization and sparsity interaction.

set_plot_defaults();

n = 5_000
α = 1.0

a = (1 / 10)
b = 1 / 2

q = [a * (1 - b), b, (1 - a) * (1 - b)];

# Case 1: First as reference

x1 = Int.(x_categorical .== 2);
x2 = Int.(x_categorical .== 3);

x = [x1 x2];

beta = [0.5, 1.0];

y = x * beta;

x_norm, centers, scales = normalize_features_unadjusted(Array(x), "std");

res2 = elasticnet(
    x_norm,
    y,
    α = α,
    λminratio = λminratio,
);
_, betas2 = unstandardize_coefficients(res2.β0, res2.β, centers, scales);

# Case 2: Last as reference
x_categorical = rand(Categorical(q), n);

x1 = Int.(x_categorical .== 1);
x2 = Int.(x_categorical .== 2);

x = [x1 x2];

beta = [1.0, 0.5]

y = x * beta

x_norm, centers, scales = normalize_features_unadjusted(Array(x), "none");

λminratio = 1.0e-2

res1 = elasticnet(
    x_norm,
    y,
    α = α,
    λminratio = λminratio,
);
_, betas1 = unstandardize_coefficients(res1.β0, res1.β, centers, scales);


labels = []

ylim = [-0.05, 1.05]

pl1 = plot(
    betas2',
    xlabel = "Step",
    ylim = ylim,
    ylabel = L"\hat{\beta}",
    color = ["gray" "darkorange"],
    linestyle = [:dash :solid],
    legendposition = :topleft,
    labels = [L"\beta_{B:A}" L"\beta_{C:A}"]
)
pl2 = plot(
    betas1',
    xlabel = "Step",
    color = ["darkorange" "gray"],
    linestyle = [:solid :dash],
    yformatter = _ -> "",
    ylim = ylim,
    legendposition = :topleft,
    labels = [L"\beta_{A:C}" L"\beta_{B:C}"]
)

plots = [pl1 pl2]

pl = plot(
    plots...,
    layout = (1, 2),
    size = (FULL_WIDTH * 0.7, 190),
)

file_path = @projectroot("plots", "categorical_features.pdf");

savefig(pl, file_path)
