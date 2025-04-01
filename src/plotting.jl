using Plots

function plot_lasso_path(coefs, var_ind; kws...)
  n_var = size(coefs, 1)
  n_lambda = size(coefs, 2)
  x_var = 1:n_lambda

  grey_vars = setdiff(1:n_var, var_ind)

  p = plot(xlabel = "Step", ylabel = "Coefficient", legend = false; kws...)

  for i in grey_vars
    plot!(Array(x_var), coefs[i, :], legend = false, color = :gray90)
  end

  for i in var_ind
    plot!(Array(x_var), coefs[i, :], legend = false, color = i)
  end

  p
end
