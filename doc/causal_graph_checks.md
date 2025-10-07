# AIR Tool Causal Graph Insights 

This job aid describes checks a user can follow to help understand if the causal graph provided by the AIR tool is reasonable.

##  Check 1: Is the tool notifying you that the analysis has not returned a causal graph to display?

### Why might this be happening:

- Failed upload - the data file or knowledge may have failed to successfully upload

- Lack of causal relationship - analysis does not discover any causal relationships among any of the variables

### Potential remediations:

- Ensure that the data conforms to all of the requirements outlined in the Data Guidelines

- Sample size – If you have _very few_ cases in your dataset (e.g., less than 10 rows in your CSV file), then it’s possible that there are too few datapoints to work with to find statistically-significant correlations that are the basis for discovering causal relationships, and causal discovery will then fail to find any edges and therefore output a blank graph. Therefore, gather more data cases for the input dataset and try again.

## Check 2: Are variables from your data not appearing in the causal graph?

### Why might this be happening:

- Lack of causal relationship – missing variable has no causal relationship (or statistically significant correlation) with any other variable in the dataset

- Knowledge file levels - missing variable only has ancestors among the other variables and is not the direct cause of any of them, but the Knowledge File places the missing variable after its ancestors.

### Potential remediations:

- Sample size - Increase your sample size and see if that solves the problem; however, having “no causal relationships” for variable(s) in the dataset and therefore those variables “disappearing” from the causal graph that is output by the AIR Tool is normal tool behavior.

- Knowledge File – Are you confident that the missing variable’s relationships are correctly reflected in the Knowledge file? If not, update Knowledge file so variable is in an earlier tier.

## Check 3: Are there two variables that have a causal connection in the graph that doesn’t correctly reflect the actual relationship?

### Why might this be happening:

- Temporal errors - connection shown violates known temporal reality

- Erroneous relationships - connection shown between variables known to have no causal relationship

- Flipped edges – connection shown between variables is flipped

### Potential remediations:

- Data Quality - If some values for one of the two variables is incorrect, fix that to the extent you can before proceeding. Evaluate the quality of the data you have for the two variables in the causal relationship.

- Knowledge File  – Is this relationship correctly reflected in the Knowledge file? If not, update Knowledge file so precedent variable is in an earlier tier than consequent variable.

- Confounding Variable(s)  – is there a variable not in the dataset that may possibly be affecting both variables that appear in the graph as connected? If possible, collect data for that missing variable and add it to the dataset.

- Time Interval - When including a pair of variables that measure overlapping phenomena in the same time interval, causal search may misinterpret data as flipped edges. Try refining feature engineering of the dataset and adjusting the sampling rate to eliminate the overlap, adding variables and/or cases to the dataset.

- Newly Discovered Relationship – Algorithm may have uncovered relationship not previously recognized.  


## Check 4: Is there a known causal connection between two variables that does not appear in the graph?

### Why might this be happening:

- Missing relationships - known causal relationships between variables are missing from graph

- Variable with no edges - variable with expected relationship has no edges

**Potential remediations:**

- Weak Relationships – If it’s possible that expected causal relationship is very weak between the variables, then this likely does not require further remediation. Make sure the variable you expect to be impacted is correctly identified in Knowledge File.

- Relationship is indirect not direct – If a presumed causal relationship from Variable A to Variable C might be factored through a mediation effect of a third variable (a variable B relates to A and C as follows: A --> B and B --> C). Alternatively, the effect A has on C is mostly through B, and the direct relationship from A to C is weak. Consider further feature engineering to address strongly correlated variables in the dataset.

- Strong correlation with another variable – If a third variable in the dataset is very strongly correlated (positively or negatively) with one of the two variables, that third variable may “mask” or “split” direct causal relation. Consider removing one of the two very strongly correlated variables from the dataset and rerunning the tool. Consider an additional scenario conditioning on different variable.

- Nonlinear relationship - The causal relationship between two variables might be highly nonlinear. Nonlinear relationships are not yet supported in the AIR Tool so will not appear in the graph.  Consider the impact of this missing relationship and determine if you should continue with the AIR tool.


v 0.10.0
