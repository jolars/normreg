using Distributions
using Roots

"""
    FoldedNormal(μ::Real = 0, σ::Real = 1)

A struct representing a Folded Normal distribution with mean `μ` and standard deviation `σ`.
"""
@kwdef struct FoldedNormal
  μ::Real = 0
  σ::Real = 1
end

"""
    Distributions.pdf(d::FoldedNormal, x::Real)

Compute the probability density function (PDF) of a Folded Normal distribution `d` at a given point `x`.
"""
function Distributions.pdf(d::FoldedNormal, x::Real)
  A = Normal(d.μ, d.σ)
  B = Normal(-d.μ, d.σ)

  pdf(A, x) + pdf(B, x)
end

"""
    Distributions.cdf(d::FoldedNormal, q::Real)

Compute the cumulative distribution function (CDF) of a Folded Normal distribution `d` at a given point `q`.
"""
function Distributions.cdf(d::FoldedNormal, q::Real)
  A = Normal(d.μ, d.σ)
  B = Normal(-d.μ, d.σ)

  out = cdf(A, q) + cdf(B, q) - 1
  out = max.(out, 0)

  out
end

"""
    Distributions.quantile(d::FoldedNormal, p::Real)

Compute the quantile function (inverse CDF) of a Folded Normal distribution `d` for a given probability `p`.
"""
function Distributions.quantile(d::FoldedNormal, p::Real)
  f(q) = cdf(d, q) - p

  lo = d.μ - 5 * d.σ
  hi = d.μ + 5 * d.σ

  find_zero(f, (lo, hi), Bisection())
end
```
