using Random
using Statistics
using Distributions

rho = 0.7

dist = Normal()

n = 10000

x = randn(n);
y = rho * x + sqrt(1 - rho^2) * randn(n);

cor(x, y)

kappa = 0.5

z = [z_i > quantile(x, kappa) for z_i in x]

rho * pdf(dist, quantile(dist, kappa)) / sqrt(kappa * (1 - kappa))

cor(z, y)
