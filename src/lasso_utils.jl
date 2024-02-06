using LinearAlgebra

function soft_threshold(x, λ)
  return sign(x) * max(abs(x) - λ, 0)
end

function orthogonal_solution(x, y, λ, centers, scales)
  p = size(x, 2)
  out = zeros(size(x, 2))

  for j in 1:p
    x_tilde = x[:, j] .- centers[j]
    xty = x_tilde'y
    out[j] = scales[j] * soft_threshold(xty, scales[j] * λ) / norm(x_tilde)^2
  end

  out
end

function get_lambdamax(x, y, normalization = "mean_std"; intercept = true)
  n = size(x, 1)
  λmax = maximum(abs.(x' * (y .- mean(y) * Int(intercept)))) / n

  return λmax
end
