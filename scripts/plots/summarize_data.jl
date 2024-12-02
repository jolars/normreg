using NormReg
using CSV
using DataFrames
using ProjectRoot
using Plots
using StatsPlots

set_plot_defaults()

function datatype(a)
  return length(unique(a)) <= 2 ? "binary" : "continuous"
end

function propones(a)
  sum(a .== mode(a)) / length(a)
end

datasets = ["a1a", "w1a", "rhee2006", "leukemia", "triazines"]

plots = []

for dataset in datasets
  x, y = datagrabber(dataset)

  n, p = size(x)

  response_type = datatype(y)
  feature_types = map(datatype, eachcol(x))
  design_type = all(feature_types .== feature_types[1]) ? feature_types[1] : "mixed"

  q = if design_type in ["mixed" "binary"]
    map(propones, eachcol(x[:, feature_types .== "binary"]))
  else
    continue
  end

  pl = histogram(q, title = dataset, fillcolor = :black, bins = range(0.5, 1, length = 21))

  push!(plots, pl)
end

collect(range(0.5, 1, length = 11))

plot_output = plot(plots...)

savefig(@projectroot("paper", "plots", "data-hist-q.pdf"))
