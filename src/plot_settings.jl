using Plots
using ColorSchemes
using LaTeXStrings
using PlotThemes

using PythonPlot: matplotlib

const global FULL_WIDTH = 630

function set_plot_defaults(; backend = "pyplot", target = "tmlr")
    default(framestyle = :box, label = nothing, tick_direction = :in, palette = :tableau_10)
    return if backend == "gr"
        gr()
    else
        if target == "poster"
            # Poster profile: match the ICML poster's Fira font exactly (Fira Sans
            # + Fira Math), drop the gray grid, and use large fonts so text is
            # legible at poster scale. Fira comes via fontsetup, which needs
            # lualatex, so the figures are written through matplotlib's pgf
            # backend (see `save_poster`) rather than the usetex/pdflatex pipeline
            # used for the paper. We deliberately leave the live backend on its
            # default here: switching the global backend to pgf breaks Plots'
            # layout pass (it draws the figure before saving, and the pgf canvas
            # has no file handle at that point).
            default(
                grid = false,
                titlefontsize = 18,
                guidefontsize = 16,
                tickfontsize = 13,
                legendfontsize = 14,
                thickness_scaling = 1.6,
                background_color_outside = :transparent,
                legend_background_color = :transparent,
            )
            pythonplot()
            matplotlib.rcParams["text.usetex"] = false
            # The large titles carry a subscript (e.g. sigma_e), whose descender
            # crowds the top of the plot box; give the title extra breathing room.
            matplotlib.rcParams["axes.titlepad"] = 14
            matplotlib.rcParams["pgf.texsystem"] = "lualatex"
            matplotlib.rcParams["pgf.rcfonts"] = false
            matplotlib.rcParams["pgf.preamble"] =
                "\\usepackage{amsmath}\\usepackage{mathtools}\\usepackage[fira]{fontsetup}"
        elseif target == "icml"
            default(
                titlefontsize = 10,
                guidefontsize = 10,
                thickness_scaling = 0.9,
                background_color_outside = :transparent,
                legend_background_color = :transparent,
            )
            pythonplot()
            matplotlib.rcParams["text.usetex"] = true
            matplotlib.rcParams["font.family"] = "serif"
            matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{newtx}\\usepackage{amsfonts}\\usepackage{mathtools}"
        else
            default(
                titlefontsize = 11,
                thickness_scaling = 0.9,
                background_color_outside = :transparent,
                legend_background_color = :transparent,
            )
            pythonplot()
            matplotlib.rcParams["text.usetex"] = true
            matplotlib.rcParams["text.latex.preamble"] = "\\usepackage{lmodern}\\usepackage{amsfonts}\\usepackage{amssymb}\\usepackage{mathtools}\\usepackage{bm}"
        end
    end
end

function delta_palette(ind)
    return ColorSchemes.Johnson[ind]'
end

"""
    save_poster(plt, path; kwargs...)

Save a Plots figure built under `set_plot_defaults(target = "poster")` to `path`
using matplotlib's pgf backend, so the PDF is compiled with lualatex and embeds
the poster's Fira fonts (Fira Sans + Fira Math via fontsetup).

Plots' own `savefig` routes through the live (Agg) backend, which would render
text with matplotlib's default fonts. Instead we let Plots lay the figure out,
grab the underlying matplotlib `Figure`, and call its `savefig` with
`backend = "pgf"`, which compiles just this figure through lualatex without
disturbing the global backend used for layout.
"""
function save_poster(plt, path; kwargs...)
    Plots.prepare_output(plt)
    fig = plt.o
    fig.savefig(path; backend = "pgf", bbox_inches = "tight", kwargs...)
    return path
end
