using LinearAlgebra

function softThreshold(x, λ)
  return sign(x) * max(abs(x) - λ, 0)
end

function orthogonalSolution(x, y, λ, centers, scales)
  p = size(x, 2)
  out = zeros(size(x, 2))

  for j in 1:p
    x_tilde = x[:, j] .- centers[j]
    xty = x_tilde'y
    out[j] = scales[j] * softThreshold(xty, scales[j] * λ) / norm(x_tilde)^2
  end

  out
end
