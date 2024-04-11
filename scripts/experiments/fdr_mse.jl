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

function fdr_mse_sim(
  q_signal::Real,
  σe::Real,
  δ::Real,
  n::Int64 = 1_000,
  λ_in::Real = 0.5,
  p::Int64 = 1_000,
  k::Int64 = 10,
)
  Random.seed!(1001)

  mse_sum = 0

  # qs = collect(range(0.5, 0.999, length = ceil(Int64, p - k)))
  qs = collect(logspace(0.5, 0.99, ceil(Int64, p - k)))

  fdp = 0
  dr = 0
  power = 1

  for j in 1:p
    if j <= k
      # signal
      β = 2
      q = q_signal
    else
      # noise
      β = 0
      q = qs[j - k]
    end

    s = (q - q^2)^δ

    λ = n * 2 * λ_in / (0.5 - 0.5^2)^δ

    μ = binary_mean(β, n, q, s)
    σ = binary_stddev(σe, n, q, s)
    d = binary_d(n, q, s, λ)

    θ = -(μ + λ)
    γ = μ - λ

    eβ = binary_expected_value(θ, γ, σ, d)
    v = binary_variance(θ, γ, σ, d)

    bias = eβ - β
    mse = bias^2 + v

    X = Normal()

    prob = cdf(X, (μ - λ) / σ) + cdf(X, (-μ - λ) / σ)

    dr += prob

    if j <= k
      # Compute power for signals
      power *= prob
    else
      # Compute false discovery rate for noise
      fdp += prob
    end

    mse_sum += mse
  end

  fdr = dr == 0 ? 1 : fdp / dr

  return mse_sum, fdr, power
end

param_dict = Dict{String,Any}(
  "q" => [0.5, 0.9, 0.99],
  "p" => collect(20:10:100),
  "sigma_e" => [1],
  "delta" => [0, 1 / 2, 1.0],
  "lambda" => [0.05],
);

param_expanded = dict_list(param_dict);

results = []

for (i, d) in enumerate(param_expanded)
  @unpack q, p, sigma_e, delta, lambda = d

  n = 100
  k = 10

  mse, fdr, power = fdr_mse_sim(q, sigma_e, delta, n, lambda, p, k)

  d_exp = copy(d)
  d_exp["mse"] = mse
  d_exp["fdr"] = fdr
  d_exp["power"] = power

  push!(results, d_exp)
end

df = DataFrame(results);
df_long = stack(df, Not([:q, :p, :sigma_e, :delta, :lambda, :power]));

n_rows = length(unique(df_long.variable))
n_cols = length(unique(df.q))

grouped_df = groupby(df_long, [:variable])

plots = []

colors = delta_palette(3:5)

for (i, d) in enumerate(grouped_df)
  # subgrouped_df = groupby(df_long, [:q])
  subgrouped_df = groupby(d, [:q])

  for (j, dd) in enumerate(subgrouped_df)
    variable = dd.variable[1]

    if j == 1
      ylab = variable == "mse" ? "NMSE" : "FDR"
    else
      ylab = ""
    end

    title_stump = unique(dd.q)[1]

    title = i == 1 ? L"q = %$(title_stump)" : ""

    xlab = j == 2 && i == n_rows ? L"p" : ""

    xformatter = i == n_rows ? :auto : _ -> ""

    ylims = (0, 1.1)

    if variable == "mse"
      dd.value .= dd.value ./ maximum(dd.value)
    end

    yformatter = j == 1 ? :auto : _ -> ""

    pl = @df dd plot(
      :p,
      :value,
      groups = :delta,
      ylabel = ylab,
      xlabel = xlab,
      xformatter = xformatter,
      yformatter = yformatter,
      title = title,
      ylims = ylims,
      xlims = (15, 105),
      legend = false,
      color = colors,
    )

    push!(plots, pl)
  end
end

lab = reshape(unique(df.delta), 1, length(unique(df.delta)))
labvals = zeros(1, length(lab))

legend = plot(
  labvals,
  showaxis = false,
  grid = false,
  label = lab,
  legend_position = :topleft,
  frametitle = :none,
  legend_title = L"\delta",
  background_color_subplot = :transparent,
  color = colors,
)

l = @layout[grid(n_rows, n_cols) a{0.2w}]

fdr_mse_plot = plot(plots..., legend, layout = l, size = (FULL_WIDTH * 0.6, 250))

savefig(fdr_mse_plot, @projectroot("paper", "plots", "fdr_mse.pdf"))
