using Random
using Distributions

"""
    generate_binary_gaussian_features(n; μ = 0, σ = 1, p = 0.5, ρ = 0)

Generate two-dimensional data consisting of a feature with normally dsitributed
data with mean `μ` and standard deviation `σ`, and a binary feature with Bernoulli
distributed data with parameter `p`.

# Arguments
- `n::Int`: Number of observations to generate.
- `μ::Real`: Mean of the normally distributed feature. Default is 0.
- `σ::Real`: Standard deviation of the normally distributed feature. Default is 1.
- `p::Real`: Class balance for the resulting Bernoulli distributed data. Default is 0.5.
- `ρ::Real`: Correlation coefficient between the two features. Default is 0.

# Returns
- `Array{Float64, 2}`: Generated data points. The first column represent the normally distributed data, and the second the Bernoulli distributed data.
"""
function generate_binary_gaussian_features(n; μ = 0, σ = 1, p = 0.5, ρ = 0)
  X = Normal(0, 1)

  x = rand(X, n)
  z = rand(X, n)

  q = quantile(X, 1 - p)

  r = ρ * √(p * (1 - p)) / pdf(X, q)

  y = r * x .+ √(1 - r^2) * z

  # Modify standard deviation and mean
  y = (y * σ) .+ μ

  b = Int64.(x .>= q)

  return [y b]
end
