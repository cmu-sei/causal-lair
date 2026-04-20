# Troubleshooting

## Log Retrieval

If you wish to capture a log of activity occurring while using the AIR Tool, begin by returning to the Docker Desktop application.

### Step 1: Return to Docker Desktop

In the Docker Desktop Terminal, the prompt should look like this:

![Docker Desktop terminal showing active session prompt](../../images/image11.png)

End the session by pressing **Ctrl+C**, which should change the prompt:

![Docker Desktop terminal after pressing Ctrl+C](../../images/image12.png)

### Step 2: Access Logs

To view the logs, enter:

```
tree logs
```

Note the most recent log in the output.

![Tree logs output showing log directory structure](../../images/image13.png)

![Log directory listing with most recent log highlighted](../../images/image14.png)

### Step 3: View Log Details

To view log details, enter the following command using your log name:

```
tail -f logs/LOGNAME/airtool.log
```

Example:

```
tail -f logs/2025-09-04_14-44-22/airtool.log
```

![Terminal showing airtool.log output](../../images/image15.png)

---

## Common Problems

### Variables not selectable in Step 2

Experimental (x) variables that have no inputs or no outputs cannot be selected in the tool. If a variable you expect to select is unavailable, review the causal graph from Step 1 — the variable may not have the connections expected. Refer to [Causal Graph Checks](step1-causal-graph.md) for guidance on diagnosing graph issues.

### Data file issues

Ensure your data file meets all requirements outlined in [Input Data Files](input-files.md). Common causes of upload failure include spaces in variable names, missing values, and constant columns.

---

## Contact and Support

If you encounter issues not covered here, reach out to the AIR Tool team:

**Email:** tailor-help@sei.cmu.edu
