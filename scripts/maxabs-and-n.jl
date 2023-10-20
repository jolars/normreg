using DrWatson
@quickactivate "normreg"

include(srcdir("preprocessing.jl"))

using Random
using Distributions
using Statistics
using Lasso
using Plots

function expvalue_gev(n)
  γ = 0.57721566490153286060651209008240243 # Euler-Mascheroni constant

  return sqrt(log(n^2 / (2 * π * log(n^2 / (2 * π))))) * (1 + γ / log(n))
end

ns = Int64.(round.(range(10, 1000, length=1000)))

# ev = expvalue_gev.(ns)
#
# plot(ns, ev, ylims=[0, Inf])


Random.seed!(1234)

m = 100

sigma = 0.5
p = 0.5

d_normal = Normal(0, sigma)
d_binary = Bernoulli(p)

betas = zeros(2, length(ns))

lambda = [0.2]

for i in eachindex(ns)
  n = ns[i]
  x1 = rand(d_normal, n)
  x2 = rand(d_binary, n)

  x = [x1 x2]
  beta = [1.0, 1.0]

  y = x * beta + rand(Normal(0, 1), n)

  x, centers, scales = normalize(x, "max_abs")
  model = Lasso.fit(Lasso.LassoPath, x, y, Normal(), standardize=false, λ=lambda)
  betas[:, i] = model.coefs
end

# fit = Lasso.fit(Lasso.LassoPath, x, y, Normal(), standardize=false, λ=lambda)
# fit.coefs
#
plot(ns, betas[1, :], label="normal")
plot!(ns, betas[2, :], label="binary")


n = 100

x1 = rand(d_normal, n)
x2 = rand(d_binary, n)

x = [x1 x2]
beta = [1.0, 1.0]

y = x * beta + rand(Normal(0, 1), n)
y = y .- mean(y)

# x, centers, scales = normalize(x, "max_abs")
y = x * beta
x = [x1 / 100 x2]

modelnew = (x'x) \ x'y
model = Lasso.fit(Lasso.LassoPath, x, y, Normal(), standardize=false, λ=[0.001], intercept=false)
model.coefs

