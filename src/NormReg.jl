module NormReg

include("folded_normal.jl")
export FoldedNormal

include("generate_data.jl")
export generate_binary_gaussian_features
export generate_binary_data

include("lasso_utils.jl")
export orthogonal_solution, soft_threshold, get_lambdamax

include("plot_settings.jl")
export set_plot_defaults, get_full_width
export get_full_width

include("plotting.jl")
export plot_lasso_path

include("preprocessing.jl")
export find_binary_features, normalize, unstandardize_coefficients

include("cv.jl")
export cross_validate

include("utils.jl")
export confidence_interval
export confidence_error

end
