using DataFrames
using Plots
using JSON
using LaTeXStrings
using ProjectRoot
using NormReg
using StatsBase

set_plot_defaults()

file = @projectroot("results", "orthogonality.json")

json_data = JSON.parsefile(file)

df = DataFrame(json_data);

function plot_orthogonality(df, rho, i)
  df = filter(row -> !any(x -> x === nothing, vcat(row.beta...)), df)
  df_subset = subset(df, :rho => r -> r .== rho)
  grouped_df = groupby(df_subset, :q)

  result = combine(grouped_df) do gdf
    # Extract beta values into a matrix
    b = gdf.beta
    beta_matrix = reduce(hcat, [vec[1] for vec in b])

    # Calculate means of each column (beta component)
    beta1_mean = mean(beta_matrix[1, :])
    beta2_mean = mean(beta_matrix[2, :])

    # Calculate standard errors
    n = size(beta_matrix, 2)
    beta1_std = std(beta_matrix[1, :]) / sqrt(n)
    beta2_std = std(beta_matrix[2, :]) / sqrt(n)

    # Calculate 95% confidence intervals (using 1.96 for approx. 95% CI)
    beta1_ci = 1.96 * beta1_std
    beta2_ci = 1.96 * beta2_std

    # Return as a named tuple
    return (
      beta1_mean = beta1_mean,
      beta2_mean = beta2_mean,
      beta1_ci = beta1_ci,
      beta2_ci = beta2_ci,
    )
  end

  # Sort the result DataFrame by q values to ensure proper line plotting
  sort!(result, :q)

  # Extract data for plotting
  q_values = result.q
  beta1_means = result.beta1_mean
  beta2_means = result.beta2_mean
  beta1_upper = beta1_means .+ result.beta1_ci
  beta1_lower = beta1_means .- result.beta1_ci
  beta2_upper = beta2_means .+ result.beta2_ci
  beta2_lower = beta2_means .- result.beta2_ci

  # Create the plot
  title = L"\rho = %$(rho)"
  ylabel = i == 1 ? L"\hat{\boldsymbol{\beta}}" : ""
  yformatter = i == 1 ? :auto : _ -> ""
  legend = i == 3 ? :topright : nothing
  xlabel = i == 2 ? L"q_2" : ""

  p = plot(
    q_values,
    beta1_means,
    ribbon = (beta1_means .- beta1_lower, beta1_upper .- beta1_means),
    fillalpha = 0.3,
    label = L"\hat{\beta}_1",
    yformatter = yformatter,
    xlabel = xlabel,
    ylabel = ylabel,
    ylims = (-0.03, 0.67),
    xlims = (0.47, 0.93),
    title = title,
    legend = legend,
  )

  plot!(
    p,
    q_values,
    beta2_means,
    ribbon = (beta2_means .- beta2_lower, beta2_upper .- beta2_means),
    fillalpha = 0.3,
    label = L"\hat{\beta}_2",
  )
end

plots = []

for (i, rho) in enumerate(unique(df.rho))
  push!(plots, plot_orthogonality(df, rho, i))
end

pl = plot(plots..., layout = (1, length(plots)), size = (FULL_WIDTH * 0.9, 220))

file_path = @projectroot("plots", "orthogonality.pdf")
savefig(pl, file_path)
