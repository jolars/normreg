using Plots
using LaTeXStrings

using PythonPlot: matplotlib

function setPlotSettings()
  default(titlefontsize = 12, thickness_scaling = 1)

  pythonplot()
  # gr()

  # font = Plots.font("Helvetica", 18)

  matplotlib.rcParams["text.usetex"] = true
  matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}"
end
