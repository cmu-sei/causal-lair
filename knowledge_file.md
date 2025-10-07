# AIR Knowledge File Guidance

For AIR Step 1 – Causal Discovery – the user is asked to upload a Knowledge File that defines rough hierarchies of levels of causation between variables as determined logically by subject matter experts. This input supports the accuracy and efficiency of the AIR causal learning algorithms.

Levels are defined as follows:

- **Level 0 – Exogenous variables**: These variables are not influenced by any other variables. Often used as starting points for causal graphs.

- **Level 1 – Endogenous variables:** Variables in this level are potentially influenced by those in level 0 and possibly other level 1 variables.

- **Level 2 and up – Higher-level variables:** These variables may be influenced by any preceding levels or its own. There can be any number of levels, though as few as three are strictly necessary.

Although it’s not necessary to assign every variable to a level, subject matter experts are encouraged to assign as many variables to as many hierarchy levels as logically correct, which will improve the performance of the tool. Two levels are sufficient, but three or more are generally recommended.

The Knowledge File should be a CSV with two columns. The AIR tool will provide a notification if it detects header formatting issues or when there are variable names in the Knowledge File that don’t appear in the uploaded data.

Here is an example about growing crops with reminders for appropriate formatting and content of the Knowledge File. 


V 0.10.0
