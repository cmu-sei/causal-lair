# Data Guidelines

Selecting and preparing the right dataset is one of the most important factors in getting meaningful results from the AIR Tool. This section covers what makes a dataset suitable for AIR analysis and what to watch out for during preparation.

## Key Dataset Guidelines

- Dataset should include most (or as many as possible) of the variables that causally impact the outcome of interest
- Dataset should have fewer than 1,000 variables
- Data should be in CSV format
- Data must be numerical with no alpha characters
- If multiple variables are highly correlated (generally > 0.9 or < -0.9), remove all but one
- No variables that are randomly assigned values (e.g., item numbers)
- No empty cells or missing data
- No variables that are constant values across all cases
- Variable names must have no embedded spaces and must be in the first row of the CSV file

## Other Key Considerations

For time-series data, using data from two time periods can provide meaningful direct causal relationships between variables in the current time period and the next. Causal relationships within the same time period will be much less robust.

The dataset is most helpful if it is either the same data used to build the AI classifier in question, or data that is or could be fed to the classifier to make predictions.

When using the AIR tool to analyze results of an AI model that makes predictions of consequences from taking actions on a system, the analyzed dataset should include variables addressing those actions and consequences in order to provide more accurate (de-confounded) and complete information.

## AI-Readiness Checklist

Leveraging the Earth Science Information Partners (ESIP) Checklist to Examine AI-readiness for Open Environmental Datasets, the SEI has identified dataset readiness conditions that are likely to ensure successful application of the current version of the AIR Tool.

[Annotated ESIP Checklist (PDF)](https://github.com/cmu-sei/causal-lair/blob/main/doc/log_retrieval_instructions_files/media/data_guidelines_ESIP.pdf)

The full annotated checklist with SEI notes is available in the [ESIP Checklist](esip-checklist.md) subchapter.
