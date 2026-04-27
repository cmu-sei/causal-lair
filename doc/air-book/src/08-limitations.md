# Known Issues and Limitations

## Existing Problems

Issues still present in the current release will be revealed with further testing.

## Limitations

**Multiple runs on the same dataset:** Running the AIR tool multiple times on the same full dataset is not recommended because it increases the risk of false discoveries due to multiple comparisons. Each run introduces a chance of identifying spurious associations that may appear statistically significant but are actually artifacts of random noise. If multiple analyses are necessary, use different versions of the full dataset (subsets, partitions, or new datasets entirely). This phenomenon is true in any statistical analysis and is not specific to the AIR Tool.

**Binary variables only:** The tool is currently only equipped to handle binary (on/off or true/false) treatment and binary outcome variables. A built-in capability to transform continuous variables into binary is provided as a workaround.

**Model format:** The tool only accepts `.rda` files for model upload. If you have a different model format, contact tailor-help@sei.cmu.edu and the team will try to support your model type.

**No model remediation:** The tool does not fix your model but provides a health report that identifies areas and variables where bias is likely being introduced. The user will need to identify and apply appropriate remediations based on this information.
