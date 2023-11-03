## To Do

- Use homotopy path algorithm to express upcoming critical λ values as a function of the scaling of the features.
- Solve two-dimensional ridge regression problem with correlation to examine the effects of correlation between a binary and a continuous variable.
- Solve a two-dimensional lasso problem, without correlation, to observe the relative effect of standard deviation.
- Use Fisher–Tippett–Gnedenko theorem to say something about the effect of max-abs-scaling when used with gaussian and bernoulli variables.
- Consider the relationship to adaptive lasso.
- Consider other penalties to generalize and appeal to a broader audience: MCP, SCAD, hinge loss.
- Consider developing a package (in python/R maybe?) that features symbolic design matrices, such that it automatically does just-in-time normalization for sparse and permanent-storage (hard drive) design matrices. So that you can say write a gradient descent method without caring about doing the JIT normalization yourself.

## Insights

- Rare traits (especially in binary data), will "never" be selected.
- Outliers can cause variables to not be selected.
- Scaling with maximum absolute value means that for a Gaussian variable, the importance of a variable decrease with the number of samples (since the change of encountering a high value increases).

## Open Questions

- What effect does standardization have when it is used in the presence of dummy variables?
- Should dummy variables be standardized?
- In which situations is standardization of type x useful? What about type y?
- Is this only a problem for simpler models? I.e., does it matter for neural networks, for instance? Probably not.
- Adaptive lasso can be seen as a type of pre-processing. How does it compare? Does it fix the problems here?
- We standardize unconditionally, but interpret regression coefficients conditionally.
- Can we quantify how strong a given feature's RMSE needs to be for it to be selected?
- How is prediction performance affected by this?
- How is false discovery rate affected by this?
- How is cross-validation affected by this?
- Can we mitigate the effect through stratification of the features?
- Can we mitigate the effect through some type of normalization?
