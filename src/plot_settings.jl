using Plots
using LaTeXStrings
using PlotThemes

using PythonPlot: matplotlib

const global FULL_WIDTH = 630

function set_plot_defaults(backend = "pyplot")
  theme(:wong)
  default(framestyle = :box, label = nothing, tick_direction = :in)
  if backend == "gr"
    gr()
  else
    default(titlefontsize = 11)
    pythonplot()
    matplotlib.rcParams["text.usetex"] = true
    matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}\\usepackage{mathtools}"
  end
end
