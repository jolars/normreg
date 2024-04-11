
using Random
using LinearAlgebra
using Distributions
using DrWatson
using Statistics
using DataFrames
using Lasso
using Plots
using JSON
using ProjectRoot
using NormReg

α = 1
delta = 1
snr = 0.01
sigma = 0.1
n_it = 100
n_qs = 100
n = 1000
p = 1
σe = 2
λ = 0.4

beta = [1]
betas = zeros(p, n_qs)

betas_theoretical = zeros(1, n_qs)

qs = range(0.5, 0.999, length = n_qs)
# qs = collect(logspace(0.5, 0.99, n_qs))

for i in 1:n_qs
  λ = 0.4
  beta_hat = zeros(p)
  for _ in 1:n_it
    x1 = generate_pseudobernoulli(n, q = qs[i])

    x = reshape(x1, (n, 1))
    y = x * beta + rand(Normal(0, σe), n)
    # y .-= mean(y)

    x_std, centers, scales = normalize_features(x, delta)

    model = Lasso.fit(
      Lasso.LassoPath,
      x_std,
      y,
      Normal(),
      α = α,
      standardize = false,
      λ = [λ],
      intercept = true,
    )

    _, beta_hat_it = unstandardize_coefficients(model.b0, model.coefs, centers, scales)

    # Compute the average across the iterations
    beta_hat += beta_hat_it / n_it
  end
  betas[:, i] = beta_hat

  # theoretical
  δ = delta
  q = qs[i]

  mod = 0.5 / (0.25^delta)
  s = mod * (q - q^2)^δ

  λ1 = λ * α * n

  β = beta[1]

  μ = binary_mean(β, n, q, s)
  σ = binary_stddev(σe, n, q, s)

  d = binary_d(n, q, s, λ, α)

  θ = -(μ + λ1)
  γ = μ - λ1

  eβ = binary_expected_value(θ, γ, σ, d, print_components = false)
  betas_theoretical[1, i] = eβ
  # v = binary_variance(θ, γ, σ, d)
end

set_plot_defaults("gr")

plot(
  qs,
  [betas' betas_theoretical'],
  ylim = (-0.1, 1.1),
  legend = true,
  labels = ["empirical" "theoretical"],
)

q = 0.9;
x = generate_pseudobernoulli(n, q = q);

x_std, centers, scales = normalize_features(reshape(x, (n, 1)), delta)

s = scales[1]

σe = 2
y = reshape(x, (n, 1)) * beta + rand(Normal(0, σe), n)

mu = x_std' * x .* beta
mu = x_std' * y

mu_theory = beta * n * (q - q^2) / scales[1]

d = s * (x_std' * x_std)
d_theory = n * (q - q^2) / s + s * (1 - α) * λ

(mu .- λ * n) / d

sigma = sqrt(σe^2 * n * (q - q^2) / s^2)

# sigma = 100

# x = rand(Normal(mu, sigma), 1000000)
Z = Normal(mu[1], sigma)

z = rand(Z, 1000)

mean(soft_threshold.(z, λ * n) ./ (d[1]))

model = Lasso.fit(
  Lasso.LassoPath,
  x_std,
  y,
  Normal(),
  α = α,
  standardize = false,
  λ = [λ],
  intercept = true,
)

coef(model) / s

# mean(soft_threshold.(x, mu * 0.9))
