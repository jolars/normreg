using DataFrames
using Plots
using LaTeXStrings
using NormReg
using JSON
using ProjectRoot

set_plot_defaults(target = "icml");

function plot_realpaths(df)
  plots = []
  n_rows = length(unique(df.normalization))
  n_cols = length(unique(df.dataset))

  for (i, d) in enumerate(groupby(df, :normalization))
    for (j, dd) in enumerate(groupby(d, :dataset))
      normalization = unique(dd.normalization)[1]
      dataset = unique(dd.dataset)[1]

      betas = Float64.(mapreduce(permutedims, vcat, dd.betas[1]))'

      normalization =
        replace(normalization, "std" => "Standardization", "max_abs" => "Max--Abs")

      n_choose = 70

      betas = betas[:, 1:n_choose]

      first_five = findfirst(dropdims(sum(betas .!= 0, dims = 1) .>= 5, dims = 1))
      var_ind = findall(Array(betas[:, first_five]) .!= 0)

      coefs = betas ./ maximum(abs.(betas))

      n_var = size(coefs, 1)
      n_lambda = size(coefs, 2)
      x_var = 1:n_lambda

      var_grey = findall(dropdims(sum(betas .!= 0, dims = 2) .> 0, dims = 2))
      grey_vars = setdiff(var_grey, var_ind)

      xformatter = i == n_rows ? :auto : _ -> ""

      p = plot(legend = false)

      for i in grey_vars
        plot!(Array(x_var), coefs[i, :], legend = false, color = :gray90)
      end

      yguideposition = if j == n_cols
        :right
      else
        :left
      end

      yguide = if j == 1
        L"\hat\beta / \max_j |\hat\beta_j| "
      elseif j == n_cols
        normalization
      else
        ""
      end

      yformatter = j == 1 ? :auto : _ -> ""

      for i in var_ind
        plot!(
          Array(x_var),
          coefs[i, :],
          color = i,
          legend = false,
          xformatter = xformatter,
          yformatter = yformatter,
          yguide = yguide,
          yguideposition = yguideposition,
          ylims = (-1.1, 1.1),
        )
      end

      if i == 1
        title!(dataset)
      else
        xlabel!("Step")
      end

      push!(plots, p)
    end
  end
  return plots
end

json_data = JSON.parsefile(@projectroot("results", "realdata_paths.json"));
df = DataFrame(json_data);
plots = plot_realpaths(df)

plot_output = plot(plots..., layout = (2, 4), size = (FULL_WIDTH, 340))

file_path = @projectroot("plots", "realdata_paths.pdf")

savefig(plot_output, file_path)

# for one-column (ICML)
df = DataFrame(json_data);
df_small = DataFrames.subset(df, :dataset => d -> d .== "triazines" .|| d .== "w1a")

plots_small = plot_realpaths(df_small)

plot_output = plot(plots_small..., layout = (2, 2), size = (320, 280))

file_path_small = @projectroot("plots", "realdata_paths_small.pdf")

savefig(plot_output, file_path_small)
