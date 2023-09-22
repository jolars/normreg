"""
    standardize_matrix(matrix::AbstractMatrix, method::String)

Standardizes the given matrix using the specified method.

# Arguments
- `matrix::AbstractMatrix`: The matrix to be standardized.
- `method::String`: The method to be used for standardization. Valid options are "mean_std" and "max_abs".

# Returns
- `standardized_matrix::Matrix`: The standardized matrix.

# Examples
```julia
julia> matrix = [1 2 3; 4 5 6; 7 8 9]
3×3 Matrix{Int64}:
 1  2  3
 4  5  6
 7  8  9

julia> standardize_matrix(matrix, "mean_std")
3×3 Matrix{Float64}:
 -1.0  -1.0  -1.0
  0.0   0.0   0.0
  1.0   1.0   1.0

julia> standardize_matrix(matrix, "max_abs")
3×3 Matrix{Float64}:
 0.142857  0.25  0.333333
 0.571429  0.625  0.666667
 1.0       1.0    1.0
```
"""
function standardize_matrix(matrix::AbstractMatrix, method::String)
  if method == "mean_std"
    centers = mean(matrix, dims=1)
    scales = std(matrix, dims=1)
    scales[findall(scales .== 0.0)] .= 1.0
    out_matrix = (Matrix(matrix) .- centers) ./ scales
  elseif method == "max_abs"
    centers = zeros(size(matrix, 2))
    scales = maximum(abs.(matrix), dims=1)
    scales[findall(scales .== 0.0)] .= 1.0
    out_matrix = Matrix(matrix ./ scales)
  else
    error("Invalid method. Choose either 'mean_std' or 'max_abs'.")
  end

  return out_matrix, centers, scales
end


function unstandardize_coefficients(
  beta0::AbstractVector,
  beta::AbstractMatrix,
  centers::AbstractVector,
  scales::AbstractVector)

  beta_out = Array(beta)
  beta0_out = Array(beta0)

  for m in axes(beta, 2)
    x_bar_beta_sum = 0.0
    for j in axes(beta, 1)
      beta_out[j, m] = beta[j, m] / scales[j]
      x_bar_beta_sum += beta_out[j, m] * centers[j]
    end
    beta0_out[m] -= x_bar_beta_sum
  end


  (beta0_out, beta_out)
end
