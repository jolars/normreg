# Reviews

## Reviewer 1

> The study mainly focuses on binary and continuous features under
> least-squares loss. It would be better to discuss further how the results can
> be extended to categorical variables with more than two levels or broader
> classes of models.

We agree that it would be interesting to extend the results to a wider class of
models and data types, but believe that this would require extensive additional
work to be meaningful. We have, however, now included an additional experiment
and short discussion on categorical features to the appendix (Appendix F).
As we mention in the discussion of the paper, we also believe that
an extension to generalized linear models is straightforward given
that they depend directly on the same linear predictor.

> It would be better to discuss how the studies can be extended to some deep
> learning scenarios, for example, distance regularization for fine-tuning
> pretrained deep neural networks.

While we agree that this would be interesting and worthwhile, it would
also require an altogether different analysis, which we believe is better
suited for future work.

> It would be better to include a discussion of highly sparse binary data
> (e.g., text or clickstream data), where normalization strategies may interact
> with sparsity constraints differently.

We already cover highly sparse binary data. In fact, this is the primary target
of our study (unbalanced binary features), so it is exactly the situation that
both our theoretical and empirical work is focused on.

> The bias–variance trade-off can be quantified more clearly, e.g., error rates
> or feature selection accuracy in simulated settings with varying SNRs.

Please note that we have closed-form expression for mean-squared error and
feature selection probability through equations (5), (6), and (8). This is also
visualized directly in Figures 3, 4, 13, and 14 (in the revised paper). We also
study power and false-discovery rate empirically in the experiment in Appendix
E.1 (see figure 14) and the effect of SNR in the experiment in Appendix E.3
(see figure 17). Did you have any particular other experiment or result in
mind?

> It would be better to add more intuitive examples and visualizations (e.g.,
> small toy datasets) to illustrate how normalization changes coefficient paths
> for non-technical readers.

Thank you for this suggestion! We have now included a new figure (Figure 2 in
the revision), which shows coefficient paths along the regularization paths for
balanced and imbalanced binary features under different types of normalization.

## Reviewer 2

> A slight weakness is that the paper is based on strong assumptions in a very
> simple setting.

We agree that this is a limitation, but also want to stress that it is a first
step in understanding the effect of normalization, and that ours is the only
paper to have so far studied the issue in any capacity. And although the
setting may seem simple, it is actually not trivial to extend the results to
more complex settings.

> Also, results only concerns the expected value of the
> regression coefficient in the limit of extremely unbalanced binary features.

This is not quite true. Equations (5), (6), and (8) are not
asymptotic results. They hold for any $q$ and are
closed-form expressions for expected value, variance, and probability
of selection. In addition, please note that we have empirical
results covering a wide range of simulated as well as real-world
data.

> In table 1, the $\hat{\beta}_\text{max-ab}$ column is entirely zero. Is it
> correct or a mistake?

Yes, that is in fact correct, and it underlines how strong the effect of
normalization can be. We have clarified this in the part of the text
where we discuss the table.

> Also, could the authors explain the possibility or the difficulty how to extend
> the results to non-binary and non-Gaussian features?

We think it would be interesting to extend the results to other distributions
too, but this would likely require extensive additional work, which we think is
better suited for future work. We have, however, now included an additional
experiment and short discussion on categorical features to the appendix
(Appendix F).

## Reviewer 3

> Light request: instead of labeling e.g. the design matrix $X_{ij}$, consider
> using mixed Greek and Roman indices like $X_{\alpha j}$. This improves the
> clarity of which quantities are in feature space vs data space.

Thank you for the suggestion, but we would like to argue that the current
notation is standard and that mixing greek and roman indices might lead to more
confusion, particularly since greek letters are often used for other purposes
(e.g. parameters). We have, however, added a phrase to clarify the notation
when it is first introduced. Please also note that we make scant use of the
double-index notation in the paper, so we believe there is little potential for
confusion.

> The main request is to add a more detailed, separate section on practical
> lessons from the theory and the experiments, e.g. about how to choose the
> normalization scheme and/or sanity checks for making sure the normalization
> scheme is well selected. In particular it seems like choosing nontrivial
> $\delta$ was beneficial in the experiments, which may lead to recommendations
> for practitioners to use non-traditional normalization schemes.

We agree that this is a good idea and have added a new section (Section 5 in
the revision) called "Practical Recommendations", which summarizes the main
practical takeaways from our results.
