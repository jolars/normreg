using DataFrames
using NormReg
using JSON
using LaTeXStrings
using Plots

json = JSON.parsefile(here("data", "lasso_ridge_twodim.json"))

df = DataFrame(json)

df_subset = subset(df, :rho => r -> r .== 0.0)

plots = []

groups = (groupby(df_subset, [:alpha, :normalization], sort = true))

NormReg.setPlotSettings()

for (i, d) in enumerate(groups)
  lasso = d.alpha[1] == 1
  p = plot(legend = false)

  labels = ["normal" "binary"]
  legend = i == 4 ? true : false

  yguideposition = :left
  yguide = ""

  if mod(i, 4) == 0
    yguide = d.alpha[1] == 1 ? "lasso" : "ridge"
    yguideposition = :right
  elseif mod(i + 3, 4) == 0
    yguide = L"\beta"
  end

  betas = Float64.(mapreduce(permutedims, vcat, d.betas[1]))

  plot!(
    d.ps[1],
    betas,
    yguide = yguide,
    yguideposition = yguideposition,
    legend = legend,
    label = labels,
    xticks = 0.5:0.25:1.0,
  )

  if i <= ceil(length(groups) / 2)
    title!(string(d.normalization[1]))
  else
    xlabel!(L"q")
  end

  push!(plots, p)
end

n_rows = length(unique(df.alpha))
n_cols = length(unique(df.normalization))

plot_output =
  plot(plots..., layout = (n_rows, n_cols), ylim = (0, 0.9), size = (450, 400))

file_path = here("plots", "lasso_ridge_twodim.pdf")

savefig(plot_output, file_path)
