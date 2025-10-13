using NormReg
using Test
using QuadGK
using StatsBase
using Distributions
using Statistics

function st(x, λ)
    return sign(x) * max(abs(x) - λ, 0)
end

function int(f, a, b)
    return quadgk(f, a, b)[1]
end

@testset "bias-variance" begin
    q = 0.99
    β = 1
    σe = 2
    n = 100

    λ = β * n * 0.9

    for method in ["std", "var", "none"]
        if method == "var"
            s = q * (1 - q)
        elseif method == "std"
            s = sqrt(q * (1 - q))
        elseif method == "none"
            s = 1
        end

        x = zeros(n)
        x[1:ceil(Int, n * q)] .= 1

        xs = (x .- mean(x)) / s

        y = x * β + rand(Normal(0, σe), n)
        z = xs' * y

        μ = binary_mean(β, n, q, s)
        σ = binary_stddev(σe, n, q, s)
        d = binary_d(n, q, s, λ)

        # empirical
        n_z = 100_000

        Z = Normal(μ, σ)
        z = rand(Z, n_z)

        st_z = st.(z, λ) / d
        bias_emp = mean(st_z) - β
        var_emp = var(st_z)
        mse_emp = mean((st_z .- β) .^ 2) # var_emp + bias_emp^2

        # theoretical
        θ = -(μ + λ)
        γ = μ - λ

        eβ = binary_expected_value(θ, γ, σ, d)
        v = binary_variance(θ, γ, σ, d)

        bias = eβ - β

        @test abs(bias_emp - bias) < 0.1
        @test abs(var_emp - v) < 0.1
    end
end
