using LinearAlgebra

function st(u::Float64, λ::Float64)
  sign(u) * max(abs(u) - λ, 0.0)
end

function ridge(
  x::AbstractMatrix{<:Real},
  y::Vector{<:Real},
  λ::Vector{<:Real},
  w2::Vector{<:Real};
  fit_intercept::Bool = true,
)
  n, p = size(x)

  betas = zeros(p, length(λ))
  intercepts = zeros(length(λ))

  if fit_intercept
    x = hcat(ones(n), x)
    w2 = vcat([0.0], w2)
  end

  if n >= p
    xtx = x' * x
    xty = x' * y

    for i in 1:length(λ)
      res = (xtx + Diagonal(w2 * λ[i])) \ xty

      intercepts[i] = res[1]
      betas[:, i] = res[2:end]
    end
  else
    U, σ, Vt = svd(x)
    V = Vt'

    ind = findall(σ .> max(0, minimum(size(x)) * eps(eltype(x))) * σ[1])

    Ux = U[:, ind]
    σx = σ[ind]
    Vx = V[:, ind]

    Rx = Ux * Diagonal(σx)
    RxtRx = Rx'Rx
    Rxty = Rx'y

    for i in 1:length(λ)
      res = Vx * inv(RxtRx + Diagonal(w2 * λ[i])) * Rxty

      intercepts[i] = res[1]
      betas[:, i] = res[2:end]
    end
  end

  return betas, intercepts
end

function cdsolver(
  x::AbstractMatrix{<:Real},
  y::Vector{<:Real},
  lambda1::Vector{<:Real},
  lambda2::Vector{<:Real},
  L::Vector{<:Real} = vec(sum(x .^ 2, dims = 1)),
  intercept::Real = 0.0,
  beta::Vector{<:Real} = zeros(size(x, 2));
  max_it::Int = 10000,
  tol::Real = 1e-6,
  fit_intercept::Bool = true,
)
  n, p = size(x)

  residual = copy(y)

  primals = zeros(max_it)
  duals = zeros(max_it)
  gaps = zeros(max_it)

  for it in 1:max_it
    # if it % 10 == 0
    # check convergence via duality gap
    residual = y - x * beta .- intercept
    primal =
      0.5 * dot(residual, residual) +
      sum(lambda1 .* abs.(beta)) +
      0.5 * sum(lambda2 .* (beta .^ 2))

    theta = -residual

    dual_scaling = max(1.0, norm((x' * theta + lambda2 .* beta) ./ lambda1, Inf))

    dual = (
      0.5 * norm(y)^2 - 0.5 * norm(y .+ theta / dual_scaling)^2 -
      0.5 * sum(lambda2 .* (beta ./ dual_scaling) .^ 2)
    )

    gap = primal - dual

    primals[it] = primal
    duals[it] = dual
    gaps[it] = gap

    if gap <= tol * primal
      break
    end

    for j in 1:p
      if L[j] == 0.0
        continue
      end
      beta_old = beta[j]
      beta[j] =
        st(beta[j] + x[:, j]' * residual / L[j], lambda1[j] / L[j]) /
        (1.0 + lambda2[j] / L[j])
      diff = beta_old - beta[j]
      if diff != 0
        residual .+= diff .* x[:, j]
      end
    end

    if fit_intercept
      intercept_update = mean(residual)
      residual .-= intercept_update
      intercept += intercept_update
    end
  end

  return beta, intercept, primals, duals, gaps
end

function elasticnet(
  x::AbstractMatrix{<:Real},
  y::Vector{<:Real},
  α::Real = 1,
  λ::Union{Nothing,Vector{<:Real}} = nothing,
  w1::Vector{<:Real} = ones(size(x, 2)),
  w2::Vector{<:Real} = ones(size(x, 2));
  fit_intercept::Bool = true,
  path_length::Int = 100,
  kwargs...,
)
  n, p = size(x)

  if isnothing(λ)
    λminratio = n > p ? 1e-2 : 1e-4
    xty = fit_intercept ? x' * (y .- mean(y)) : x'y
    λmax = maximum(abs.(xty) ./ (max(1e-6, α) * w1))
    λ = collect(logspace(λmax, λmax * λminratio, path_length))
  end

  if α == 0
    return ridge(x, y, λ, w2, fit_intercept = fit_intercept)
  end

  L = vec(sum(x .^ 2, dims = 1))

  intercept = 0.0
  beta = zeros(p)

  path_length = length(λ)

  intercepts = zeros(path_length)
  betas = zeros(p, path_length)

  for i in 1:path_length
    lambda1 = w1 .* α * λ[i]
    lambda2 = w2 .* (1 - α) * λ[i]

    beta, intercept, _, _, _ = cdsolver(
      x,
      y,
      lambda1,
      lambda2,
      L,
      intercept,
      beta;
      fit_intercept = fit_intercept,
      kwargs...,
    )

    betas[:, i] = beta
    intercepts[i] = intercept
  end

  return betas, intercepts
end
