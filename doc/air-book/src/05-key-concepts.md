# Key Concepts and Reference

The AIR method has three primary steps: (1) causal discovery, (2) causal identification, and (3) causal estimation. Each step leverages innovative research in distinct fields of practice, which can be challenging to understand. Use of the AIR Tool does not require a detailed understanding of any of its steps; however, understanding one or more steps in a little more detail can help users better appreciate what the AIR Tool accomplishes, and better understand the basis for the tool's capabilities and limitations.

As a federally funded research and development center (FFRDC), the SEI bridges the gap between research and practice for government customers.

## Overview Resources

**Can You Rely on Your AI? Applying the AIR Tool to Improve Classifier Performance**
SEI Webcast. May 31, 2024.
<https://www.sei.cmu.edu/library/can-you-rely-on-your-ai-applying-the-air-tool-to-improve-classifier-performance/>

**Measuring AI Accuracy with the AI Robustness (AIR) Tool**
SEI Blog. September 30, 2024.
<https://www.sei.cmu.edu/blog/measuring-ai-accuracy-with-the-ai-robustness-air-tool/>

## AIR Step 1: Causal Discovery

Causal discovery helps answer: What does the underlying causal graph look like? How can we better understand cause-and-effect relationships within our data? Which causal relationships might be contributing confounding bias to scenarios with outcomes of interest? The best-of-breed open-source tool, Tetrad, is at the heart of AIR Step 1.

**Key source**

Pearl, Judea; Glymour, Madelyn; & Jewell, Nicholas. *Causal Inference in Statistics: A Primer.* Wiley. 2016. ISBN: 978-1-119-18684-7.
<https://www.wiley.com/en-ae/Causal+Inference+in+Statistics:+A+Primer-p-9781119186847>

*This textbook is also a key resource for AIR Step 2.*

**Key concepts**

- Observational data (the importance of working with observational data and not only experiments)
- Causation and graphical representation (basic theory of AIR Step 1)
- Causal Markov Condition (what it is and why it is important)
- D-separation (how to know variables X and Y are conditionally independent)
- Bayesian optimization sequential surrogate (BOSS) algorithm and example applications

**Additional resources**

Scheines, Richard. *CCD Summer Short Course 2016: Day 1, AM Session, Part 1.* Center for Causal Discovery. June 23, 2016.
<https://www.youtube.com/watch?v=9yEYZURoE3Y>
*(Includes a description of the open-source tool Tetrad, which is at the heart of AIR Step 1.)*

Matrix algebra introduction (first eight videos):
<https://www.3blue1brown.com/topics/linear-algebra>

Andrews, Bryan; Ramsey, Joseph; Sanchez-Romero, Ruben; Camchong, Jazmin; & Kummerfeld, Erich. *Fast Scalable and Accurate Discovery of DAGs Using the Best Order Score Search and Grow Shrink Trees.* 37th Conference on Neural Information Processing Systems (NeurIPS 2023). 2023.
<https://proceedings.neurips.cc/paper_files/paper/2023/hash/c9cde817d04811ba28e44071bd9f76a5-Abstract-Conference.html>

Ramsey, Joseph. *Tetrad.* Department of Philosophy, Carnegie Mellon University. Accessed October 14, 2024.
<https://www.cmu.edu/dietrich/philosophy/tetrad/>

## AIR Step 2: Causal Identification

Causal identification helps answer: How can we identify paths within the causal graph that are likely to misleadingly influence the estimation of the cause-effect relationships we care about? What nodes/variables might we need to adjust for in order to filter out bias so that we can understand the true causal effect of a scenario on outcomes of interest?

**Key source**

Pearl, Judea; Glymour, Madelyn; & Jewell, Nicholas. *Causal Inference in Statistics: A Primer.* Wiley. 2016. ISBN: 978-1-119-18684-7.
<https://www.wiley.com/en-ae/Causal+Inference+in+Statistics:+A+Primer-p-9781119186847>

**Key concepts**

- Simpson's Paradox
- Structural causal models (modeling causal assumptions)
- The effects of interventions
- The adjustment formula(s)
- The backdoor criterion
- Inverse probability weighting

**Additional resources**

Shpitser, Ilya & VanderWeele, Tyler J. *A Complete Graphical Criterion for the Adjustment Formula in Mediation Analysis.* The International Journal of Biostatistics. Volume 7. Issue 1. 2011.
doi: 10.2202/1557-4679.1297

Pearl, Judea. *The Do-Calculus Revisited.* Pages 3–11. UAI'12: Proceedings of the Twenty-Eighth Conference on Uncertainty in Artificial Intelligence. August 14, 2012.
<https://dl.acm.org/doi/abs/10.5555/3020652.3020654>

Perković, Emilija; Textor, Johannes; Kalisch, Markus; & Maathuis, Marloes H. *Complete Graphical Characterization and Construction of Adjustment Sets in Markov Equivalence Classes of Ancestral Graphs.* Journal of Machine Learning Research. Volume 18. 2018. Pages 1–62.
<https://doi.org/10.48550/arXiv.1606.06903>

## AIR Step 3: Causal Estimation

Causal estimation helps answer: How can we quantify the causal effect? What effect should be seen on the treatment variable in the absence of bias? Is that effect different from what our classifier is predicting?

**Key source**

van der Laan, Mark; Coyle, Jeremy; Hejazi, Nima; Malenica, Ivana; Phillips, Rachael; & Hubbard, Alan. *Targeted Learning in R: Causal Data Science with the tlverse Software Ecosystem.* UC Berkeley, School of Public Health. July 07, 2023.
<https://tlverse.org/tlverse-handbook/>

*(Explores sl3 (super learning) and tmle3 (targeted MLE), where MLE may be either minimum loss-based estimation or maximum likelihood estimation.)*

**Additional resources**

van der Laan, Mark J. & Rose, Sherry. *Targeted Learning: Causal Inference for Observational and Experimental Data.* Springer. 2011. ISBN-10: 1441997814.
<https://link.springer.com/book/10.1007/978-1-4419-9782-1>

Gruber, Susan & van der Laan, Mark J. *tmle: An R Package for Targeted Maximum Likelihood Estimation.* Journal of Statistical Software. Volume 51. Issue 13. November 16, 2012. Pages 1–35.
<https://doi.org/10.18637/jss.v051.i13>

Hoffman, Katherine. *An Illustrated Guide to TMLE, Part I: Introduction and Motivation* [blog post]. KHStats. December 10, 2020.
<https://www.khstats.com/blog/tmle/tutorial>

## Feature Engineering

Feature engineering is a key step performed prior to AIR Tool application in order to derive new variables representing the scenario(s) of interest (i.e., "treatments" that are the focus of "interventions"), the outcomes of interest, and key confounding variables.

**Key sources**

Hira, Anandi; Alstad, Jim; & Konrad, Mike. *Investigating Causal Effects of Software and Systems Engineering Effort.* Joint Software and IT-Cost Forum 2020. Department of Homeland Security Website. 2020.
<https://www.dhs.gov/sites/default/files/publications/it-cast_swsyscausalanalysis_final_hira_alstad_konrad.pdf>
*(About how to search small datasets by employing bootstrapping and null variables.)*

Alstad, Jim; Hira, Anandi; Konrad, Mike; & Brown, A. Winsor. *Revisiting "Investigating Causal Effects of Software and Systems Engineering Effort" Using New Causal Search Algorithms.* BCSSE's COCOMO® and Cost Model Forum. 2022.
<https://boehmcsse.org/events/cocomo-forum-2022/>
*(Explores the early application and evaluation of the BOSS causal discovery algorithm.)*

Carlos, Paradis; Kazman, Rick; & Konrad, Mike. *A Socio-Technical Perspective on Software Vulnerabilities: A Causal Analysis.* Information and Software Technology. Volume 176. December 2024.
<https://doi.org/10.1016/j.infsof.2024.107553>

## Technology Transition

The SEI leverages best practices for socio-technical transition to improve the experience of adopting the AIR Tool for both initial AIR partners and future adopters.

**Key sources**

Miller, Suzanne. *Five Models of Technology Transition to Bridge the Gap Between Digital Natives and Digital Immigrants* [blog post]. SEI Blog. November 13, 2017.
<https://insights.sei.cmu.edu/blog/five-models-of-technology-transition-to-bridge-the-gap-between-digital-natives-and-digital-immigrants/>

Fowler, Priscilla & Levine, Linda. *A Conceptual Framework for Software Technology Transition.* CMU/SEI-93-TR-031. Software Engineering Institute, Carnegie Mellon University. 1993.
<https://insights.sei.cmu.edu/library/a-conceptual-framework-for-software-technology-transition/>
