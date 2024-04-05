module NormReg

include("folded_normal.jl")
export FoldedNormal

include("generate_data.jl")
export generate_binary_data
export generate_binary_gaussian_features
export generate_interaction_data
export generate_mixed_data
export generate_pseudobernoulli
export generate_pseudobernoulli_times_gaussian
export generate_pseudonormal
export log10space
export logspace

include("lasso_utils.jl")
export get_lambdamax
export orthogonal_solution
export soft_threshold

include("plot_settings.jl")
export set_plot_defaults
export FULL_WIDTH

include("plotting.jl")
export plot_lasso_path

include("preprocessing.jl")
export find_binary_features
export normalize_features
export normalize_features2
export normalize_features_unadjusted
export unstandardize_coefficients

include("cv.jl")
export cross_validate
export get_error
export holdout_validation
export split_data

include("utils.jl")
export confidence_error
export confidence_interval

include("binary_features.jl")
export binary_d
export binary_expected_value
export binary_mean
export binary_selection_prob
export binary_stddev
export binary_variance

end
