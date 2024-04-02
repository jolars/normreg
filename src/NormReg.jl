module NormReg

include("folded_normal.jl")
export FoldedNormal

include("generate_data.jl")
export generate_binary_gaussian_features
export generate_binary_data
export generate_mixed_data
export generate_pseudobernoulli
export generate_pseudonormal
export generate_pseudobernoulli_times_gaussian
export logspace
export log10space

include("lasso_utils.jl")
export orthogonal_solution, soft_threshold, get_lambdamax

include("plot_settings.jl")
export set_plot_defaults
export FULL_WIDTH

include("plotting.jl")
export plot_lasso_path

include("preprocessing.jl")
export find_binary_features,
  normalize_features, unstandardize_coefficients, normalize_features2

include("cv.jl")
export cross_validate
export holdout_validation
export split_data
export get_error

include("utils.jl")
export confidence_interval
export confidence_error

include("binary_features.jl")
export binary_expected_value
export binary_variance
export binary_mean
export binary_stddev
export binary_d

end
