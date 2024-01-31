using Plots
using LaTeXStrings
using PlotThemes

using PythonPlot: matplotlib

function setPlotSettings(backend = "pyplot")
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
    # scalefontsizes(1.3)
  else
    theme(:wong)
    default(titlefontsize = 11, thickness_scaling = 1, framestyle = :box)
    pythonplot()
    matplotlib.rcParams["text.usetex"] = true
    matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}"
  end
end
