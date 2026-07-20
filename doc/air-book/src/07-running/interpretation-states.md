# Interpretation Section — States, Mockups, and Language Suggestions

This document maps every possible interpretation output to the conditions that produce it,
shows a concrete mockup of each, and proposes plain-language rewrites that include richer
context already available in the tool's computations.

Variable names used in mockups: **credit_score** (treatment, X) → **loan_default** (outcome, Y).

---

## 1. What the User Chose (Model Mode)

| UI choice | Internal value | What it means |
|---|---|---|
| Yes: I can upload it | `"Yes"` | User provides a trained R model; AIR runs it against the data to get a predicted effect |
| Yes: I can provide an ATE | `"ATE"` | User supplies a single effect-size number directly |
| No: Do it all for me | `"No"` | AIR trains five classifiers internally and summarises them |
| No: Just show me the effect | `"null"` | No model; user only wants the causal effect from the data |

Modes `Yes`, `ATE`, and `No` all produce a **model ATE** (a flag value) compared to the causal confidence intervals.
Mode `null` currently has **no dedicated interpretation path** — it falls into the model-comparison logic with `flag = 0`, producing misleading text (see §3).

---

## 2. Output States (Model Comparison Modes: Yes / ATE / No)

These states are evaluated in order; the first that applies wins.

---

### State 0 — Computation Failed
**Condition:** `nrow(dfr) == 0`

> *No results — model fitting failed. Check the log.*

---

### State 1 — No Consensus Between Causal Estimates
**Condition:** Z1 and Z2 confidence intervals do not overlap at all.

**Current text:**
> **Consensus Could Not Be Reached for This Scenario.** The two causal analyses do not agree within their confidence ranges. This suggests that the data or model assumptions may not support a stable or consistent causal conclusion for this scenario.

**Suggested rewrite:**
> **The two causal analyses gave conflicting answers.**
>
> AIR computes the effect of *credit_score* on *loan_default* using two different sets of background variables. Here, those two approaches disagree completely — Analysis A estimates the effect at **+5% to +18%**, while Analysis B estimates it at **−8% to +2%**. When the ranges don't even overlap, no single reliable conclusion can be drawn.
>
> Wide uncertainty ranges on one or both estimates often accompany this result and can indicate a small dataset, uncertain relationships in the causal graph, or a missing variable that's driving the disagreement.
>
> **What to do:** Review your causal graph for missing variables or incorrect edges. Consider collecting more data before drawing conclusions.

*New in this version: the actual CI ranges are quoted so the user can see how far apart the analyses are, not just that they disagree.*

---

### State 2 — Analyses Partially Agree but Disagree on Magnitude
**Condition:** Z1 and Z2 CIs overlap, but the point estimates are far enough apart that neither falls inside the other's interval.

**Current text:**
> The causal estimates appear inconsistent, suggesting there may not be enough information to train a reliable model.

**Suggested rewrite:**
> **The two analyses agree on direction but disagree on size.**
>
> Both analyses find that *credit_score* increases the likelihood of *loan_default*, but they differ meaningfully on how large that effect is. Analysis A estimates **+8%** and Analysis B estimates **+28%** — a 20 percentage-point spread. Their confidence ranges do overlap (roughly +10% to +18%), so a causal effect in that region is plausible, but the disagreement means estimates should be treated as rough approximations rather than precise values.
>
> This usually reflects limited data or structural uncertainty in the causal graph, not necessarily a problem with your model.

*New in this version: the actual point estimates are quoted, the overlap region is identified as the most defensible range, and the user gets a concrete sense of the disagreement rather than just a warning.*

---

### State 3 — Standard Interpretation (Z1/Z2 agree; model present)

All remaining cases share the same structure. What varies:

| Signal | Values |
|---|---|
| Consensus range | The overlap of Z1 and Z2 CIs — the most reliable single estimate |
| CI width | Narrow / moderate / wide — used to signal how confident the analysis is |
| Z1/Z2 point estimate proximity | How closely the two analyses agree, beyond just overlapping |
| Model estimation | Underestimating / overestimating / accurate |
| Degree of divergence | How far outside the CI the model is (not just inside/outside) |
| Bias status | Unbiased / partially biased / biased |
| Bias source | Z1 variables (direct drivers of treatment) vs Z2 variables (confounders along the pathway) |
| Classifier spread | `"No"` mode only — consistency across the five internal classifiers |
| Sample size note | Appears when n is small, as a caveat on unbiased or marginal results |

---

#### 3a — Unbiased, Positive Effect, Accurate Model

**Current output (assembled from templates):**
> Your model appears to be accurately estimating the effect that credit_score has on loan_default. Based on the causal analysis, credit_score is expected to have a positive effect on loan_default. As credit_score changes from baseline to experimental values, the likelihood of loan_default increases by about 12–18%. Fortunately, your model is producing unbiased results. Your model's effect is: 0.15. Overall, this suggests your seeing an appropriate change in loan_default as credit_score varies. No evidence of bias is detected at this time. These treatment effect estimates are based on the variables included in your causal graph. If important factors are missing, the results may not represent true causal relationships...

**Suggested rewrite (Yes / ATE mode):**
> **No bias detected.**
>
> Your model's predicted effect of *credit_score* on *loan_default* (15%) is consistent with what the causal analysis expects. Both independent analyses agree that the true effect lies in the range of **14–16%** (Analysis A: 12–18%, Analysis B: 13–17%), and your model falls squarely within that window. The two analyses give nearly identical estimates, which adds confidence to this finding.
>
> The uncertainty range is narrow, meaning the data supports a fairly precise estimate — not just a directional guess.
>
> **What the causal analysis found:** When *credit_score* moves from its baseline range to its experimental range, the probability of *loan_default* increases by roughly **12–18%**.
>
> **Caveat:** These estimates are only as reliable as the causal graph. If an important variable is missing, the true effect may differ.

**Additional paragraph for "No: Do it all for me" mode (classifiers consistent):**
> The five classifiers AIR trained internally also gave consistent predictions, ranging from 13% to 17%. This agreement across different modeling approaches reinforces the conclusion.

**Additional paragraph for "No: Do it all for me" mode (classifiers inconsistent):**
> Note: the five classifiers AIR trained internally gave a wide spread of predictions (5% to 31%). Even though the summary estimate is unbiased, this spread suggests the model may be sensitive to the choice of algorithm. Interpret the specific effect size with caution.

---

#### 3b — Partially Biased, Positive Effect, Overestimating

**Current output:**
> Your model appears to be overestimating the effect that credit_score has on loan_default by roughly 5–9%. Based on the causal analysis, credit_score is expected to have a positive effect on loan_default. As credit_score changes from baseline to experimental values, the likelihood of loan_default increases by about 12–18%. Unfortunately, your model is producing partially biased results. Your model's effect is: 0.24. Overall, this suggests your seeing a larger than expected change in loan_default as credit_score varies. Bias may be introduced through variable(s): age, income (see causal graph)...

**Suggested rewrite:**
> **Possible bias detected.**
>
> Your model predicts that *credit_score* increases the probability of *loan_default* by **24%**, but the causal analysis puts the best estimate at **14–16%** — your model is overstating the effect by roughly **8–10 percentage points**. It falls within one of the two analysis ranges but outside the other, which is a warning sign rather than a definitive verdict.
>
> **Likely source:** The variables *age* and *income* are highlighted in red on the causal graph. These are direct background causes of *credit_score* itself — meaning your model may have learned a relationship that's partly driven by who has high credit scores, rather than what high credit scores do. Adjusting for these variables (or investigating whether they are properly represented in your model) is the recommended next step.
>
> **What the causal analysis found:** A genuine **12–18% increase** in *loan_default* probability as *credit_score* moves from baseline to experimental values. The two analyses agree well (Analysis A: 12–18%, Analysis B: 13–20%), so this range is reliable.

*New in this version: the degree of overshoot is explicit ("8–10 percentage points"), the structural meaning of Z1 bias variables ("direct background causes of the treatment") is explained, and the point estimate proximity between Z1/Z2 is reported.*

---

#### 3c — Biased, Negative Effect, Underestimating

**Current output:**
> Your model appears to be underestimating the effect that credit_score has on loan_default by roughly 8–14%. Based on the causal analysis, credit_score is expected to have a negative effect on loan_default. As credit_score changes from baseline to experimental values, the likelihood of loan_default decreases by about 20–28%. Unfortunately, your model is producing biased results. Your model's effect is: -0.10. Overall, this suggests your seeing a smaller than expected change in loan_default as credit_score varies. Bias may be introduced through variable(s): age, income and/or payment_history (see causal graph)...

**Suggested rewrite:**
> **Bias detected.**
>
> Your model predicts only a **10% decrease** in *loan_default* probability from *credit_score*, but both causal analyses consistently estimate the true effect is a **20–28% decrease** — your model is understating the effect by roughly **10–18 percentage points**. The model's prediction falls outside both analysis ranges, not just one.
>
> **Likely source:** The variables *age*, *income*, and *payment_history* are flagged on the causal graph. *Age* and *income* appear to influence *credit_score* directly (they are direct causes of your treatment variable). *Payment_history* sits on the pathway between *credit_score* and *loan_default*, meaning it may be partially absorbing the effect your model is trying to measure. Together, these variables may be causing your model to underestimate how strongly *credit_score* affects *loan_default*.
>
> **What the causal analysis found:** A genuine **20–28% reduction** in *loan_default* probability when *credit_score* moves from baseline to experimental values. Both analyses agree closely (Analysis A: −20% to −24%, Analysis B: −22% to −28%), giving high confidence in this range.

*New in this version: Z1 variables and Z2 variables are explained with different structural language ("direct causes of the treatment" vs "sits on the pathway"), and the degree of disagreement and its CI-agreement level are both surfaced.*

---

#### 3d — Biased, No Effect (model detects an effect the causal analysis doesn't support)

**Current output:**
> Your model appears to be overestimating the effect that credit_score has on loan_default by roughly 12–16%. Based on the causal analysis, credit_score is expected to have no effect on loan_default. As credit_score changes from baseline to experimental values, the likelihood of loan_default is unlikely to change. Unfortunately, your model is producing biased results. Your model's effect is: 0.14. Overall, this suggests your seeing a larger than expected change in loan_default as credit_score varies. Bias may be introduced through variable(s): age (see causal graph).

**Suggested rewrite:**
> **Bias detected — the relationship your model found may be spurious.**
>
> Your model predicts that *credit_score* has a meaningful effect on *loan_default* (+14%), but the causal analysis finds **no real effect**: both independent analyses agree the true effect is near zero (Analysis A: −3% to +4%, Analysis B: −2% to +5%). Your model's prediction is **17–19 percentage points** above what either analysis supports.
>
> **Likely source:** The variable *age* (highlighted in red) appears to be a direct cause of *credit_score*. It is likely that *age* affects both *credit_score* and *loan_default* independently, creating a statistical association between them that is not a genuine causal effect. Your model may have learned this spurious association rather than a real one.
>
> **What the causal analysis found:** Changing *credit_score* from baseline to experimental values does not meaningfully change the probability of *loan_default*. The two analyses agree on this with narrow confidence ranges, making this a high-confidence finding. The association your model detected is not causally supported.

*New in this version: the actual CI values for "no effect" are shown (so the user understands it's not just zero — it's a bounded claim), the degree of divergence is stated explicitly, and the spurious-association mechanism is explained plainly.*

---

#### 3e — Wide CIs (Uncertainty Modifier, any bias state)

This isn't a separate state — it's an additional sentence that should appear whenever the CI width exceeds a threshold (e.g., > 25 percentage points), regardless of bias status.

**Additional sentence for wide CIs:**
> *Note: the uncertainty range for this analysis is wide (spanning more than 25 percentage points), meaning the data supports only a rough directional conclusion, not a precise effect size. Collecting more data or refining the causal graph may narrow this range.*

**Additional sentence for narrow CIs:**
> *The uncertainty range is narrow, meaning the data supports a fairly precise estimate — not just a directional guess.*

---

## 3. "Just Show Me the Effect" Mode — Currently Missing

When the user selects **"No: Just show me the effect"** (`null`), the code sets `m_ate = 0` and runs the model-comparison logic. This produces text like "your model is underestimating the effect" — but the user has no model. The text is nonsensical.

This mode needs its own interpretation branch that:
- Opens with the consensus range as the headline (the overlap of Z1 and Z2)
- Reports CI width as a confidence signal
- Reports Z1/Z2 point estimate proximity
- Does **not** mention a model, bias, or classifiers
- Still surfaces the Z1/Z2 agreement/disagreement check (States 1 and 2 still apply)

### Proposed mockups for "null" mode

#### null — Positive Effect, Z1/Z2 Closely Agree, Narrow CIs
> **Causal Effect Summary**
>
> Based on your data and causal graph, increasing *credit_score* from its baseline range to its experimental range is associated with a **12–18% increase** in the probability of *loan_default*.
>
> Both independent analyses give nearly identical estimates (Analysis A: 12–18%, Analysis B: 13–17%), and the most defensible single range — where both analyses agree — is **13–17%**. The uncertainty range is narrow, so this is a fairly precise estimate.
>
> **Caveat:** These estimates depend on the variables in your causal graph. If an important variable is missing, the true effect may differ.

#### null — Negative Effect, Z1/Z2 Agree, Moderate CIs
> **Causal Effect Summary**
>
> Based on your data and causal graph, increasing *credit_score* from its baseline range to its experimental range is associated with a **20–28% decrease** in the probability of *loan_default*.
>
> Both analyses agree on direction and are reasonably consistent on magnitude (Analysis A: −20% to −24%, Analysis B: −22% to −28%). The range where both analyses agree is **−22% to −24%**, which is the most reliable estimate. There is moderate uncertainty about the exact size of the effect.

#### null — No Effect, Z1/Z2 Agree
> **Causal Effect Summary**
>
> Based on your data and causal graph, changing *credit_score* from baseline to experimental values does **not meaningfully change** the probability of *loan_default*. Both analyses agree: the effect, if any, is too small to distinguish from random variation.
>
> The range where both analyses agree spans roughly **−3% to +4%**, which the tool treats as no meaningful effect.

#### null — Positive Effect, Wide CIs
> **Causal Effect Summary**
>
> Based on your data and causal graph, increasing *credit_score* from its baseline range to its experimental range is associated with an **increase** in the probability of *loan_default*, but the data does not support a precise estimate. The analysis places the effect somewhere between **+5% and +40%** — a wide range that reflects high uncertainty.
>
> Both analyses agree on direction (positive), but differ on magnitude. Before drawing conclusions about the size of this effect, consider whether additional data or a refined causal graph might tighten this estimate.

#### null — Z1/Z2 Don't Agree (State 1)
> **The two causal analyses gave conflicting answers.**
>
> This means the data cannot reliably support a single conclusion about how *credit_score* affects *loan_default* under the current causal graph. Review the graph for missing variables or uncertain edges, and consider collecting more data before drawing conclusions.

---

## 4. Language Issues in the Current Implementation

### Problem 1: One unbroken sentence chain
All text is concatenated with `paste0(...)`, producing a dense block. Breaking it into a **headline + 2–3 short paragraphs** makes the same information scannable.

### Problem 2: Jargon
Suggested substitutions:

| Current term | Suggested replacement |
|---|---|
| causal estimates | what the causal analysis expects |
| adjustment set / Z1 / Z2 | Analysis A / Analysis B, or "two independent analyses" |
| confidence interval / confidence range | uncertainty range / plausible range |
| ATE | predicted effect / effect size |
| flag | your model's predicted effect |
| treatment level | experimental condition |
| control level | baseline condition |

### Problem 3: "Fortunately/Unfortunately" + bias label without action
"Unfortunately, your model is producing partially biased results" sounds alarming but gives no direction. Rewrite as: **what** is biased, **which variables** are likely causing it, **why** structurally, and **what to do**.

### Problem 4: The disclaimer is boilerplate in every case
The caveat about missing variables is valid, but appending it identically everywhere makes it feel like a legal disclaimer. It should only appear when results are positive or marginal — when bias is already flagged, the disclaimer is redundant.

### Problem 5: The figure caption repeats the interpretation
The "Risk Difference" caption text largely duplicates what the interpretation paragraph says. Consider removing it and letting the interpretation carry all the explanation.

---

## 5. New Data Signals — What They Are and Where They Come From

These signals are all computed today and simply not surfaced in the interpretation text.

| Signal | Where it comes from | What it adds |
|---|---|---|
| **Consensus range** | `lo_overlap` / `hi_overlap` (already computed at line 2065) | The single most defensible effect estimate — where both analyses agree. More actionable than two separate CI bands. |
| **CI width** | `z1_ATE_UCI - z1_ATE_LCI`, same for Z2 | Tells the user whether this is a precise estimate or a rough directional finding. Applies to every state. |
| **Z1/Z2 point estimate proximity** | `abs(z1_ATE - z2_ATE)` | Distinguishes "barely overlapping" from "nearly identical" — a meaningful confidence gradient the current logic collapses to a binary. |
| **Degree of model divergence** | `abs(flag - nearest CI boundary)` | Replaces the vague "biased" label with a concrete number — how far off is the model, in percentage points? |
| **Classifier spread** (`"No"` mode only) | `range(ate_df_all$flag)` — all five ATEs are in `ate_df_all` (line 1514) | If the five classifiers agree, the summary ATE is trustworthy; if they scatter, the bias verdict is less reliable. Currently unused after line 1523. |
| **Z1 vs Z2 structural roles** | Z1 = `Zvars[grp=="Z1"]` (parents of treatment); Z2 = `Zvars[grp=="Z2"]` (confounders of intermediate variables) | Bias variables from Z1 mean the model isn't accounting for *what drives the treatment*. Bias variables from Z2 mean the model is confusing the *mechanism* with the effect. Different diagnoses, currently conflated. |
| **Sample size** | `nrow(df())` | When n is small, even "no bias detected" should carry a note that the analysis may not have had enough data to detect bias if it exists. |

---

## 6. Proposed Code Change for `null` Mode

In `get_ui_interpretation()` (line 2053), add an early return before the CI overlap check:

```r
# --- null mode: no model, just show the causal effect ---
if (isTRUE(rv$model_yn == "null")) {
  # Reuse: flagdir, CI range arithmetic, lo_overlap/hi_overlap, CI width
  # Omit:  all "your model is…" and "bias may be introduced through…" sentences
  # ...return a standalone causal effect summary...
}
```

The `flagdir`, CI range arithmetic, and Z1/Z2 overlap logic can all be reused — the only change is
that none of the model-comparison or bias-source sentences should appear.
