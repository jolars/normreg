# Poster lead figure (column 1, "The Problem"): real-data lasso paths for a
# single dataset under two normalizations. Standardization and max-abs highlight
# different features purely because of the normalization choice. Reads the
# already-computed results; data is produced by
# scripts/experiments/realdata_paths.jl.

using DataFrames
using JSON
using LaTeXStrings
using NormReg
using Plots
using ProjectRoot

set_plot_defaults(target = "poster")

dataset_choice = "w1a"
norm_order = ["std", "max_abs"]
norm_label = Dict("std" => "Standardization", "max_abs" => "Max–Abs")

json_data = JSON.parsefile(@projectroot("results", "realdata_paths.json"))
df = subset(DataFrame(json_data), :dataset => d -> d .== dataset_choice)

plots = []
n_cols = length(norm_order)

for (j, normalization) in enumerate(norm_order)
    dd = subset(df, :normalization => n -> n .== normalization)

    betas = Float64.(mapreduce(permutedims, vcat, dd.betas[1]))'   # p × n_lambda

    n_choose = 70
    betas = betas[:, 1:n_choose]

    # Highlight the features that are first to enter (at the step where at least
    # five are nonzero); grey out the rest.
    first_five = findfirst(dropdims(sum(betas .!= 0, dims = 1) .>= 5, dims = 1))
    var_ind = findall(Array(betas[:, first_five]) .!= 0)

    coefs = betas ./ maximum(abs.(betas))
    n_lambda = size(coefs, 2)
    x_var = 1:n_lambda

    var_grey = findall(dropdims(sum(betas .!= 0, dims = 2) .> 0, dims = 2))
    grey_vars = setdiff(var_grey, var_ind)

    yformatter = j == 1 ? :auto : _ -> ""
    yguide = j == 1 ? L"\hat\beta / \max_j |\hat\beta_j|" : ""

    p = plot(
        legend = false,
        title = norm_label[normalization],
        xlabel = "Step",
        ylims = (-0.7, 1.1),
        yguide = yguide,
        yformatter = yformatter,
    )

    for i in grey_vars
        plot!(p, Array(x_var), coefs[i, :], color = :gray80)
    end
    for i in var_ind
        plot!(p, Array(x_var), coefs[i, :], color = i)
    end

    push!(plots, p)
end

pl = plot(plots..., layout = (1, n_cols), size = (900, 420))

out = @projectroot("posters", "icml2026", "figures", "realdata_paths.pdf")
mkpath(dirname(out))
save_poster(pl, out)
println("wrote ", out)
