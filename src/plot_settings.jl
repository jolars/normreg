using Plots
using LaTeXStrings

using PythonPlot: matplotlib

default(titlefontsize = 12)

pythonplot()

matplotlib.rcParams["text.usetex"] = true
