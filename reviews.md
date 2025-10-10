# Reviews

## Reviewer 1

### Strengths And Weaknesses:

#### Weaknesses

> - The study mainly focuses on binary and continuous features under
>   least-squares loss. It would be better to discuss further how the results can
>   be extended to categorical variables with more than two levels or broader
>   classes of models.

TO DO

> It would be better to discuss how the studies can be extended to some deep
> learning scenarios, for example, distance regularization for fine-tuning
> pretrained deep neural networks.

While we agree that this would be interesting and worthwhile, it would
also require an altogether different analysis, which we believe is better
suited for future work.

#### Requested Changes:

> It would be better to include a discussion of highly sparse binary data
> (e.g., text or clickstream data), where normalization strategies may interact
> with sparsity constraints differently.

We already cover highly sparse binary data. In fact, this is the primary target
of our study (unbalanced data), so it is exactly the situation in which both
our theoretical and empirical work covers.

> The bias–variance trade-off can be quantified more clearly, e.g., error rates
> or feature selection accuracy in simulated settings with varying SNRs.

Please note that we have closed-form expression for mean-squared error
and feature selection probability through equations (5), (6), and (8).
This is also visualized directly in Figures 2, 3, 12, and 13. We also
study power and false-discovery rate empirically in
the experiment in Appendix E.1 (see figure 14) and the effect of
SNR in the experiment in Apepndix E.3 (see figure 16).
Did you have any particular other experiment or result in mind?

> It would be better to add more intuitive examples and visualizations (e.g.,
> small toy datasets) to illustrate how normalization changes coefficient paths
> for non-technical readers.

Add some example. Maybe two paths to show different effects. Generate data
so that we can show the effect clearly. Maybe balanced vs unbalanced.

## Reviewer 2

### Weakness

> A slight weakness is that the paper is based on strong assumptions in a very
> simple setting.

We agree that this is a limitation, but also want to stress that it is a first
step in understanding the effect of normalization and that this is the first
paper to have even studied the issue in any capacity. And although the setting
is simple, it is not trivial to extend the results to more complex settings.

> Also, results only concerns the expected value of the
> regression coefficient at the limit of extremely unbalanced binary features.

This is not quite true. Equations (5), (6), and (8) are not
asymptotic results. They hold for any $q$ and are
closed-form expressions for expected value, variance, and probability
of selection. In addition, please note that we have empirical
results that cover a wide range of simulated as well as real-world
data.

### Requested Changes:

> In table 1, the $\hat{\beta}_\text{max-ab}$ column is entirely zero. Is it
> correct or a mistake?

Yes, that is in fact correct, and underlines how strong the effect of
normalization can be. We have clarified this in the part of the text
where we discuss Table 1.

> Also, could the authors explain the possibility or the difficulty how to extend
> the results to non-binary and non-Gaussian features?

For the theoretical results, it way be difficult. But we have
added new experiments on simulated data...

- Easy fix: poisson/t-distribution
- Better: categorical features

## Reviewer 3

### Summary Of Contributions:

> The main weakness is the lack of clearly stated lessons for practitioners; some
> guidance is available but the main lessons appear to be scattered throughout
> the text. I believe consolidating these into a single discussion section could
> be valuable.

Yes, good idea.

### Requested Changes:

> Light request: instead of labeling e.g. the design matrix $X_{ij}$, consider
> using mixed greek and roman indices like $X_{\alpha j}$. This improves the
> clarity of which quantities are in feature space vs data space.

Thank you for the suggestion, but we would like to argue that the current
notation is standard and that mixing greek and roman indices would likely
lead to more confusion, particularly since greek letters are often used
for other purposes (e.g. parameters). We have, however,
added a phrase to clarify the notation when it is first introduced. Please also
note that we make very little use of the double-index notation in the
paper, so we believe there is little potential for confusion.

> The main request is to add a more detailed, separate section on practical
> lessons from the theory and the experiments, e.g. about how to choose the
> normalization scheme and/or sanity checks for making sure the normalization
> scheme is well selected. In particular it seems like choosing nontrivial
> $\delta$ was beneficial in the experiments, which may lead to recommendations
> for practitioners to use non-traditional normalization schemes.
