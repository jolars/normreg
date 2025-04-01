using Random
using Statistics
using StatsBase
using Distributions
using NormReg
using DrWatson
using Plots

pythonplot()

set_plot_defaults()

rho = 0.7

dist = Normal()

n = 10000

x = randn(n);
y = rho * x + sqrt(1 - rho^2) * randn(n);

cor(x, y)

kappa = 0.5

z = [z_i > quantile(x, kappa) for z_i in x]

rho * pdf(dist, quantile(dist, kappa)) / sqrt(kappa * (1 - kappa))

cor(z, y)

q = 0.8

x, y = datagrabber("housing")

n, p = size(x)

# National crime rate average US 1970-1971
us_crime = (364.5 + 3277.5 + 396 + 3544.6) / 2

x = Matrix(x)

# Above/below national average crime rate
x[:, 1] = Int.(x[:, 1] .> us_crime / 100000)

# Presence/absence of large lot zoning (>0 vs 0)
x[:, 2] = Int.(x[:, 2] .> 0)

# Residential vs industrial areas (below/above 10% non-retail business acres)
x[:, 3] = Int.(x[:, 3] .> 10)

# Charles River dummy variable

# Above/below EPA air quality standard for NOx (100 parts ber billion)
x[:, 5] = Int.(x[:, 5] / (10 * 10^6) .> 53 / 10^9)

# Rooms per dwelling above/below typical size for family with children
x[:, 6] = Int.(x[:, 6] .> 6)

# Newer vs historic housing (less/more than 50% pre-1940)
x[:, 7] = Int.(x[:, 7] .> 50)

# Close vs far from employment centers (less/more than 5 miles)
x[:, 8] = Int.(x[:, 8] .> 5)

# Limited vs good highway access (index below/above 5)
x[:, 9] = Int.(x[:, 9] .> 20)

# Below/above Massachusetts average property tax rate (~$12 per $1000 in 1970s)
x[:, 10] = Int.(x[:, 10] .> 200)

# Pupil-teacher ratio below/above recommended value
x[:, 11] = Int.(x[:, 11] .> 16)

# More or less diverse population (above/below 85% white)
x[:, 12] = Int.(x[:, 12] .> 85)

# Middle-class vs lower-income areas
x[:, 13] = Int.(x[:, 13] .> 15)

# function dichotomization_experiment(x_in)
#   x = Matrix(x_in)
#
#   for j in 1:p
#     if length(unique(x[:, j])) != 2
#       x[:, j] = Int.(x[:, j] .> quantile(x[:, j], q))
#     end
#   end
#
#   res = elasticnet(x, y, α = 1.0)
# end

# OLS solution
beta_ols = hcat(ones(size(x, 1)), x) \ y
beta_ols = beta_ols[2:end]

# qs = collect(range(0.5, 0.9, length = 3))

methods = ["ours", "std", "min_max"]

param_dict = Dict("method" => methods, "beta" => [zeros(p, 100)])

expanded_params = dict_list(param_dict);

results = [];

for (i, d) in enumerate(expanded_params)
  @unpack method, beta = d

  # Random.seed!(it)

  x_norm, centers, scales = normalize_features_unadjusted(x, method, 1, adjust = false)

  res = elasticnet(x_norm, y, α = 1.0)

  _, beta_out = unstandardize_coefficients(res.β0, res.β, centers, scales)

  order = sortperm([findfirst(row) for row in eachrow(beta_out .!= 0)])
  rank = ordinalrank([findfirst(row) for row in eachrow(beta_out .!= 0)])

  d_exp = copy(d)
  d_exp["beta"] = beta_out
  d_exp["order"] = order
  d_exp["rank"] = rank

  push!(results, d_exp)
end

plots = []

for (i, d) in enumerate(results)
  @unpack method, beta = d

  ylab = i == 1 ? "Coefficient" : ""

  yformatter = i == 1 ? :auto : _ -> ""

  plot_lasso_path(
    abs.(d["beta"]),
    1:p,
    ylims = (-0.2, 7.8),
    ylabel = ylab,
    yformatter = yformatter,
  )
  # scatter!(repeat([60.0], p), abs.(beta_ols_std))

  push!(plots, plot!(title = method))
end

plot(plots..., layout = (1, 3), size = (FULL_WIDTH, 300))

true_order = sortperm(abs.(beta_ols), rev = true)
hcat(true_order, results[1]["order"], results[2]["order"], results[3]["order"])

results[1]["order"]

# plot_lasso_path(abs.(results[1]["beta"]), 1:p)
# scatter!(repeat([60.0], p), abs.(beta_ols_std))
#
# plot_lasso_path(abs.(results[2]["beta"]), 1:p)
# scatter!(repeat([60.0], p), abs.(beta_ols_std))
#
# plot_lasso_path(abs.(results[3]["beta"]), 1:p)
# scatter!(repeat([60.0], p), abs.(beta_ols_std))

# Compare estimated orders against true order
function compare_rankings(true_order, estimated_orders)
  metrics = Dict()

  metrics["spearman"] =
    [corspearman(true_order, est_order) for est_order in estimated_orders]

  # 2. Kendall's tau rank correlation (higher is better)
  metrics["kendall"] = [corkendall(true_order, est_order) for est_order in estimated_orders]

  # 3. Mean absolute difference in ranks (lower is better)
  metrics["mean_abs_diff"] =
    [mean(abs.(true_order .- est_order)) for est_order in estimated_orders]

  # 4. Normalized Discounted Cumulative Gain (higher is better)
  # Focuses on the importance of correct ordering at the top of the list
  function ndcg(true_ranks, pred_ranks)
    n = length(true_ranks)
    # Create relevance scores (higher true rank = higher relevance)
    relevance = n + 1 .- true_ranks

    # Calculate DCG: rel_i / log2(i+1)
    idcg = sum(relevance[sortperm(relevance, rev = true)] ./ log2.(2:(n + 1)))
    dcg = sum(relevance[sortperm(pred_ranks)] ./ log2.(2:(n + 1)))

    return dcg / idcg
  end

  metrics["ndcg"] = [ndcg(true_order, est_order) for est_order in estimated_orders]

  return metrics
end

# Use with your results
true_order = ordinalrank(-abs.(beta_ols))
estimated_orders = [d["rank"] for d in results]
ranking_metrics = compare_rankings(true_order, estimated_orders)

# Print the results
for (metric_name, values) in ranking_metrics
  println("$metric_name: ", values)
  best_idx = metric_name == "mean_abs_diff" ? argmin(values) : argmax(values)
  println("Best method ($metric_name): ", methods[best_idx])
end

# Create a formatted table of results

function print_table()
  println("\n" * "="^72)
  println("Method Comparison Results")
  println("="^72)

  # Header row
  headers = ["Metric", methods..., "Best Method"]
  println(
    rpad("Metric", 15),
    " | ",
    join([rpad(m, 10) for m in methods], " | "),
    " | Best Method",
  )
  println("-"^15 * "-+-" * "-"^10 * "-+-" * "-"^10 * "-+-" * "-"^10 * "-+-" * "-"^15)

  # Data rows
  for (metric_name, values) in ranking_metrics
    best_idx = metric_name == "mean_abs_diff" ? argmin(values) : argmax(values)
    formatted_vals = [round(v, digits = 4) for v in values]
    println(
      rpad(metric_name, 15),
      " | ",
      join([rpad(string(v), 10) for v in formatted_vals], " | "),
      " | ",
      methods[best_idx],
    )
  end

  println("="^72)
end

print_table()

function print_latex_table()
  println("\\begin{table}[htbp]")
  println("  \\centering")
  println("  \\caption{Method Comparison Results}")
  println("  \\label{tab:method_comparison}")
  println(
    "  \\begin{tabular}{l S[table-format=1.4] S[table-format=1.4] S[table-format=1.4]}",
  )
  println("    \\toprule")
  println("    Metric & {", join(methods, "} & {"), "} \\\\")
  println("    \\midrule")

  # Data rows
  for (metric_name, values) in ranking_metrics
    best_idx = metric_name == "mean_abs_diff" ? argmin(values) : argmax(values)
    formatted_vals = []

    for (i, v) in enumerate(values)
      push!(formatted_vals, string(round(v, digits = 4)))
    end

    println("    ", metric_name, " & ", join(formatted_vals, " & "), " \\\\")
  end

  println("    \\bottomrule")
  println("  \\end{tabular}")
  println("\\end{table}")
end

print_latex_table()
