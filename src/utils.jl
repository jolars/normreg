using CSV
using DataFrames
using Distributions
using ProjectRoot
using Statistics

function confidence_interval(x, level = 0.95)
  n = length(x)

  alpha = 1 - level

  q = quantile(TDist(n - 1), 1 - alpha / 2)
  se = std(x) / sqrt(n)

  return (mean(x) - q * se, mean(x) + q * se)
end

function confidence_error(x, level = 0.95)
  n = length(x)

  alpha = 1 - level

  q = quantile(TDist(n - 1), 1 - alpha / 2)
  se = std(x) / sqrt(n)

  return q * se
end

function datagrabber(dataset)
  if dataset in ["rhee2006"]
    xy = CSV.read(@projectroot("data", "$(dataset).csv"), DataFrame)
    y = xy[:, 1]
    x = Matrix(xy[:, 2:end])

    return x, y
  else
    x, y = load_dataset(dataset, dense = false, replace = false, verbose = false)

    density = sum(x .!= 0) / (size(x, 1) * size(x, 2))

    if density > 0.2
      return Matrix(x), y
    else
      return x, y
    end
  end
end
