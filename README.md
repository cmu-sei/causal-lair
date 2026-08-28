# AI Robustness Tool 

The AI Robustness (AIR) tool is a project of the Software Engineering Institute at 
Carnegie Mellon University. The tool allows users to gauge AI/ML classifier performance with
data-based confidence. Modern analytic methods, including Artificial Intelligence (AI) 
and Machine Learning (ML) classifiers, depend on correlations; however, such approaches 
often fail to account for confounding in the data, which prevents accurate modeling of cause
and effect, which can lead to prediction bias.  

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



## System Requirements and Installation

AIR tool can be installed at partner site or run in the SEI environment.
Classified options are not available at the SEI at this point.

**Requirements for running AIR:**

-   **Hardware:**

    -   10+GiB of storage + any additional for your data

    -   12GiB+ memory (Estimate is based on our testing, but may vary)

-   **Software:**

    -   Docker-capable system (i.e., Linux/Mac/Windows)

    -   WSL2/Docker/Docker Desktop software

    -   A text editor

    -   A web browser (used for viewing/interacting with local .html
        files)

-   **User:**

    -   Permissions to run a Docker container and any other supporting
        tools

    -   Local copies of datasets to use with the AIR tool

### Installation Instructions

Having met the usage requirements above, installation is a matter of
copying the container to a location that is accessible from the Docker
host. You'll want to have your data and knowledge files accessible to
the Docker host as well. A sample run command for using the container
would be:

```bash
docker run -it -p 4173:4173 -u root --rm --name airtool airtool-image:latest
```

Flag definitions:

-   4173: Default port that the development server runs on, it can be
    re-mapped if this port is inconvenient in your environment by simply
    changing the docker command.

-   '-u root': Indicates what user the process inside the container will
    think it is running as (Note: Does not mean you need root
    permissions to run the container)

-   '--rm': Indicates to remove the container after you've finished with
    it. If you wish to keep it around, remove this parameter.

-   '--name': provides the name Docker will use to refer to this
    container. This is important, as if you don't choose a name, a new
    one will be assigned every time you run the container. If you are
    not removing the container, you will soon find you are running out
    of hard drive storage, after a handful of runs.

-   'airtool-image:latest': is the tagged name for the container. If you
    loaded the image to a local registry, using:

*docker load \< airtool.tar*\
*docker tag airtool-image:latest*

then the container will be viewable in your local docker registry,
using:

*docker images*

You may wish to add a data volume to your container. A limitation of the
current release is that intermediate products are not stored within the
container. I.e., every run starts from a new state.


**Limitations:**

-   Currently this tool is only equipped to handle binary (in the on/off
    or true/false sense) treatment and binary outcome variables. This is
    largely due to the differences in interpretation resulting from the
    different analyses they require. As a workaround, we provide a
    built-in tool to transform continuous variables into binary (as part
    of step 2).

-   This tool only accepts .rda files for model upload. This is largely
    due to lack of interest but if you have a different model format
    you'd like to use, let us know and we'll try to get your model type
    working!

-   This tool does not actually fix your model but provides a health
    report that identifies areas/variables where bias is likely being
    introduced. It is up to the user to identify and apply appropriate
    remediations based on this information to ensure that their
    classifier is producing the desired results.

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
