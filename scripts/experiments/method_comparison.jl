using Random
using NormReg
using CSV
using DataFrames
using ProjectRoot
using Distributions

grid_size = 100
datasets = [
    "housing",
    "rhee2006",
    "a1a",
    "w1a",
    "triazines",
    "eunite2001",
    "heart",
    "australian",
    "leukemia",
]
norm_methods = ["ours", "std", "max_abs", "min_max", "l1"]
res = DataFrame(
    alpha = Real[],
    dataset = String[],
    response = String[],
    method = String[],
    delta = Real[],
    lambda = Real[],
    err = Real[],
    lo = Real[],
    hi = Real[],
)

# deltas = collect(range(0, 1, length = grid_size));
deltas = collect(range(0, 1, length = 21));
alphas = [0, 1]

target = "nmse"

for alpha in alphas
    for (seed, dataset) in enumerate(datasets)
        for norm_method in norm_methods
            x, y = datagrabber(dataset)

            binary_response = dataset in ["heart", "australian", "a1a", "w1a", "leukemia"]

            dist = if binary_response
                Binomial()
            else
                Normal()
            end

            if binary_response
                y .= Int.(y .> 0.5)
            end

            test_error, ci_low, ci_high, best_delta, best_lambda, avg_error = cross_validate(
                x,
                y,
                Normal(),
                norm_method,
                alpha,
                deltas,
                10,
                target,
                seed = seed,
                repeats = 10,
            )

            df = DataFrame(
                alpha = alpha,
                dataset = dataset,
                response = binary_response ? "binary" : "continuous",
                method = norm_method,
                delta = best_delta,
                lambda = best_lambda,
                err = test_error,
                lo = ci_low,
                hi = ci_high,
            )

            res = vcat(res, df)
        end
    end
end

# res

outfile = @projectroot("results", "method_comparison.csv")

open(outfile, "w") do f
    CSV.write(f, res)
end
