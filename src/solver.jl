using LinearAlgebra
using IterativeSolvers

function st(u::Float64, λ::Float64)
  sign(u) * max(abs(u) - λ, 0.0)
end

function cdsolver(
  x::AbstractMatrix{<:Real},
  y::Vector{<:Real},
  lambda1::Vector{<:Real},
  lambda2::Vector{<:Real},
  L::Vector{<:Real},
  intercept::Real,
  beta::Vector{<:Real},
  working_set::Vector{Int};
  max_it::Int = 100_000,
  tol::Real = 1e-5,
  fit_intercept::Bool = true,
  verbose = false,
)
  n, p = size(x)

  residual = copy(y)

  primals = zeros(max_it)
  duals = zeros(max_it)
  gaps = zeros(max_it)

  lasso = all(lambda2 .== 0.0)

  for it in 1:max_it
    if it % 10 == 0
      # check convergence via duality gap
      residual = y - x[:, working_set] * beta[working_set] .- intercept
      primal =
        0.5 * norm(residual)^2 +
        sum(lambda1[working_set] .* abs.(beta[working_set])) +
        0.5 * sum(lambda2[working_set] .* (beta[working_set] .^ 2))

      theta = -residual

      if lasso
        dual_scaling = max(
          1.0,
          norm(
            (x[:, working_set]' * theta + lambda2[working_set] .* beta[working_set]) ./
            lambda1[working_set],
            Inf,
          ),
        )

        dual =
          0.5 * norm(y)^2 - 0.5 * norm(y .+ theta / dual_scaling)^2 -
          0.5 * sum(lambda2[working_set] .* (beta[working_set] ./ dual_scaling) .^ 2)
      else
        dual =
          -0.5 * norm(theta)^2 - dot(y, theta) -
          0.5 * sum(
            max.(0, abs.(x[:, working_set]' * theta) .- lambda1[working_set]) .^ 2 ./
            lambda2[working_set],
          )
      end

      gap = primal - dual

      primals[it] = primal
      duals[it] = dual
      gaps[it] = gap

      rel_tol = tol * primal

      if verbose
        println("Iteration: $it, gap: $gap, tol: $rel_tol")
      end

      if gap <= rel_tol
        break
      end
    end

    if it == max_it
      @warn("The CD solver did not converge, duality gap: $gap")
    end

    # beta_prev = copy(beta)
    diffs = zeros(p)

    for j in working_set
      if L[j] == 0.0
        continue
      end
      beta_old = beta[j]
      beta[j] =
        st(beta[j] + dot(x[:, j], residual) / L[j], lambda1[j] / L[j]) /
        (1.0 + lambda2[j] / L[j])
      diff = beta_old - beta[j]
      diffs[j] = diff
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
  y::Vector{<:Real};
  α::Number = 1,
  λ::Union{Nothing,Vector{<:Real}} = nothing,
  w1::Vector{<:Real} = ones(size(x, 2)),
  w2::Vector{<:Real} = ones(size(x, 2)),
  fit_intercept::Bool = true,
  path_length::Int = 100,
  devmax::Number = 0.999,
  fdev::Number = 1e-5,
  dfmax = size(x, 2) + 1,
  verbose = false,
  kwargs...,
)
  n, p = size(x)

  intercept = mean(y) * fit_intercept
  residual = y .- intercept

  # w1 = w1 * p / sum(w1)
  # w2 = w2 * p / sum(w2)

  # only screen when l1 penalty is involved
  screen = α > 0

  screened = screen ? zeros(Bool, p) : ones(Bool, p)

  λminratio = n > p ? 1e-4 : 1e-2
  c = x' * (y .- fit_intercept * mean(y))
  tmp = abs.(c) ./ (max(1e-3, α) * w1)
  max_ind = argmax(tmp)
  λmax = tmp[max_ind]

  auto_lambda = isnothing(λ)

  if auto_lambda
    λ = collect(logspace(λmax, λmax * λminratio, path_length))
    if screen
      # turn on the first active variable
      screened[max_ind] = true
    end
  elseif screen
    lambda2 = w2 .* (1 - α) * λ[1]
    screened = abs.(c) .> w1 .* α * (2 * λ[1] - λmax)
  end

  path_length = length(λ)

  L = vec(sum(x .^ 2, dims = 1))

  beta = zeros(p)

  intercepts = zeros(path_length)
  betas = zeros(p, path_length)

  dev_null = 0.5 * norm(residual)^2
  dev_ratio = dev_null

  working_set = findall(screened)

  for i in 1:path_length
    lambda1 = w1 .* α * λ[i]
    lambda2 = w2 .* (1 - α) * λ[i]

    residual = y .- intercept .- x[:, working_set] * beta[working_set]

    if i > 1 && screen
      screened[1:p] .= false
      c = x' * residual .- lambda2 .* beta
      screened = abs.(c) .> w1 .* α * (2 * λ[i] - λ[i - 1])
    end

    while true
      working_set = findall(screened)
      beta[working_set] .= 0.0

      beta, intercept, _, _, _ = cdsolver(
        x,
        y,
        lambda1,
        lambda2,
        L,
        intercept,
        beta,
        working_set;
        fit_intercept = fit_intercept,
        kwargs...,
      )

      # check violations
      any_violations = false

      if screen
        residual = y .- intercept .- x[:, working_set] * beta[working_set]

        for j in 1:p
          if !screened[j]
            c_j = dot(x[:, j], residual) - lambda2[j] * beta[j]
            if abs(c_j) >= w1[j] .* α * λ[i]
              println("Violation: Adding $j to the working set")
              screened[j] = true
              any_violations = true
            end
          end
        end
      end

      if !any_violations
        break
      end
    end

    betas[:, i] = beta
    intercepts[i] = intercept

    # check for early stopping
    df = sum(beta .!= 0)
    dev = 0.5 * norm(residual)^2
    dev_ratio_prev = dev_ratio
    dev_ratio = 1 - dev / dev_null
    dev_change = (dev_ratio - dev_ratio_prev) / dev_ratio

    if verbose
      println("Iteration: $i, df: $df, dev_ratio: $dev_ratio, dev_change: $dev_change")
    end

    if auto_lambda && i > 1
      if (α > 0 && df > dfmax) || dev_ratio > devmax || dev_change < fdev
        if verbose
          println("Early stopping at iteration: $i")
        end
        path_length = i
        break
      end
    end
  end

  return betas[:, 1:path_length], intercepts[1:path_length], λ[1:path_length]
end
