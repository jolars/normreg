using Plots
using LaTeXStrings
using PlotThemes

using PythonPlot: matplotlib

function get_full_width()
  return 470
end

function set_plot_defaults(backend = "pyplot")
  theme(:wong)
  if backend == "gr"
    gr()
    default(
      fontfamily = "Computer Modern",
      linewidth = 1,
      framestyle = :box,
      label = nothing,
      titlefontsize = 11,
      thickness_scaling = 0.6,
    )
  else
    default(titlefontsize = 11, thickness_scaling = 1, framestyle = :box)
    pythonplot()
    matplotlib.rcParams["text.usetex"] = true
    matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}\\usepackage{mathtools}"
  end
end
