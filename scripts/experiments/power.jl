using Distributions
using Plots
using Random
using LaTeXStrings
using StatsPlots
using NormReg
using DrWatson
using DataFrames
using ProjectRoot
using Plots.PlotMeasures

set_plot_defaults()

function power_sim(
  q::Real,
  σe::Real,
  δ::Real,
  n::Int64 = 1_000,
  λ_in::Real = 0.5,
  k::Int64 = 10,
)
  Random.seed!(1001)

  power = 1
  β = 2

  for j in 1:k
    s = (q - q^2)^δ

    λ = n * 2 * λ_in / (0.5 - 0.5^2)^δ

    μ = binary_mean(β, n, q, s)
    σ = binary_stddev(σe, n, q, s)

    X = Normal()

    prob = cdf(X, (μ - λ) / σ) + cdf(X, (-μ - λ) / σ)

    if j <= k
      # Compute power for signals
      power *= prob
    end
  end

  return power
end

param_dict = Dict{String,Any}(
  "q" => collect(range(0.5, 0.99, 100)),
  "sigma_e" => [1],
  "delta" => [0, 1 / 2, 1.0],
  "lambda" => [0.05],
);

param_expanded = dict_list(param_dict);

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, sigma_e, delta, lambda = d

  n = 100
  k = 10

  power = power_sim(q, sigma_e, delta, n, lambda, k)

  d_exp = copy(d)
  d_exp["power"] = power

  push!(results, d_exp)
end

df = DataFrame(results);
df_sorted = sort(df, :delta);
df_power = unique(select(df_sorted, [:q, :delta, :power]));
df_power.delta = string.(df_power.delta);

colors = delta_palette([1, 3, 5])

power_plot = @df df_power plot(
  :q,
  :power,
  group = :delta,
  ylab = "Power",
  xlab = L"q",
  legend_title = L"\delta",
  ylims = (0, 1.05),
  legend_position = :bottomleft,
  legend_background_color = :transparent,
  size = (FULL_WIDTH * 0.37, 230),
  color = colors,
)

savefig(power_plot, @projectroot("plots", "power.pdf"))
