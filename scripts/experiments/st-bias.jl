using Distributions
using LinearAlgebra
using QuadGK

function st(x, λ)
  return sign(x) * max(abs(x) - λ, 0)
end

function integrate(f, d, a = -15, b = -15; n = 100_000)
  x = range(a, b, length = n)
  dx = (b - a) / n
  return sum(f.(x) .* pdf.(d, x) * dx)
end

function int(f, a, b)
  return quadgk(f, a, b)[1]
end

# function bias(μ, σ)
# mua * cdf(snorm, mua / σ) + σ * pdf(snorm, mua / σ)
#
# mub = -(λ + μ)
#
# mub * cdf(snorm, mub / σ) + σ * pdf(snorm, mub / σ)

snorm = Normal()
ϕ(x) = pdf(Normal(), x)
Φ(x) = cdf(Normal(), x)

# μ = 1e7;
dist = Normal(μ, σ);

q = 0.999
inf = 5
β = 3
σe = 4;
n = 100

x = zeros(n)
x[1:ceil(Int, n * q)] .= 1

xs = (x .- mean(x)) / var(x)

y = x * β + rand(Normal(0, σe), n)
z = xs' * y

s = q * (1 - q)

μ = β * n * q * (1 - q) / s

σ2 = σe^2 * q * (1 - q) / s^2
σ = sqrt(σ2)

Y = Normal()
Z = Normal(μ, σ)

λ = 0.5*μ

n_z = 10_000

z = rand(Z, n_z)

st_z = st.(z, λ);
bias_emp = mean(st_z) - μ
var_emp = var(st_z)
mse_emp = mean((st_z .- μ) .^ 2) # var_emp + bias_emp^2

# bias_th = integrate(x -> x + λ, dist, -inf, -λ) + integrate(x -> x - λ, dist, λ, inf) - μ

lo = (-λ - μ) / σ
up = (λ - μ) / σ
bias_th = integrate(x -> σ*x + λ + μ, snorm, -inf, lo) + integrate(x -> σ * x - λ + μ, snorm, up, inf) - μ

int(x -> (σ * x + λ + μ) * pdf(Normal(), x), -Inf, lo)
int(x -> (σ * x - λ + μ) * pdf(Normal(), x), up, Inf)

mua = μ - λ
mub = -(λ + μ)

-(mub * cdf(snorm, mub / σ) + σ * pdf(snorm, mub / σ)) +
mua * cdf(snorm, mua / σ) + σ * pdf(snorm, mua / σ) - μ

