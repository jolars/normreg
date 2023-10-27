using DrWatson

@quickactivate "normreg"

using DataFrames

using Plots
gr()

include(srcdir("plot_settings.jl"))

df = collect_results(datadir("realdata_paths"))

plots = []

for (i, d) in enumerate(groupby(df, :normalization))
  for (j, dd) in enumerate(groupby(d, :dataset))
    normalization = unique(dd.normalization)[1]
    dataset = unique(dd.dataset)[1]
    betas = Array(dd.betas[1])

    normalization =
      replace(normalization, "mean_std" => "Mean-SD", "max_abs" => "Max-Abs")

    n_choose = 70

    betas = betas[:, 1:n_choose]

    first_ten = findfirst(dropdims(sum(betas .!= 0, dims = 1) .>= 5, dims = 1))
    var_ind = findall(Array(betas[:, first_ten]) .!= 0)

    coefs = betas

    n_var = size(coefs, 1)
    n_lambda = size(coefs, 2)
    x_var = 1:n_lambda

    var_grey = findall(dropdims(sum(betas .!= 0, dims = 2) .> 0, dims = 2))
    grey_vars = setdiff(var_grey, var_ind)

    p = plot(legend = false)
    print(var_grey)

    for i in grey_vars
      plot!(Array(x_var), coefs[i, :], legend = false, color = :gray90)
    end

    for i in var_ind
      if j == 3
        plot!(
          Array(x_var),
          coefs[i, :],
          legend = false,
          color = i,
          yguide = normalization,
          yguideposition = :right,
        )
      else
        plot!(Array(x_var), coefs[i, :], legend = false, color = i)
      end
    end

    if i == 1
      title!(dataset)
    else
      if j == 2
        xlabel!("Step")
      end
    end

    if j == 3
      ylabel!(normalization)
    end

    if mod(j - 1, 3) == 0
      ylabel!(L"\beta")
    end

    push!(plots, p)
  end
end

plot_output = plot(plots..., layout = (2, 3), size = (450, 350))

file_name = "realdata_paths"

savefig(plot_output, plotsdir(file_name * ".pdf"))
