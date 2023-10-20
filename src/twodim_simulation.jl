include("generate_twodim_data.jl")

# function twodim_sim(σ=0.5, p=0.5, corr=0, λ; n=1000, seed=1)
#
#
#   d_normal = Normal(0, sigma)
#
# end

x = generate_twodim_data(10000, ρ = 0.5, μ = 100, σ = 2)

cor(x)

mean(x, dims = 1)
std(x, dims = 1)
