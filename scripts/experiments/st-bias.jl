using Distributions

function st(x, λ)
  return sign(x) * max(abs(x) - λ, 0)
end

function integrate(f, d, a = -15, b = -15; n = 100_000)
  x = range(a, b, length = n)
  dx = (b - a) / n
  return sum(f.(x) .* pdf.(d, x) * dx)
end

snorm = Normal()
ϕ(x) = pdf(Normal(), x)
Φ(x) = cdf(Normal(), x)

μ = 2.5;
# μ = 1e7;
σ = 1.8;
dist = Normal(μ, σ);

λ = 2

inf = 50

x = rand(dist, 100_000);

st_x = st.(x, λ);
bias_emp = mean(st_x) - μ
var_emp = var(st_x)
mse_emp = mean((st_x .- μ) .^ 2) # var_emp + bias_emp^2

bias_th = integrate(x -> x + λ, dist, -inf, -λ) + integrate(x -> x - λ, dist, λ, inf) - μ
e2 = integrate(x -> (x + λ)^2, dist, -inf, -λ) + integrate(x -> (x - λ)^2, dist, λ, inf)
var_th = e2 - bias_th^2

# theoretical MSE
integrate(x -> (x + λ - μ)^2, dist, -inf, -λ) +
integrate(x -> (x - λ - μ)^2, dist, λ, inf) +
μ^2 * integrate(x -> 1, dist, -λ, λ)

μ = 100

r =
  integrate(x -> (σ * x + λ)^2, snorm, -inf, (-λ - μ) / σ) +
  integrate(x -> (σ * x - λ)^2, snorm, (λ - μ) / σ, inf) +
  μ^2 * integrate(x -> 1, snorm, (-λ - μ) / σ, (λ - μ) / σ)
