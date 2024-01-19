using Plots
using LaTeXStrings

using PythonPlot: matplotlib

default(titlefontsize = 11)

pythonplot()

matplotlib.rcParams["text.usetex"] = true
