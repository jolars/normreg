using LinearAlgebra
using Random
using LIBSVMdata
using Statistics

dataset = "leukemia"

x, y = load_dataset(dataset, dense = true, replace = false, verbose = false);

n, p = size(x)

α = 0.0

Random.seed!(1234)
w2 = rand(Float64, p)

w2 = w2 * p / sum(w2);

residual = y .- mean(y)

xtx = x'x;
xty = x'y;

tmp = abs.(x'residual) / 1e-3
max_ind = argmax(tmp)
λmax = tmp[max_ind]

λ = λmax / 1000

# standard version
x1 = hcat(ones(n), x)
res1 = (x1'x1 + λ .* Diagonal(vcat([0.0], w2))) \ x1'y;

W = Diagonal(λ * w2)
W⁻ = Diagonal(1 ./ (λ * w2))

# display(res1)
# kk

# block inverse
A⁻ = (1 / λ) * W⁻ .- (1 / λ^2) * W⁻ * x' * (I(n) + (1 / λ) * x * W⁻ * x')^-1 * x * W⁻
C = ones(n)'x
S = n - C * A⁻ * C'

B = A⁻ * (I(p) + (1 / S) * I(p) * (C' * C) * A⁻)
