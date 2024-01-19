using Plots
using LaTeXStrings

using PythonPlot: matplotlib

function setPlotSettings()
  default(titlefontsize = 11, thickness_scaling = 1)

  pythonplot()
  # gr()

  matplotlib.rcParams["text.usetex"] = true
  matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}"
end
