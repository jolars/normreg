# Rebuttal

## General Response

We would like to thank the reviewers for their valuable feedback
and are grateful for the time and effort they have put into reviewing our work.
We have carefully read all the comments and suggestions and will address them
point-by-point in comments to the original remarks. We would, however, like
to address a few general points here.

### Assumption of Orthogonality

### Originality

We would like to highlight that our work is the first to investigate this issue.
As the reviewers are aware, we could not in our literature review find
any relevant work that have addressed the problem of feature normalization
before and note that this seems to be confirmed by the fact that the
reviewers were unable to find any relevant references either.

## Reviewer 1

> ## Theoretical Claims
>
> there is a problem in the draft, where the authors write $q_j \righarrow^+ 1$

Thank you, we realize that yours is the more standard notation and will
change this in our paper, along with clearly defining the notation.

> ## Other Strengths and Weaknesses
>
> ### Strength
>
> I like the problem considered here, and I agree that this problem is somewhat under-investigated and worth pursuing.

Thank you for your appreciation. We agree that the problem is
under-investigated and worth pursuing.

> ### Weaknesses
>
> 1. This paper is not well-polished. The flow is very monotone, making the
>    readers have a hard time reading this paper. See below for suggestions.
> 2. The assumption on the orthogonality of the normalized design matrix is
>    super strong and rarely holds in practice. This is even more unrealistic
>    for two cases that this paper considers here: binary features and mixed
>    features. As a result, it is very hard to tell if the findings in this
>    paper have an interesting implication in the general cases and in
>    practice.
> 3. As a consequence, I expect that it is the technical challenge on the
>    theoretical side that makes the paper more interesting. However, this is
>    not the case here.
>
> The assumption on the orthogonality of the normalized design matrix $\tilde{\mathbf{X}}$
> is super strong and rarely holds in practice. This is even more unrealistic for
> two cases that this paper considers here: binary features and mixed features.
> As a result, it is very hard to tell if the findings in this paper have an
> interesting implication in the general cases and in practice.

We agree that the assumption is strong and unrealistic. Nevertheless, it is
not uncommon in literature, particularly not in the context of
research on Lasso, Ridge, and Elastic Net, where the theoretical analysis
is difficult due to the composite nature of the objective and the
non-differentiability of the L1 norm. But more importantly, we believe
that it is not, in contrast to many other results, restrictive in
relation to our results. As you can see in Figure 15 where we have
introduced correlation between the features, for instance, it is clear
that the effect of class-imbalance is _stronger_ when the features
are correlated. This is actually not surprising since it is well-known
that regularization means that the model will tend to select, for instance,
the one of two correlated features that has the strongest main effect
since the objective can be reduced more by reducing the coefficient
in this case.

We realize that we do a poor job of explaining this in the paper and will
both add a paragraph to the paper discussing the validity of this assumption.
We have also added a

> ## Other comments or suggestions
>
> ### General Comment
>
> Overall, I find the problem being considered interesting. However, I find the
> presentation of this paper a bit underwhelming, and I feel uncomfortable
> reading this paper. I believe that the presentation can be greatly improved.
> However, in this form, I believe this draft is not ready to be published, and I
> cannot recommend acceptance for this paper. But don't worry, I will consider
> updating my score after the authors make changes to improve the presentation,
> clarity, and flow of this paper. Here are some suggestions: Minor changes:
> Potential typos/clarification suggestions
>
> ### Minor changes
>
> 1. In Equation 2, $\tilde{\boldsymbol{X}}$ is used before defined in
>    Definition 2.1. Consider adding a small clarification right after Equation
>    2, even if it is repetitive.
> 2. In the first paragraph of Section 3, there is no definition for the noise
>    (it is defined later). Consider adding this clarification right after
>    using it.
> 3. In the first paragraph of Section 3, maybe explicitly mentioning that
>    $\boldsymbol{x}_j$ is the-th column of $\tilde{\boldsymbol{X}}$ could
>    improve. clarity.
> 4. The same goes with $\tilde{\boldsymbol{x}}_j$.
> 5. Please discuss the (strong) assumption on the orthogonality of the
>    normalized design matrix $\tilde{\boldsymbol{X}}$: (1) how it rarely >
>    holds in practice, (2) how it is necessary in this framework, (3) if any
>    prior works also have this assumption (to see that it is not too weird
>    one).
> 6. In the first paragraph of Section 3.1., what is
>    $\overline{\boldsymbol{x}}$? I know that it is defined in Table 1, but
>    please refer to it once again to help the readers keep track of the
>    notations. Besides, the wording of this paragraph is not good; consider
>    rewriting this paragraph.
> 7. What is in Equation 8? I know this one is the CDF of normal distribution,
>    but please define it clearly here.
> 8. In section 4.1.2, the author should at least describe what those datasets
>    (a1a, rhee2006, and w1a) are about. I know that the statistics of that
>    dataset is mentioned in Appendix E, Table 2, but at least the author
>    should refer to that Table in the main body.
> 9. In Theorems 3.1, 3.2, and 3.3, since $q_j \in [0,1]$, why do the authors
>    write the limit ? Do you mean $1^{-1}$ instead?

> ### Major changes
>
> 1. It is better if the authors write the whole paragraph/sections of notations
>    used in this paper. The way the authors use notations here is not good: it
>    makes the readers have a hard time finding relevant notions.
> 2. Consider adding the contributions paragraph at the end of Section 1. List the
>    main contributions clearly and where they are located in the main body. I know
>    that the authors discuss those points in Section 5, but I think it is better if
>    authors have some punch lines right from the start so that the readers can keep
>    track of the paper more easily. Consider reorganizing Section 5 accordingly,
>    making it more condensed, and putting the punch lines right at the start.
> 3. Section 3 is very monotone; please reorganize this section. For example, in
>    Section 3.1, the authors could make each part of Section 3.1 more
>    distinguishable, for example, by writing:
>    (1) "\paragraph{Class blance}", which contains the rigorous definition and its
>    intuition.
>    (2) "\paragraph{the effects on the estimators scale ...}" discusses how the
>    class balance directly affects the estimator. Please make three paragraphs
>    after Equation 7 stand out more and elaborate on how the finding is interesting
>    and counterintuitive. (3) and so on.
>    The above are just some suggestions that I have. I recommend that the authors
>    do multiple passes to improve the presentation of this draft.

> ## Questions For the Authors
>
> Is the assumption of the orthogonality of the normalized design matrix too
> strong and unnatural, especially for the case of binary features and mixed
> features? Please give me a couple of examples where this assumption holds and a
> couple of prior works that deal with this assumption. My intuition is that this
> assumption is extremely weird in the cases that this paper considers.

We agree that the assumption is strong, but want to highlight that it is

## Reviewer 2

> This paper investigates how different normalization strategies affect the
> shrinkage in regularized regression models such as Lasso, Ridge, and Elastic
> Net. The authors analyze the impact of normalization on binary and continuous
> features, noting that class balance directly affects regression coefficients
> and that different normalization methods may introduce a trade-off between bias
> and variance. The paper proposes the possibility of replacing feature
> normalization with a weighted Elastic Net approach. Experimental results are
> validated using both synthetic and real data.
>
> ## Claims And Evidence
>
> (1)The evaluation is based on synthetic and small-scale data, which is far from
> the real scenario. I understand that this paper is only for simple (linear)
> model. However, the sparsity property is also somewhat important for deep
> neural network. I think this paper should tailor the method and analyses for
> deep neural networks. Otherwise, I cannot find its value in practice. (I cannot
> judge whether the proposed method/analyses is enough novel and significant in
> the lasso problem, since I am not familiar to the topic of Lasso).

> (2)The paper analyzes traditional regression models, but current predominant
> models also include CNNs, Transformers, etc., which use normalization
> techniques such as Batch Normalization and Layer Normalization. It would be
> valuable to provide some discussion and experimental results on the
> applicability of the conclusions to these models and normalization methods.
>
> ## Theoretical Claims
>
> I do not find remarkable errors in theoretical claims. My main concern is the
> assumption of feature orthogonality. The theoretical analysis assumes feature
> orthogonality, which is often not the case in real data. It would be beneficial
> to include analysis and experimental results for these scenarios.

See the general response regarding the assumption of orthogonality.

> ## Experimental Designs Or Analyses
>
> The experiments provided metrics for various parameters; it would be helpful to
> include accuracy comparison results.

> This paper should conduct more experiments on large-scale classification tasks.

We would be happy to include results on additional data sets, which we will present
in the supplementary material. Here is an updated Figure 16, which we will
include in the new version o the paper as well, featuring several new data sets.

<!-- TODO: Add results on additional datasets -->

We have also updated the dimensions of the experiments related to Figure 17 to
include more features.

<!-- TODO: Update experiment of figure 17 -->

> This paper only provides the code in supplementary materials, and I do not check
> it.

The code will be made available in the form of a public repository as well. If
you prefer, we could also upload it to a anonymous repository for the duration
of the review as well?

> ## Other Comments or Suggestions
>
> Formula Derivation Confirmation: In Equation 12, how is $x_j^T \varepsilon$
> derived? Should it be $x_j^T \varepsilon$ instead? A detailed derivation
> process would be appreciated.

## Reviewer 3

> ## Summary
>
> The paper proposed to study the nature and impact of feature normalization
> schemes with respect to linear models under the L1, L2, and Elastic-Net
> penalties. This is done only for regression, and is focused particularly on
> binary features. The results are primarily theoretical in nature, with a
> limited number of datasets evaluated. Claims And Evidence:
>
> ## Claims and Evidence
>
> Though the claims do have evidence, the abstract set my expectations
> considerably beyond what the article contains. I had anticipated
>
> 1. Logistic models to be considered as well
> 2. A larger collection of datasets
> 3. An empirical evaluation of "our recommendations" vs the readily available
>    tools
>
> ## Methods And Evaluation Criteria
>
> The theoretical approach is sound as far as I can tell. Many figures would be
> clearer, especially the ones with simulated results, by instead centering the
> plots to the deviation from the estimated effect $\hat{\beta}_j$ from the known true effect
> $\beta_j$, as it is otherwise difficult to tell at a glance what the results mean and
> how to interpret them. Indeed while well written, every result is presented in
> a way that presumes the reader is intimately familiar with the larger
> statistical literature. I think the paper is suffering a bit from "I wrote it
> and I know it", and could use a friendly pass from a colleague unaware of the
> work previously. Theoretical Claims:
>
> I have not manually checked the proofs.
>
> ## Experimental Designs Or Analyses
>
> I have no issues with the content of what was done, but find the most obvious
> experiments seem to be missing.
>
> 1. Use each of the listed normalization approaches and the current recommendation
>    in a table for each of L1, L2, and Elastic-Net regression. Show the final total
>    difference in predictive performance achieved using the new theoretically
>    derived insights. If a positive improvement is shown, it also validates the
>    acceptability of the theoretical model, assuming Gaussian errors.
> 2. Consider more
>    datasets, which it is easy to binarize other datasets to match the scope of the
>    model. In this way a statistical test via the Wilcoxon Signed Rank Test can be
>    performed to show conclusively that the approach is an improvement. See, Should
>    We Really Use Post-Hoc Tests Based on Mean-Ranks?
>    <https://jmlr.org/papers/v17/benavoli16a.html>
>
> ## Relation To Broader Scientific Literature
>
> Linear models make the real world go round, the impact could be massive. Most
> literature in this space consider the algorithm independent of the data
> normalization (or just pick something). Even in other areas like Differential
> Privacy, it is standard to assume a specific L1 normalization of the data for
> theoretical reasons, and this work may evidence som understandings of an
> implicit difference between DP and standard regressions beyond the effect of
> randomized noise. Essential References Not Discussed:
>
> No critical missing references, but it would be nice to give pointers to the
> many libraries that have these models to highlight impact (Scikit, DLIB, JSAT,
> Celer, and so many more). Other Strengths And Weaknesses:
>
> I was very excited about this paper initially. I've solved many real-world
> problems with L1 penalized models, followed by Xgboost, and that gets you 90%
> of the world. Briding the empirical gap to show that the results are practical
> in a straight up, "what is the Accuracy /AUC", as mentioned in the above
> sections, would massively elevate the quality and impact of the paper.
>
> The paper's readability would be greatly improved by including an Algorithm
> block for each of L1, L2, and Elastic-Net of the author's proposed approach to
> normalization, each is currently buried in the text and hard to separate in the
> content.
>
> ## Other Comments Or Suggestions
>
> The article would be improved with some more guidance to the reader of "where
> we are going and why", each section currently "jumps in" and it is not clear
> what point is necessarily being made until the end. That isn't to say that the
> paper isn't good grammar, but it was my excitement that carrier me through - it
> would have been more pleasant if I had a map!

Thank you for raising this issue. We will take a careful look
at the text and improve the flow and readability of the paper.

> Considering or discussion robust standardization methods would also be
> appreciated, but a weakness I could accept if other items were addressed.
>
> ## Questions For Authors
>
> See above content, if you could provide:
>
> 1. Larger experimental evaluations
> 2. Algorithm blocks for each case
