using Random
using Distributions
using Base

logspace(start, last, count) = Iterators.map(exp, range(log(start), log(last), count))

function generate_binary_gaussian_features(n; μ = 0, σ = 0.5, p = 0.5, ρ = 0)
  X = Normal(0, 1)

  x = rand(X, n)
  z = rand(X, n)

  q = quantile(X, 1 - p)

  r = ρ * √(p * (1 - p)) / pdf(X, q)

  y = r * x .+ √(1 - r^2) * z

  # Modify standard deviation and mean
  y = (y * σ) .+ μ

  b = Int64.(x .>= q)

  return [y b]
end

function generate_binary_data(n, p, k, q_type, beta_type = "constant", snr = 1)
  x = zeros(n, p)

  β = zeros(p)

  if beta_type == "constant"
    β[1:k] .= 1
  elseif beta_type == "linear"
    β[1:k] .= collect(range(1, 0.1, length = k))
  elseif beta_type == "geometric"
    β[1:k] .= collect(logspace(1.0, 0.0, k))
  else
    error("beta_type not supported")
  end

  q = collect(logspace(0.5, 0.99, k))
  q_noise = collect(range(0.5, 0.99, length = p - k))

  for i in 1:p
    if i <= k
      if q_type == "decreasing"
        q_i = q[i]
      elseif q_type == "balanced"
        q_i = 0.5
      elseif q_type == "imbalanced"
        q_i = 0.9
      elseif q_type == "very_imbalanced"
        q_i = 0.99
      else
        error("q_type not supported")
      end
    else
      q_i = q_noise[i - k]
    end

    n_ones = ceil(Int64, q_i * n)
    inds = sample(1:n, n_ones, replace = false)
    x[inds, i] .= 1
  end

  σ = √(var(x * β) / snr)
  # σ = 1e-8

  y = x * β .+ rand(Normal(0, σ), n)

  return x, y, β, σ
end

function generate_mixed_data(n, p, k, q_type, beta_type, snr)
  x = zeros(n, p)

  β = zeros(p)

  k_half = Int64(floor(k / 2))

  if beta_type == "constant"
    β[1:k] .= 1
  elseif beta_type == "linear"
    β[1:k_half] .= collect(range(10, 0.5, length = k_half))
    β[(k_half + 1):k] .= collect(range(10, 0.5, length = k - k_half))
  else
    error("beta_type not supported")
  end

  if q_type == "linear"
    q = collect(range(0.5, 0.99, length = k))
  elseif q_type == "geometric"
    q = collect(logspace(0.5, 0.99, k))
  end

  for i in 1:p
    if i <= k_half
      # First half of the signals are Normally distributed
      X = Normal(0, 0.5)
    elseif i <= k
      # Second half of the signals are Bernoulli distributed
      if q_type in ["linear", "geometric"]
        X = Bernoulli(q[i])
      elseif q_type == "balanced"
        X = Bernoulli(0.5)
      elseif q_type == "imbalanced"
        X = Bernoulli(0.9)
      elseif q_type == "very_imbalanced"
        X = Bernoulli(0.99)
      else
        error("q_type not supported")
      end
    else
      if i % 2 == 0
        X = Normal(0, 0.5)
      else
        q_i = rand(Uniform(0.5, 0.99), 1)
        X = Bernoulli(q_i[1])
      end
    end

    x[:, i] = rand(X, n)
  end

  σ = √(var(x * β) / snr)
  y = x * β .+ rand(Normal(0, σ), n)

  return x, y, β
end
