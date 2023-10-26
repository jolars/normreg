using Plots
using LaTeXStrings

using PythonPlot: matplotlib

default(titlefontsize = 12)

matplotlib.rcParams["text.usetex"] = true

# TODO: Figure out why these have no effect.
# matplotlib.rcParams["axes.titlesize"] = "small"
# matplotlib.rcParams["figure.titlesize"] = "small"

pythonplot()
