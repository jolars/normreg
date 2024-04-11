using Distributions
using SpecialFunctions

function binary_mean(β, n, q, s)
  return β * n * (q - q^2) / s
end

function binary_stddev(σe, n, q, s)
  v = σe^2 * n * (q - q^2) / s^2
  return sqrt(v)
end

function binary_d(n, q, s, λ, α = 1)
  return n * (q - q^2) / s + s * (1 - α) * λ
end

function binary_expected_value(θ, γ, σ, d; print_components = false)
  X = Normal(0, 1)

  tmp = -θ * cdf(X, θ / σ) - σ * pdf(X, θ / σ) + γ * cdf(X, γ / σ) + σ * pdf(X, γ / σ)

  if print_components
    println(-θ * cdf(X, θ / σ) / d + γ * cdf(X, γ / σ) / d)
    println((σ / d) * (pdf(X, γ / σ) - pdf(X, θ / σ)))
  end

  return tmp / d
end

function binary_variance(θ, γ, σ, d)
  X = Normal()

  u = γ / σ

  a1 =
    (σ^2 / sqrt(2 * pi)) *
    (sqrt(pi) * erf(u / sqrt(2)) / sqrt(2) - u * exp(-u^2 / 2) + sqrt(pi / 2))
  a2 = 2 * γ * σ * pdf(X, γ / σ)
  a3 = γ^2 * cdf(X, γ / σ)

  a = a1 + a2 + a3

  v = θ / σ

  b1 =
    (σ^2 / sqrt(2 * pi)) *
    (sqrt(pi) * erf(v / sqrt(2)) / sqrt(2) - v * exp(-v^2 / 2) + sqrt(pi / 2))
  b2 = 2 * θ * σ * pdf(X, θ / σ)
  b3 = θ^2 * cdf(X, θ / σ)

  b = b1 + b2 + b3

  return (1 / d^2) * (a + b) - binary_expected_value(θ, γ, σ, d)^2
end

function binary_selection_prob(β, n, q, delta, lambda, σe)
  X = Normal()

  s = (q - q^2)^delta

  lambda = lambda / (0.5 - 0.5^2)^delta

  X = Normal()
  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)

  prob = cdf(X, (μ - lambda) / σ) + cdf(X, (-μ - lambda) / σ)

  return prob, lambda
end
