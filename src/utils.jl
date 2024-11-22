using Distributions
using Statistics

function delta_palette(ind)
  return ColorSchemes.Johnson[ind]'
end

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
