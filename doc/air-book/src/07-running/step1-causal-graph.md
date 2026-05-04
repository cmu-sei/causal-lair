# Step 1: Building Your Causal Graph

Once the AIR tool is successfully installed and open in the web browser, the first step is to upload your data and knowledge files and build the causal graph.

## Uploading Files

The tool will first prompt you to upload your data file. The blue status bar will confirm when upload is complete. The tool will provide a notification if errors are discovered during upload.

After the data file is uploaded, you will be prompted to upload the knowledge file. Once both files are accepted, a **Build Graph** button will appear.

Once activated, the tool runs Causal Discovery algorithms and displays the resulting causal graph in the main panel. If you are unsatisfied with the graph, you can select new files and re-build until satisfied.

More detailed information about assessing causal graphs can be found in [AIR Tool Causal Graph Insights](https://github.com/cmu-sei/causal-lair/blob/main/doc/causal_graph_checks.md).

![Causal graph displayed in the AIR Tool main panel](../../images/image1.png)
 
## Causal Graph Checks

Use the following checks to evaluate whether the causal graph produced by the tool reflects reasonable expectations before proceeding.

### Check 1: The tool is not returning a causal graph

**Why this might be happening:**
- Failed upload — the data file or knowledge file may have failed to upload successfully
- Lack of causal relationship — the analysis does not discover any causal relationships among any of the variables

**Potential remediations:**
- Ensure that the data conforms to all requirements outlined in the [Data Guidelines](../06-data-guidelines/README.md)
- If you have very few cases (e.g., fewer than 10 rows), there may be too few data points to find statistically significant correlations. Gather more data and try again.

### Check 2: Variables from your data are not appearing in the causal graph

**Why this might be happening:**
- Lack of causal relationship — the missing variable has no causal relationship with any other variable
- Knowledge file levels — the missing variable is placed after its ancestors in the Knowledge File but has no direct causes of its own

**Potential remediations:**
- Increase your sample size
- Review the Knowledge File to confirm that the missing variable's relationships are correctly reflected; if not, update it so the variable is in an earlier tier

### Check 3: Two variables have a causal connection that doesn't correctly reflect the actual relationship

**Why this might be happening:**
- Temporal errors — the connection shown violates known temporal reality
- Erroneous relationships — a connection is shown between variables known to have no causal relationship
- Flipped edges — the direction of the connection is reversed

**Potential remediations:**
- Evaluate data quality for the two variables and correct errors where possible
- Review the Knowledge File to ensure the relationship is correctly reflected
- Consider whether an unmeasured confounding variable might be affecting both variables
- For overlapping phenomena in the same time interval, try refining feature engineering and adjusting the sampling rate
- Note that the algorithm may have uncovered a relationship not previously recognized

### Check 4: A known causal connection between two variables does not appear in the graph

**Why this might be happening:**
- The expected causal relationship may be very weak
- The relationship may be indirect (mediated by a third variable) rather than direct
- A third variable in the dataset may be very strongly correlated with one of the two variables, masking the direct causal relation
- Highly nonlinear relationships are not yet supported in the AIR Tool

**Potential remediations:**
- If the expected relationship is very weak, no further remediation may be required
- Review the Knowledge File to confirm the variable is correctly placed
- Consider removing one of two very strongly correlated variables and rerunning
- Consider the impact of any missing nonlinear relationship and determine whether to continue with the AIR tool
