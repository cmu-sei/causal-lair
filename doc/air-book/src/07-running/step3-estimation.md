# Step 3: Estimating the Causal Effect

The tool will now prompt you for information about the model to be tested. You have four options.

## Option 1: Upload Your Model

This choice prompts you to upload a copy of your model. The tool will estimate the average treatment effect (ATE) predicted by your model and compare it against the causally-derived estimates of AIR.

Currently, this tool only accepts models in `.rda` format. If you have a different model format, contact the team and they will try to support your model type.

## Option 2: Provide an ATE

If you can calculate your own ATE, you can input it directly. The AIR Tool accepts ATE values calculated using potential outcome prediction.

For each individual data point in the dataset, calculate potential outcomes as follows:

- **Ŷ₁:** the predicted outcome where the treatment value for all individuals is manually set to 1 (T=1)
- **Ŷ₀:** the predicted outcome where the treatment value for all individuals is manually set to 0 (T=0)

The ATE is the average difference between the two potential outcomes:

```
ATE = (1/N) * Σ (Ŷ₁ᵢ − Ŷ₀ᵢ)
```

See [Calculating ATE](https://github.com/cmu-sei/causal-lair/blob/main/doc/calculating_ATE.md) for more information.

## Option 3: Do It All for Me

This option is for a user who doesn't have a specific model but would like the tool to generate several commonly-used machine learning models to compare against the causally-derived model of AIR. No additional input required.

## Option 4: Just Show Me the Effect

This option allows you to proceed with the AIR analysis without any comparison to a predictive model.

---

Once you have made a selection, click **Calculate Results** to finish the causal estimation portion of the tool.

> **Note:** After this process has started, it cannot be undone. This process typically takes 2–10 minutes to run with a fairly simple model. Once complete, the progress bar will disappear and the results will be displayed.

![Step 3 model selection interface](../../images/image3.png)
