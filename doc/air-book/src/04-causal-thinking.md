# Understanding Causal Thinking

The AIR Tool is built on a branch of statistics and computer science called causal inference. If you are coming to it primarily as an AI/ML practitioner, or primarily as a domain expert, some of the ideas underlying the tool may be unfamiliar. This section introduces the core concepts you need in order to use the tool effectively and interpret its results with confidence. [Key Concepts and Reference](05-key-concepts.md) provides a deeper technical reference for those who want to go further.

## Correlation Is Not Enough

Most AI and machine learning classifiers work by finding patterns — correlations — in data. A model trained to predict equipment failure, for example, learns which combinations of sensor readings tend to precede failures in the historical record. This works well when the future looks like the past. But correlation alone cannot tell you *why* something happens, only that two things tend to occur together.

This distinction matters enormously in practice. A model might learn that a particular sensor reading correlates with failure — not because the sensor reading causes the failure, but because both are caused by a third factor the model never directly observed. When conditions change and that hidden factor behaves differently, the correlation weakens or disappears, and the model's predictions degrade. The model was never actually tracking the mechanism behind failure; it was tracking a symptom.

This is the core problem the AIR Tool is designed to detect.

## What Is a Confounder?

A **confounder** is a variable that influences both the thing you are studying (the treatment or experimental variable) and the outcome you care about, without being part of the causal path between them. Because a confounder affects both sides of the relationship, it creates a spurious correlation that can mislead a model into making biased predictions.

A classic example: ice cream sales and drowning rates are positively correlated. A naive model might conclude that ice cream causes drowning. The confounder, of course, is summer heat — it drives both ice cream consumption and swimming, and therefore both ice cream sales and drowning rates rise together. No amount of restricting ice cream sales will reduce drowning.

In operational AI/ML systems, confounders are often less obvious but just as consequential. A classifier predicting mission success might appear to perform well during training but fail in the field because a confounding variable — present consistently in training data but varying in deployment — was quietly driving the predictions all along.

## Causation and Causal Graphs

Causal inference provides tools to reason explicitly about cause and effect, rather than relying solely on correlation. The foundation is the **causal graph** (also called a directed acyclic graph, or DAG) — a diagram in which nodes represent variables and arrows represent causal relationships. An arrow from variable A to variable B means that A directly influences B.

Causal graphs make your assumptions about the data-generating process explicit and visible. This is powerful for two reasons. First, it allows subject matter experts to contribute their knowledge directly — a data scientist may not know which variables causally precede others, but an operational analyst often does. Second, once the graph is established, it can be used mathematically to identify which variables need to be accounted for (adjusted for) in order to isolate the true causal effect of interest.

The AIR Tool builds this causal graph automatically from your data using a process called **causal discovery**, then uses it to perform the subsequent analysis steps.

## The Three Steps of Causal Analysis

Understanding what the AIR Tool is doing at each stage helps you interpret its outputs and respond appropriately when something looks unexpected.

**Step 1 — Causal Discovery** asks: what does the causal structure of this data look like? The tool examines statistical relationships in your dataset and, guided by the hierarchy of variables you provide in the knowledge file, constructs a causal graph. This graph represents its best inference about which variables cause which others.

**Step 2 — Causal Identification** asks: given this causal graph, what do we need to control for in order to estimate the true effect of the treatment variable on the outcome variable? This step identifies the confounders — variables that could be distorting the relationship — and determines which sets of variables, if adjusted for, would allow an unbiased estimate of the causal effect.

**Step 3 — Causal Estimation** asks: what is the actual magnitude of the causal effect, and how does your model's estimate compare to it? The tool calculates the Average Treatment Effect (ATE) — how much the outcome changes, on average, when the treatment variable changes — using the adjustment sets identified in Step 2. It then compares this causally-derived estimate against the ATE produced by your AI/ML model. A significant discrepancy is evidence of confounding bias in your model.

## Why This Matters for AI Robustness

A well-trained model can look excellent on held-out test data and still be making predictions for the wrong reasons. If the patterns it learned were driven by confounders rather than true causal relationships, the model is brittle — it will degrade when the distribution of those confounders shifts, which happens constantly in real-world operational environments.

The AIR Tool does not replace your model or retrain it. What it does is give you an independent, causally-grounded check on whether your model's predictions are tracking real causal mechanisms or spurious correlations. Think of it as a health check: a clean result gives you evidence-based confidence in your model; a flagged result tells you specifically which variables are likely responsible for the bias and where to focus remediation efforts.

## What You Do Not Need to Know

You do not need to be a statistician or a causal inference researcher to use the AIR Tool effectively. The mathematics underlying causal discovery, identification, and estimation are handled internally. What the tool requires from you — and what no algorithm can substitute for — is **domain knowledge**: an understanding of your variables, your operational scenario, and the rough causal hierarchy among the factors at play. That knowledge, encoded in the knowledge file and the variable definitions you provide, is what allows the tool to produce results that are meaningful rather than merely mathematical.

If you want to go deeper into the theory behind any of these steps, [Key Concepts and Reference](05-key-concepts.md) provides curated references for each.
