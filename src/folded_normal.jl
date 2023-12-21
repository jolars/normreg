using Distributions
using Roots

@kwdef struct FoldedNormal
  μ::Real = 0
  σ::Real = 1
end

function Distributions.pdf(d::FoldedNormal, x::Real)
  A = Normal(d.μ, d.σ)
  B = Normal(-d.μ, d.σ)

  pdf(A, x) + pdf(B, x)
end

function Distributions.cdf(d::FoldedNormal, q::Real)
  A = Normal(d.μ, d.σ)
  B = Normal(-d.μ, d.σ)

  out = cdf(A, q) + cdf(B, q) - 1
  out = max.(out, 0)

  out
end

function Distributions.quantile(d::FoldedNormal, p::Real)
  f(q) = cdf(d, q) - p

  lo = d.μ - 4 * d.σ
  hi = d.μ + 4 * d.σ

  find_zero(f, (-lo, hi), Bisection())
end
