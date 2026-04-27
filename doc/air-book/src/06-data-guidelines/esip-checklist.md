# ESIP Checklist

The following is the SEI-annotated version of the Earth Science Information Partners (ESIP) Checklist to Examine AI-readiness for Open Environmental Datasets. Items in **bold** are particularly relevant to AIR Tool application. SEI notes appear as blockquotes beneath relevant items.

![Annotated ESIP Checklist excerpt](../../images/image7.png)

To indicate dataset attributes important to successful AIR Tool application, the SEI has:

- **Bold/Underline:** Emphasized checklist questions relevant to AIR Tool application
- **Highlighted in Blue:** Emphasized when a particular response to the checklist question is required by the AIR Tool
- **Highlighted in Yellow:** Additional notes elaborating on the applicability of the checklist question to the AIR Tool

---

## General Information

- Link to the dataset landing page
- Name of the dataset
- Current version of the dataset
- Point of contact for the dataset
- When was the dataset originally published?
- Is this raw data or a derived/processed data product? *Raw / Derived*
- **Is this observational data, simulation/model output, or synthetic data?** *Observed / Modeled / Synthetic*

> *SEI Note: The dataset should include observational data and any features necessary for application of the AIR Tool. The current version does not support processing image or NLP data.*

- Is the data single-source or aggregated from several sources? *Single-source / Aggregated*

---

## Data Quality

### Timeliness

- Will the dataset be updated? *Yes / No*
- If yes, how often? *(near-real-time / hourly / daily / weekly / monthly / yearly / longer than a year)*
- Will there be different stages of update (e.g., preliminary data replaced by a full record)? *Yes / No / Not applicable*
- Should the new version supersede the current version? *Yes / No / Other*

### Completeness

- **Is there any documentation about the completeness of the dataset?** *Yes / No*
- How complete is the dataset compared to the expected spatial coverage? *Complete / Partial / Unknown / Not applicable*
- How complete is the dataset compared to the expected temporal coverage? *Complete / Partial / Unknown / Not applicable*

> *SEI Note: Is this dataset subject to confounding? The current version of the AIR Tool does not currently support significant confounding (i.e., any common causes of two or more variables are themselves captured in the dataset).*

### Consistency

- **Is this dataset self-consistent in that its units, data types, and parameter names do not change over time and space?** *Yes / No / Not applicable*
- Is this dataset's units, data types, and parameter names consistent with similar data collections? *Yes / No / Not applicable*
- Are there processes to monitor for consistency? *Yes / No / Not applicable*

### Bias

- Is there known bias in the dataset? *Yes / No*

> *SEI Note: If yes, provide more information. Ideally, no significant measurement error in the data.*

- Have measures been taken to examine bias? *Yes / No*
- Is the bias metrologically traceable?
- Is there reported bias in the data? *No known bias / Bias found and reported / No information available*

### Other Quality Factors

- Is there quantitative information about data resolution in space and time? *Yes / No / Not applicable*
- Are there published data quality procedures or reports? *Yes / No*
- Is the provenance of the dataset tracked and documented? *Yes / No / Not applicable*
- Are there checksums or other checks for data integrity? *Yes / No / Not applicable*
- **What is the size of the dataset?** (total data volume, dimensionality, number of rows, etc.)

> *SEI Note: Fewer than approximately 1,000 variables is strongly preferred. The current version does not support images.*

---

## Data Documentation

- Does the dataset metadata follow a community/domain standard? *Yes / No / Not applicable*
- Is the dataset metadata machine-readable? *Yes / No / Not applicable*
- Does it include details on the spatial and temporal extent? *Yes / No / Not applicable*
- **Is there a comprehensive data dictionary/codebook that describes what each element means?** *Yes / No / Not applicable*
- Is the data dictionary machine-readable? *Yes / No / Not applicable*
- Do the parameters follow a defined standard? *Yes / No / Not applicable*
- Are parameters crosswalked in an ontology or common vocabulary (e.g., NIEM)? *Yes / No / Not applicable*
- Does the dataset have a unique persistent identifier (e.g., DOI)? *Yes / No / Not applicable*
- **Is there contact information for subject-matter experts?** *Yes / No / Not applicable*
- Is there a mechanism for user feedback and suggestions? *Yes / No / Not applicable*
- Are there example codes/notebooks/toolkits showing how the data can be used? *Yes / No / Not applicable*
- What is the license for the data?
- **Has this dataset already been used in AI or ML activities?** *Yes / No — Link to publications/reports*

> *SEI Note: "Yes" is strongly preferred as it adds business value for employing the AIR Tool.*

- **Are there recommendations on the intended use of the data, and uses that are not recommended?** *Yes / No / Not applicable*

> *SEI Note: There needs to be one or more controllable (intervenable) variables in the dataset.*

---

## Data Access

- **What are the major file formats?**
- **Is this format machine-readable?** *Yes / No / Not applicable*

> *SEI Note: CSV is preferred.*

- Is the data available in at least one open, non-proprietary format? *Yes / No / Not applicable*
- Does data access require authentication? *Yes / No / Not applicable*
- Can the file be accessed via direct file download? *Yes / No / Not applicable*
- Is there an API or web service to access the data? *Yes / No / Not applicable*
- Is the data available publicly via cloud services? *Yes / No / Not applicable*
- For restricted data, have measures been taken to provide some access while applying appropriate protection for privacy and security? *Yes / No / Not applicable*
  - Has the data been aggregated to reduce granularity? *Yes / No / Not applicable*
  - Has the data been anonymized/de-identified? *Yes / No / Not applicable*
  - Is there secure access to the full dataset for authorized users? *Yes / No / Not applicable*

---

## Data Preparation

- **Have null values/gaps been filled?** *Yes / No / Not applicable*

> *SEI Note: Has functional determinism (e.g., no variable is the sum of two others) and high intercorrelations (> 0.9 or < -0.9) been addressed? Yes / No*

- **Have outliers been identified?** *Yes, tagged / Yes, removed / No / Not applicable*
- **Is the data gridded (regularly sampled in time and space)?** *(Regularly gridded in space / Constant time-frequency / Both / Not gridded / Not applicable)*
- **Are there associated targets or labels for supervised learning techniques?** *Yes / No / Not applicable*

---

## Definitions

### Quality

- **Completeness:** the breadth of a dataset compared to an ideal 100% completion (spatial, temporal, demographic, etc.); important in avoiding sampling bias
- **Consistency:** uniformity within the entire dataset or compared with similar data collections; for example, no changes in units or data types over time
- **Bias:** a systematic tilt in the dataset when compared to a reference, caused for example by instrumentation, incorrect data processing, unrepresentative sampling, or human error
- **Uncertainty:** a parameter characterizing the dispersion of values that could reasonably be attributed to the measurand
- **Timeliness:** the speed of data release compared to when an event occurred or measurements were made
- **Provenance:** identification of the data sources, how it was processed, and who released it
- **Integrity:** verification that the data remains unchanged from the original; also known as data fixity

### Documentation

- **Dataset Metadata:** complete information about the dataset: quality, provenance, location, time period, responsible parties, purpose, etc.
- **Data Dictionary / Codebook:** complete information about the individual variables/measures/parameters within a dataset: type, units, null value, etc.
- **Identifier:** a code or number that uniquely identifies a dataset
- **Ontology:** formalized definitions of concepts within a domain of knowledge, and the nature of the inter-relationships among those concepts

### Access

- **Formats:** standards that govern how information is stored in a computer file (e.g., CSV, JSON, GeoTIFF, etc.)
- **Delivery Options:** mechanisms for publishing open data for public use (e.g., direct file download, API, cloud services, etc.)
- **License / Usage Rights:** information on who is allowed to use the data and for what purposes, including data sharing agreements, fees, etc.
- **Security / Privacy:** protection of data that is restricted in some way (privacy, proprietary/business information, national security, etc.)

---

## References

1. OSTP Subcommittee on Open Science (2019). *Draft AI-ready data matrix.* *(This draft document is not an official publication of the committee.)*
