using NormReg
using CSV
using DataFrames
using ProjectRoot

function datatype(a)
  return length(unique(a)) <= 2 ? "binary" : "continuous"
end

function propones(a)
  sum(a .== mode(a)) / length(a)
end

datasets = ["a1a", "w1a", "rhee2006", "housing", "leukemia", "triazines"]

res = DataFrame(dataset = [], n = [], p = [], response = [], design = [], q = [])

for dataset in datasets
  x, y = datagrabber(dataset)

  n, p = size(x)

  response_type = datatype(y)
  feature_types = map(datatype, eachcol(x))
  design_type = all(feature_types .== feature_types[1]) ? feature_types[1] : "mixed"

  mean_q = if design_type in ["mixed" "binary"]
    median(map(propones, eachcol(x[:, feature_types .== "binary"])))
  else
    NaN
  end

  df = DataFrame(
    dataset = dataset,
    n = n,
    p = p,
    response = response_type,
    design = design_type,
    q = mean_q,
  )
  res = vcat(res, df)
end

outfile = @projectroot("data", "data_summary.csv");

open(outfile, "w") do f
  CSV.write(f, res)
end
