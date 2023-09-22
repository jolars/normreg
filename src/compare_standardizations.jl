include("preprocessing.jl")
include("plotting.jl")

function compare_standardizations(x, y; dist=GLM.Normal())
  x = Array(x)

  x_std, x_std_center, x_std_scale = standardize_matrix(x, "mean_std")
  x_max, x_max_center, x_max_scale = standardize_matrix(x, "max_abs")

  res_std = Lasso.fit(Lasso.LassoPath, x_std, y, dist, standardize=false)
  res_max = Lasso.fit(Lasso.LassoPath, x_max, y, dist, standardize=false)

  intercepts_std, coefs_std = unstandardize_coefficients(res_std.b0, res_std.coefs, vec(x_std_center), vec(x_std_scale))
  intercepts_max, coefs_max = unstandardize_coefficients(res_max.b0, res_max.coefs, vec(x_max_center), vec(x_max_scale))


  # Find the indices of the 10 coefficients that entered the path first
  first_ten_std = findfirst(dropdims(sum(coefs_std .!= 0, dims=1) .>= 10, dims=1))
  var_ind_std = findall(Array(coefs_std[:, first_ten_std]) .!= 0)

  first_ten_max = findfirst(dropdims(sum(coefs_max .!= 0, dims=1) .>= 10, dims=1))
  var_ind_max = findall(Array(coefs_max[:, first_ten_max]) .!= 0)

  var_ind = union(var_ind_max, var_ind_std)

  p1 = plot_path(coefs_std, var_ind)
  p2 = plot_path(coefs_max, var_ind)

  pp = Plots.plot(p1, p2, layout=grid(2, 1))
  pp
end
