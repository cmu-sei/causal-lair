# Interpreting Results

The results page requires no input but displays the entire AIR health report. The blue **Download** button on the lower left allows you to download a PDF summary.

Refreshing the browser or clicking **Reload** on the lower left will reset the tool and allow you to begin a new analysis.

More detailed information can be found in [Interpreting AIR Results](https://github.com/cmu-sei/causal-lair/blob/main/doc/interpreting_results.md).

## Layout

**Left panel:** The causal graph with both x and y variables highlighted in blue/purple. If additional nodes are found to be contributing significant bias, they will be highlighted in red.

**Top right panel:** The Risk Difference chart.

**Bottom right panel:** A custom text-based interpretation summarizing the results from all steps, generated uniquely for each session.

## Risk Difference Chart

The Risk Difference chart compares the average treatment effect (ATE) estimated by the AIR tool with your AI/ML model's ATE. The AIR tool ATE estimates are combined at the bottom of the chart into a single horizontal red-yellow-green bar that serves as a reference for determining whether there is bias in your model's classifications.

The x-axis ranges from negative to positive effect, where a change in treatment either decreases or increases the likelihood of the outcome, respectively. The midpoint corresponds to no statistically significant effect detected.

![Risk Difference chart showing ATE comparison](../../images/image9.png)

### Interpreting the Risk Difference Chart

**BLUE arrow in GREEN region:** Statistical testing failed to find evidence of confounding bias. Consider periodically re-testing as data may change over time.

**BLUE arrow in YELLOW region:** There is some evidence of bias, but it is weak or uncertain. Continue monitoring with the AIR Tool in case the arrow moves into the RED region.

**BLUE arrow in RED region:** There is statistically significant evidence that your AI/ML model exhibits confounding bias. Consider obtaining better measures of the variables in the adjustment sets, gathering more training data, and retraining your classifier. Note that there is no guarantee additional training will fully de-bias the model. If the model continues to make biased predictions after retraining, you might consider modeling the bias itself and adjusting the model output accordingly.

## Causal Graph

The Causal Graph indicates which variables are likely causing confounding of the relationship between the experimental variable and the outcome variable.

![Causal graph with confounding variables highlighted in red](../../images/image10.png)

- If your model's ATE is **not within** both AIR-calculated 95% confidence intervals, the red variables (or their causal ancestors) are likely introducing bias into your model's results.
- If your model's ATE is **within** the AIR-calculated 95% confidence intervals, the red nodes are simply informative for future potential bias.

## Special Circumstances

### The two 95% confidence intervals do not overlap

This can happen for one of three reasons:

1. **Data quality:** Some kind of measurement error is present. Revisit how the data is defined, collected, and entered.
2. **Unmeasured confounder:** A confounder is not being blocked by at least one of the two adjustment sets. Attempt to identify the missing variable(s) and determine how it might be measured.
3. **Algorithm error:** There is an error in the Causal Discovery or Causal Identification algorithm or its implementation.

Differentiating these causes is difficult. We recommend assuming reason (3) can be rejected, re-examining the provenance of your data, and checking whether key measures might be missing. Please also notify the SEI of any problems encountered at tailor-help@sei.cmu.edu.

### Only one adjustment set indicated

This can happen when there are only a few variables and only one adjustment set could be found in Step 2. In this case, proceed as if there were two adjustment sets and interpret the BLUE arrow position as you would when two adjustment sets are present.
