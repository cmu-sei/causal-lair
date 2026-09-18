# AI Robustness Tool 

The AI Robustness (AIR) tool is a project of the Software Engineering Institute at 
Carnegie Mellon University. The tool allows users to gauge AI/ML classifier performance with
data-based confidence. Modern analytic methods, including Artificial Intelligence (AI) 
and Machine Learning (ML) classifiers, depend on correlations; however, such approaches 
often fail to account for confounding in the data, which prevents accurate modeling of cause
and effect, which can lead to prediction bias.  By employing a body
of research that applies causal learning techniques to
produce causal graphs (causal discovery) and
evaluate cause-effect relationships (causal inference),
AIR can inform feature engineering to resolve bias and
develop robust predictive models and gauge AI and ML
model performance with unprecedented confidence,
improving new and existing models.

Installation and user guidance available at: https://cmu-sei.github.io/causal-lair/index.html

The SEI AIR tool offers a precedent-setting capability to improve the correctness of AI classifications and predictions, increasing confidence in the use of AI in development, testing, and operations decision making.

The AIR tool uses state-of-the art algorithms and techniques to

- build a causal graph from variables in the dataset  
- determine adjustment sets, which allows it to remove any potential bias introduced between X and Y.
- calculate the average risk difference and associated 95% confidence intervals for each adjustment set

In this way, the AIR tool shows when the predictive model can’t be trusted and suggests where it could be improved.

**Target Audience:** Projects that have an established AI classifier
    workflow, complete with data dictionaries and subject-matter
    experts. These release notes are for potential partners that would
    like to install the AIR tool in their own environment.
 
Copyright 2024 Carnegie Mellon University.

NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.

Licensed under a MIT (SEI)-style license, please see license.txt or contact
permission_at_sei.cmu.edu for full terms.

[DISTRIBUTION STATEMENT A] This material has been approved for public release
and unlimited distribution.  Please see Copyright notice for non-US Government
use and distribution.

This Software includes and/or makes use of Third-Party Software each subject to
its own license.

DM24-1686
---

**Title: AI Robustness (AIR) Tool**

**Version: 2.3.0**

**Release Date: 12/18/2024**

## Contact and Support Information

-   **Support Channels:** How users can reach out for help (e.g., email,
    support portal).

-   **Feedback Mechanism:**
    [tailor-help\@sei.cmu.edu](mailto:tailor-help@sei.cmu.edu){.email}

## Security Information

In the current AIR tool, data is not saved or used for any purpose,
other than specified above. When the tool has finished running, the
state is not saved for future use. The user is responsible for the
handling of their source data.

## Licensing and Legal Information

-   **Licensing Terms:** Clarify the usage rights and any licensing
    requirements.

-   **Legal Disclaimers:** Include necessary legal notices.
