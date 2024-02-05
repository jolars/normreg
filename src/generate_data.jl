using Random
using Distributions
using Base

logspace(start, last, count) = Iterators.map(exp, range(log(start), log(last), count))

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
function generate_binary_gaussian_features(n; μ = 0, σ = 0.5, p = 0.5, ρ = 0)
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

function generate_binary_data(n, p, k, q_type, beta_type = "constant", snr = 1)
  x = zeros(n, p)

  β = zeros(p)

  if beta_type == "constant"
    β[1:k] .= 1
  elseif beta_type == "linear"
    β[1:k] .= collect(range(1, 0.1, length = k))
  elseif beta_type == "geometric"
    β[1:k] .= collect(logspace(1.0, 0.0, k))
  else
    error("beta_type not supported")
  end

  q = collect(logspace(0.5, 0.99, k))

  for i in 1:p
    if i <= k
      if q_type == "decreasing"
        X = Bernoulli(q[i])
      elseif q_type == "balanced"
        X = Bernoulli(0.5)
      elseif q_type == "imbalanced"
        X = Bernoulli(0.9)
      elseif q_type == "very_imbalanced"
        X = Bernoulli(0.99)
      else
        error("q_type not supported")
      end
    else
      q_i = rand(Uniform(0.5, 0.99), 1)
      X = Bernoulli(q_i[1])
    end

    x[:, i] = rand(X, n)
  end

  σ = √(var(x * β) / snr)
  y = x * β .+ rand(Normal(0, σ), n)

  return x, y, β
end
