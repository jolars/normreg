module NormReg

include("folded_normal.jl")
export FoldedNormal

include("generate_data.jl")
export generate_binary_gaussian_features
export generate_mixed_data

include("lasso_utils.jl")
export orthogonalSolution, softThreshold, get_lambdamax

include("plot_settings.jl")
export setPlotSettings

include("plotting.jl")
export plotPath

include("preprocessing.jl")
export find_binary_features, normalize, unstandardize_coefficients

include("cv.jl")
export crossValidate

include("utils.jl")
export here

end