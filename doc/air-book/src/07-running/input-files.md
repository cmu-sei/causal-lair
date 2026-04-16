# Input Data Files

The AIR Tool requires two input files: a **data file** and a **knowledge file**. Both must be prepared before beginning analysis.

## Data File

### Format Requirements

- Must be tabular `.csv` format with a header specifying variable names with no spaces in the variable names
- Must contain all variables used in the model provided (where applicable)
- Variable names in the data file must be identical to those in the provided model (where applicable)
- Recommended to contain fewer than 1,000 variables. Above this threshold, causal discovery algorithms may slow significantly
- All categorical variables must be one-hot encoded
- All time-series data must be consistently formatted
- No missing or null entries in the data
- Features must have variability (no constant columns) and must not be intentional duplicates of one another

More information can be found in [Dataset Guidelines](../06-data-guidelines/README.md).

### Cautions

**Correlated variables:** If two variables are very highly correlated (> 0.9 or < -0.9), consider removing all but one before running the tool. Very strong correlations can cause one variable to mask the causal relationship of the other.

**Time-series data:** Using data from two time periods provides more meaningful direct causal relationships than data from a single time period. Causal relationships within the same time period will be much less robust.

**Dataset size:** Running the AIR tool multiple times on the same full dataset is not recommended because it increases the risk of false discoveries due to multiple comparisons. If multiple analyses are necessary, use different subsets or partitions of the data.

## Knowledge File

For AIR Step 1 — Causal Discovery — the user is asked to upload a Knowledge File that defines rough hierarchies of levels of causation between variables as determined logically by subject matter experts. This input supports the accuracy and efficiency of the AIR causal learning algorithms.

### Level Definitions

- **Level 0 — Exogenous variables:** These variables are not influenced by any other variables. Often used as starting points for causal graphs.
- **Level 1 — Endogenous variables:** Variables in this level are potentially influenced by those in Level 0 and possibly other Level 1 variables.
- **Level 2 and up — Higher-level variables:** These variables may be influenced by any preceding levels or their own level.

Although it's not necessary to assign every variable to a level, subject matter experts are encouraged to assign as many variables to as many hierarchy levels as logically correct, which will improve tool performance. Two levels are sufficient, but three or more are generally recommended.

### File Format

The Knowledge File should be a CSV with two columns:

- `level` — a numeric value (0–n)
- `variable` — the variable name exactly as written in the data file

Each variable name should appear exactly once. The AIR tool will provide a notification if it detects header formatting issues or variable names that don't appear in the uploaded data.

![Knowledge file format example showing level and variable columns](../../images/image8.png)

Currently, all knowledge assertions must be done ahead of time as in-place editing is not yet supported by the tool.
