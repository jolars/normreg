using Plots
using ColorSchemes
using LaTeXStrings
using PlotThemes

using PythonPlot: matplotlib

const global FULL_WIDTH = 630

function set_plot_defaults(backend = "pyplot")
  # theme(:wong2)
  default(framestyle = :box, label = nothing, tick_direction = :in, palette = :tableau_10)
  if backend == "gr"
    gr()
  else
    default(
      titlefontsize = 11,
      background_color_outside = :transparent,
      legend_background_color = :transparent,
    )
    pythonplot()
    matplotlib.rcParams["text.usetex"] = true
    matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}\\usepackage{amsfonts}\\usepackage{amssymb}\\usepackage{mathtools}"
  end
end

function delta_palette(ind)
  return ColorSchemes.Johnson[ind]'
end
