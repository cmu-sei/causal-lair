# Getting Started

## Introduction

Modern analytic methods, including Artificial Intelligence (AI) and Machine Learning (ML) classifiers, depend on correlations; however, such approaches often fail to account for confounding in the data, which prevents accurate modeling of cause and effect and often leads to prediction bias. The AI Robustness (AIR) tool allows users to gauge AI/ML classifier performance with unprecedented confidence.

**Target Audience:** Projects that have an established AI/ML model workflow (or are working to establish an AI/ML model workflow), complete with data dictionaries and subject-matter experts.

## Requirements for Running AIR

The AIR tool can be installed at a partner site or run in the SEI environment. Classified options are not available at the SEI at this point.

### Hardware

- 16 GB of storage (20 GB recommended) + any additional for your data
- 12 GB+ memory (estimate is based on testing and may vary)

### Software

- Docker-capable system (Linux, Mac, or Windows)
- WSL2 / Docker / Docker Desktop
- A text editor
- A web browser (used for viewing/interacting with local `.html` files)

### User

- Permissions to run a Docker container and any other supporting tools
- Local copies of datasets to use with the AIR tool

### Model (if AIR analysis is intended for an existing model)

- Must be an AI/ML model (e.g., classifier) that operates on structured or tabular data, relying on numerical, categorical, or time-series features — not unstructured data such as images, audio, or natural language text
- Should have a single outcome variable that the classifier is predicting (e.g., mission success, threat assessment, component failure)
- Should be run against multiple scenarios to predict the outcome above (e.g., does location affect mission success, does operating system affect threat assessment, does weather affect component failure)
- Should be compatible with use in an R environment and able to utilize a `predict()` function — **or** allow the user to predict output given user-defined input to predict Average Treatment Effect (ATE)
- Must not require GPU acceleration or external hardware not currently supported by the tool
- Unsupervised models, text classifiers, image classifiers, and most applications of generative AI are not currently supported

### Data

- Must be tabular `.csv` format with a header specifying variable names with no spaces in the variable names
- Must contain all variables used in the model provided (where applicable)
- Variable names in the data file must be identical to those in the provided model (where applicable)
- Recommended to contain fewer than 1,000 variables. Above this threshold, causal discovery algorithms may slow significantly
- All categorical variables must be one-hot encoded
- All time-series data must be consistently formatted
- No missing or null entries in the data
- Features must have variability (no constant columns) and must not be intentional duplicates of one another

More information can be found in [Data Guidelines](../06-data-guidelines/README.md).
