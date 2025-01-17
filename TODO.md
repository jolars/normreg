## To Do

- Use homotopy path algorithm to express upcoming critical λ values as a function of the scaling of the features.
- Solve two-dimensional ridge regression problem with correlation to examine the effects of correlation between a binary and a continuous variable.
- Solve a two-dimensional lasso problem, without correlation, to observe the relative effect of standard deviation.
- Consider other penalties to generalize and appeal to a broader audience: MCP, SCAD, hinge loss.

## Insights

- Rare traits (especially in binary data), will "never" be selected.
- Outliers can cause variables to not be selected.
- Scaling with maximum absolute value means that for a Gaussian variable, the importance of a variable decrease with the number of samples (since the change of encountering a high value increases).

## Open Questions

- In which situations is standardization of type x useful? What about type y?
- Is this only a problem for simpler models? I.e., does it matter for neural networks, for instance?
- We standardize unconditionally, but interpret regression coefficients conditionally.
- Can we quantify how strong a given feature's RMSE needs to be for it to be selected?
- How is prediction performance affected by this?
- How is false discovery rate affected by this?
- How is cross-validation affected by this?
- Can we mitigate the effect through stratification of the features?
- Can we mitigate the effect through some type of normalization?
