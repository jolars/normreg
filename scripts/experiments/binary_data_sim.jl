using NormReg
using JSON
using DataFrames
using Random
using ProjectRoot
using Lasso
using Statistics
using GLM
using DrWatson

function binary_simulation_varyq_experiment(n, p, s, delta, q, snr)
    beta_type = "constant"

    q_type = if q == 0.5
        "balanced"
    elseif q == 0.9
        "imbalanced"
    elseif q == 0.99
        "very_imbalanced"
    else
        error("q not supported")
    end

    x, y, β_true, _ = generate_binary_data(n, p, s, q_type, beta_type, snr)

    err, _, β_est = holdout_validation(x, y, Normal(), delta, "nmse", 0.5)

    return err, β_est, β_true
end

local snr = collect(logspace(0.05, 6, 10))

param_dict = Dict(
    "it" => collect(1:100),
    "n" => 300,
    "p" => 1000,
    "k" => 10,
    "delta" => [0, 0.5, 1],
    "q" => [0.5, 0.9, 0.99],
    "snr" => snr,
    "dummy" => "asdf",
)

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
    @unpack it, n, p, k, delta, q, snr = d

    Random.seed!(it)

    err, β_est, β_true = binary_simulation_varyq_experiment(n, p, k, delta, q, snr)

    d_exp = copy(d)
    d_exp["err"] = err
    d_exp["betas"] = β_est

    push!(results, d_exp)
end

outfile = @projectroot("results", "binary_data_sim.json");

open(outfile, "w") do f
    write(f, JSON.json(results))
end
