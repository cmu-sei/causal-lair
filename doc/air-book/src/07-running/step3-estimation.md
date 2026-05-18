# Step 3: Estimating the Causal Effect

Step 3 of the AIR Tool offers four analysis paths, ranging from "evaluate the model I already have" to "just tell me the causal effect." The right choice depends on two things: whether you have an existing predictive model to evaluate, and how much of the analysis you want AIR to handle for you.

The four options are:

1. **Yes: I can upload it**
2. **Yes: I can provide an ATE**
3. **No: Do it all for me**
4. **No: Just show me the effect**

The table below summarizes the trade-offs at a glance; each option is described in detail in the sections that follow.

|Option|What you provide|What AIR does|Best when…|
|---|---|---|---|
|Yes: I cam upload it|A trained R model file|Computes ATE from your model, then compares to the causal ATE estimate|You have direct access to your model and want the check of model prediction|
|Yes: I can provide an ATE|A single ATE value from your model|Compares your ATE to the causal ATE estimate|You can query your model but can't easily export it, or your model isn't in R|
|No: Do it all for me|Nothing extra|Trains a battery of predictive models, computes their ATEs, and compares against the causal ATE estimate|You don't have a model yet and want to see how common model families would behave|
|No: Just show me the effect|Nothing extra|Reports the causal ATE estimate only|You only want to know whether X has a reliable causal effect on Y|

## How AIR estimates the ATE

Regardless of which option you choose, the AIR Tool estimates the causal Average Treatment Effect (ATE) using **two independent adjustment sets** identified from the causal graph: one drawn from variables near the treatment, and one from variables near the outcome. Each adjustment set produces its own ATE estimate via TMLE with a SuperLearner ensemble. Agreement between the two estimates is itself a robustness check — when they converge, you have evidence of a stable causal signal; when they diverge, the signal is sensitive to which confounders are controlled for. More information about interpreting adjustment set results can be found at Section 7 Results. 

The "Yes: I can upload it" and "Yes: I can provide an ETA" options layer a comparison on top of this: your model's implied ATE is plotted against the causal ATE estimate's confidence interval on the Ribbon Plot. If your model's ATE falls inside the CI, your model is consistent with the causal evidence. If it falls outside, your model is likely picking up something other than the causal effect.

 More information about interpreting adjustment set results can be found at Section 7 Results. 

## Yes I have a model options

Choose one of the "Yes" options if you already have a predictive model and want to know whether bias might be affecting its predictions. AIR will compute (or accept) the model's Average Treatment Effect and compare it against the causal estimate derived from the data and graph.

### I can upload it

If you have direct access to your model file, you can upload it and let AIR handle the rest. This is the most streamlined option: AIR computes the ATE from your model automatically, then folds that value into the health report alongside the causal analysis. The resulting ATE from your model will appear on the Ribbon Plot in the upper right as a blue arrow once the analysis completes.

> [!warning] The current version of the AIR Tool only accepts R model files (e.g., .rds). Support for Python and other languages is on the roadmap but not yet available.

### I can provide an ATE

If you can query your model with new data but can't easily export it, or if your model is built in a language AIR doesn't yet accept, this option is often the simpler path. You calculate the ATE yourself and enter that value directly into the tool.

The ATE is the average difference between the two potential outcomes:
```
ATE = (1/N) * Σ (Ŷ₁ᵢ − Ŷ₀ᵢ)
```
The value returned is what you'll enter here. AIR uses your value alongside the causal analysis to generate the health report, and the resulting ATE appears on the Ribbon Plot as a blue arrow.
See [Calculating ATE](https://github.com/cmu-sei/causal-lair/blob/main/doc/calculating_ATE.md) for more information.

> [!info] ATE values This field only accepts ATE values between -1 and 1. Values outside this range are automatically clipped to fit, since the ATE is bounded by [-1, 1] by definition. If your hand-calculated value falls outside this range, that's a signal worth investigating. It usually indicates an error in the calculation rather than a genuinely extreme effect.


## No: I don't have a model (or I don't want to evaluate one)

Choose one of the "No" options if you want to investigate the causal relationships in your data without comparing against a specific predictive model. These options are useful when you're deciding _whether_ to use certain data to build a model in the first place, but they're also useful any time you want a causal-only view of an X → Y relationship.

### No: Do it all for me

This option requires no additional input. AIR will train a series of statistical, machine learning, and ensemble models on your data using the chosen X and Y variables. The models trained include:

- Logistic Regression
- Decision Tree
- Support Vector Machine
- Random Forest
- A stacked SuperLearner ensemble consisting of:
    - Generalized Linear Model (i.e., logistic regression)
    - Generalized Linear Model with elastic net regularization
    - XGBoost (eXtreme Gradient Boosted Decision Trees)
    - Earth (R's version of Multivariate Adaptive Regression Splines, i.e. MARS)
    - Feedforward Neural Network
    - Support Vector Machine

Each model trains on the data, predicts Y, and is then queried with X manipulated to produce its own ATE. AIR aggregates these into a mean ATE for display on the Ribbon Plot and reports the spread across model families in the interpretation section.

The point of training a battery of learners rather than a single model is that **the spread itself is informative**. When ATE estimates agree across model families, that's evidence the causal signal is robust to model choice. When they disagree, it tells you the signal is sensitive to which model family is used, and you should be cautious about deploying any single one of them in isolation.

> [!note] This option will be somewhat slower than the others because of the SuperLearner ensemble. 

### No: Just show me the effect

This is the leanest analysis path. AIR skips the predictive-model comparison entirely and reports only the causal effect of X on Y, estimated from the data and graph.

This option answers two distinct questions:

1. **Is the X → Y relationship reliably estimable at all?** The 95% confidence interval on the Ribbon Plot tells you. A tight CI that excludes zero indicates a stable, detectable effect; a wide CI or one straddling zero indicates the relationship can't be pinned down with this data.
2. **If the relationship is reliable, how big is it?** The magnitude of the causal estimate gives you an ATE target to aim for when training a predictive model later — you'll know what effect size your model should be capturing.

## Choosing between options

A few common scenarios:

- **You have an R model and full access to the file** → Upload it. Lowest effort, fullest analysis.
- **You have a model in Python (or any non-R language) but can score new data with it** → Calculate the ATE yourself and use "I can provide an ATE."
- **You're early in a modeling project and haven't picked a model family** → Use "Do it all for me" to see how different model families behave on this problem.
- **You're not building a model — you just want to know if X causes Y** → Use "Just show me the effect."

Once you have made a selection, click **Calculate Results** to finish the causal estimation portion of the tool.

> **Note:** After this process has started, it cannot be undone. This process typically takes 2–10 minutes to run with a fairly simple model. Once complete, the progress bar will disappear and the results will be displayed.

![Step 3 model selection interface](../../images/image3.png)
