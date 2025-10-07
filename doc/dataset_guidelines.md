# AIR Tool Dataset Guidelines    

These dataset guidelines are intended to inform organizations selecting datasets to be analyzed with the AIR tool.  

## Key dataset guidelines include: 

- Dataset should include most (or as many as possible) of the variables that causally impact the outcome of interest 

- Dataset should have fewer than 1000 variables  

- Data should be in CSV format  

- Data must be numerical with no alpha characters  

- If multiple variables are highly correlated to each other (correlations generally > 0.9 or < -0.9), remove all but one 

- No variables that are randomly assigned values (e.g., item numbers)  

- No empty cells/missing data   

- No variables that are constant values across all cases  

- Variable names must have no embedded spaces and must be in the first row of the CSV file 

## Other key considerations for dataset selection include:   

For ​Time Series Data, using data from two time periods can provide meaningful direct causal relationships between variables in the current time period and the next time period.​ Causal relationships within the same time period (whether current or next) will be much less robust. 

The dataset is most helpful if it is either the same data that was used to build the AI classifier in question or if it is data that is otherwise fed (or could be fed) to the AI classifier to make predictions. 

When using the AIR tool to analyze results of an AI model that makes predictions of the consequences from taking certain actions on a system, the analyzed dataset should include variables addressing those actions and consequences in order to provide more accurate (de-confounded) and complete information. 


## AI-readiness Checklist  

Leveraging the Earth Science Information Partners (ESIP) Checklist to Examine AI-readiness for Open Environmental Datasets, we have identified the dataset readiness conditions that are likely to ensure successful application of the current version of the AIR Tool.

[Annotated ESIP Checklist](./log_retrieval_instructions_files/media/data guidelines ESIP.pdf")

To indicate dataset attributes important to successful AIR Tool application and evaluation, we have: 

>Applied Bold/Underline: Emphasized select checklist questions that are relevant to application of the AIR Tool  

>Highlighted in Blue: Emphasize when a particular response to the checklist question is re-quired by the AIR Tool 

>Highlighted in Yellow: Additional notes to elaboration on the applicability of the check-list question to the AIR Tool. 

<img src="./log_retrieval_instructions_files/media/welcome_message.png"
  alt="AIR Tool welcome message." />
