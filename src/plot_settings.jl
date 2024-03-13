using Plots
using LaTeXStrings
using PlotThemes

using PythonPlot: matplotlib

function get_full_width()
  return 570
end

function set_plot_defaults(backend = "pyplot")
  theme(:wong)
  default(framestyle = :box, label = nothing, tick_direction = :in)
  if backend == "gr"
    gr()
    default(fontfamily = "Computer Modern", titlefontsize = 11, thickness_scaling = 0.7)
  else
    default(titlefontsize = 11)
    pythonplot()
    matplotlib.rcParams["text.usetex"] = true
    matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}\\usepackage{mathtools}"
  end
end
