# AIR Method Concepts and References  

The  AIR method has  three  primary  steps:  (1)  causal discovery, (2) causal identification, and (3) causal estimation. Each of these steps leverages innovative research in distinct fields of practice, which can be challenging to understand. Use of the AIR Tool does not  require  a  detailed  understanding  of  any  of  its  steps; however, by understanding one or more of the steps in a little more detail, users may develop a deeper appreciation  for  what  the  AIR  Tool  accomplishes,  which can  also  help  users  better  understand  the  basis  for  the tool’s capabilities and limitations. As early adopters prepare to use the AIR Tool, they may also need to perform feature engineering on the dataset.

As a federally funded research and development center (FFRDC), the SEI bridges the gap between research and practice  for  government  customers.  The  SEI’s  approach  to transitioning  technologies  leverages  practices  drawn  from research on socio-technical adoption. We aspire to share these transition practices with our collaborators.

### For  an  overview  of  the  AIR  Tool

Can You Rely on Your AI? Applying the AIR Tool to Improve Classifier Performance

SEI Webcast. May 31, 2024.

[**https://www.sei.cmu.edu/library/can-you-rely-on-your-ai-applying-the-air-tool-to-improve-classifier-performance/**](https://www.sei.cmu.edu/library/can-you-rely-on-your-ai-applying-the-air-tool-to-improve-classifier-performance/)

Measuring AI Accuracy with the AI Robustness (AIR) Tool

SEI Blog. September 30, 2024.

[**https://www.sei.cmu.edu/blog/measuring-ai-accuracy-with-the-ai-robustness-air-tool/**](https://www.sei.cmu.edu/blog/measuring-ai-accuracy-with-the-ai-robustness-air-tool/)

# AIR  Step  1:  Causal  Discovery

Causal discovery helps to answer several questions: What does the underlying causal graph look like? How can  we  better  understand  cause-and-effect  relationships within our data? Which causal relationships might be

contributing  bias  (i.e.,  confounding  bias)  to  scenarios  with outcomes of interest? The best-of-breed open-source tool, Tetrad, is at the heart of AIR Step 1.

### Key source

Pearl,  Judea;  Glymour,  Madelyn;  &  Jewell,  Nicholas. _Causal Inference in Statistics: A Primer._ Wiley. 2016. ISBN: 978-1-119-18684-7.

[**https://www.wiley.com/en-ae/Causal+Inference+in+Statistics%3A+A+Primer-p-9781119186847**](https://www.wiley.com/en-ae/Causal+Inference+in+Statistics%3A+A+Primer-p-9781119186847) 

_The  above  textbook  is  also  a  key  resource  for  AIR  Step  2._

### Key concepts

• Observational  data  (the  importance  of  working  with observational data and not only experiments)

• Causation  and  graphical  representation  (basic  theory  of AIR Step 1)

• Causal  Markov  Condition  (what  it  is  and  why  is  it important)

• D-separation  (how  to  know  variables  X  and  Y  are conditionally independent)

• Bayesian  optimization  sequential  surrogate  (BOSS) algorithm and example applications

### Additional  resources

Scheines,  Richard.  1—  CCD  Summer  Short  Course  2016: Day 1, AM Session, Part 1. Center for Causal Discovery. June 23, 2016.

[**https://www.youtube.com/watch?v=9yEYZURoE3Y**](https://www.youtube.com/watch?v=9yEYZURoE3Y)

This  video  includes  description  of  the  open-source  tool  Tetrad,  which is at the heart of AIR Step 1.

Matrix  algebra (e.g.,  from the  first eight videos  in this  playlist:

[**https://www.3blue1brown.com/topics/linear-algebra**](https://www.3blue1brown.com/topics/linear-algebra)

Andrews, Bryan; Ramsey, Joseph; Sanchez-Romero, Ruben; Camchong, Jazmin; & Kummerfeld, Erich. Fast Scalable and Accurate Discovery of DAGs Using the Best Order Score Search and Grow Shrink Trees. 37th Conference  on  Neural  Information  Processing  Systems (NeurIPS 2023). 2023.

[**https://proceedings.neurips.cc/**](https://proceedings.neurips.cc/paper_files/paper/2023/hash/c9cde817d04811ba28e44071bd9f76a5-Abstract-Conference.html)  [**paper_files/paper/2023/hash/**](https://proceedings.neurips.cc/paper_files/paper/2023/hash/c9cde817d04811ba28e44071bd9f76a5-Abstract-Conference.html)  [**c9cde817d04811ba28e44071bd9f76a5-Abstract-**](https://proceedings.neurips.cc/paper_files/paper/2023/hash/c9cde817d04811ba28e44071bd9f76a5-Abstract-Conference.html)  [**Conference.html**](https://proceedings.neurips.cc/paper_files/paper/2023/hash/c9cde817d04811ba28e44071bd9f76a5-Abstract-Conference.html)

Ramsey,  Joseph.  Tetrad:  Department  of  Philosophy.

_Carnegie  Mellon  University  Website._

October  14,  2024  [accessed].

[**https://www.cmu.edu/dietrich/philosophy/tetrad/**](https://www.cmu.edu/dietrich/philosophy/tetrad/)

# AIR  Step  2:  Causal  Identification

Causal identification helps to answer the following questions: How can we identify paths within the causal graph that are likely to misleadingly influence the estimation  of  the  cause–effect  relationships  that  we  care about? What nodes/variables might we need to adjust for in order to _filter_ out (i.e., account for) bias so that we  can  understand  the  true  causal  effect  of  a  scenario on outcomes of interest? Why use two independently derived adjustment sets for identification?

### Key source

Pearl,  Judea;  Glymour,  Madelyn;  &  Jewell,  Nicholas. _Causal Inference in Statistics: A Primer._ Wiley. 2016. ISBN: 978-1-119-18684-7.

[**https://www.wiley.com/en-ae/Causal+Inference+in+**](https://www.wiley.com/en-ae/Causal%2BInference%2Bin%2B%20Statistics%3A%2BA%2BPrimer-p-9781119186847)  [**Statistics%3A+A+Primer-p-9781119186847**](https://www.wiley.com/en-ae/Causal%2BInference%2Bin%2B%20Statistics%3A%2BA%2BPrimer-p-9781119186847)

### Key concepts

• Simpson’s Paradox

• structural causal models (modeling causal assumptions)

• the effects of interventions

• the adjustment formula(s)

• the  backdoor  criterion

• inverse probability weighting

### Additional  resources

Shpitser,  Ilya  &  VanderWeele,  Tyler  J.  A  Complete Graphical Criterion for the Adjustment Formula in  Mediation  Analysis.  _The  International  Journal  of Biostatistics._ Volume 7. Issue 1. 2011.

doi:  10.2202/1557-4679.1297

Pearl, Judea. The Do-Calculus Revisited. Pages 3–11. UAI’12: _Proceedings of the Twenty-Eighth Conference on Uncertainty in Artificial Intelligence._ August 14, 2012. [**https://dl.acm.org/doi/abs/10.5555/3020652.3020654**](https://dl.acm.org/doi/abs/10.5555/3020652.3020654)

Perković,  Emilija;  Textor,  Johannes;  Kalisch,  Markus; & Maathuis, Marloes H. Complete Graphical

Characterization  and  Construction  of  Adjustment  Sets  in Markov  Equivalence  Classes  of  Ancestral  Graphs.  _Journal of Machine Learning Research._ Volume 18. 2018. Pages

1–62. [**https://doi.org/10.48550/arXiv.1606.06903**](https://doi.org/10.48550/arXiv.1606.06903)

_This  source  addresses  causal  identification  in  a  much  more  general way than the way in which it has been implemented by the SEI._

# AIR  Step  3:  Causal  Estimation

Causal estimation helps to answer many questions: How can we quantify the causal effect? What effect should be seen on the treatment variable in the absence of bias? Is that  effect  different  from  what  our  classifier  is  predicting?

### Key source

van  der  Laan,  Mark;  Coyle,  Jeremy;  Hejazi,  Nima;  Malenica, Ivana; Phillips, Rachael; & Hubbard, Alan. _Targeted  Learning in R: Causal Data Science with the tlverse Software Ecosystem._ UC Berkeley, School of Public Health. July 07, 2023. [**https://tlverse.org/tlverse-handbook/**](https://tlverse.org/tlverse-handbook/)

_This book, tlverse, consists of a collection of R packages to achieve “targeted learning.” In particular, this source explores sl3 (or super learning) and tmle3 (or targeted MLE, where MLE may be either minimum  loss-based  estimation  or  maximum  likelihood  estimation)._

### Additional  resources

van der Laan, Mark J. & Rose, Sherry. _Targeted Learning: Causal  Inference  for  Observational  and  Experimental  Data._ Springer. 2011. ISBN-10 1441997814. [**https://link.**](https://link.springer.com/book/10.1007/978-1-4419-9782-1)  [**springer.com/book/10.1007/978-1-4419-9782-1**](https://link.springer.com/book/10.1007/978-1-4419-9782-1)

Gruber,  Susan  &  van  der  Laan,  Mark  J.  tmle:  An  R  Package for Targeted Maximum Likelihood Estimation. _Journal of Statistical Software._ Volume 51. Issue 13. November 16, 2012.  Pages  1–35. [**https://doi.org/10.18637/jss.v051.i13**](https://doi.org/10.18637/jss.v051.i13)

Hoffman,  Katherine.  An  Illustrated  Guide  to TMLE,
Part  I:  Introduction  and  Motivation  [blog  post].  _KHStats._ December 10, 2020. [**https://www.khstats.com/blog/tmle/tutorial**](https://www.khstats.com/blog/tmle/tutorial)

# Feature Engineering

Feature engineering is a key step performed prior to  AIR Tool application in order to derive new variables representing (or proxies for) the scenario(s) of interest (i.e.,  “treatment[s]”  that  are  the  focus  of  “interventions”), the outcomes of interest (did the interventions “succeed”?), and key confounding variables (i.e., variables thought  to  possibly  drive  or  influence  both  the  scenario[s] and outcomes).

### Key sources

Hira, Anandi; Alstad, Jim; & Konrad, Mike. Investigating Causal Effects of Software and Systems Engineering Effort.  Joint  Software  and  IT-Cost  Forum  2020.  _Department of Homeland Security Website._ 2020. [**https://www.dhs.gov/sites/default/files/publications/it-cast_swsyscausalanalysis_final_hira_alstad_konrad.pdf**](https://www.dhs.gov/sites/default/files/publications/it-cast_swsyscausalanalysis_final_hira_alstad_konrad.pdf)   

_This  source  is  about  how  to  search  small  datasets  by  employing bootstrapping and null variables._

Alstad, Jim; Hira, Anandi; Konrad, Mike; & Brown, A. Winsor. Revisiting “Investigating Causal Effects of  Software and Systems Engineering Effort” Using New Causal Search Algorithms. BCSSE’s COCOMO® and Cost Model  Forum,  Online  Workshop.  _Boehm  Center  for  Systems and Software Engineering Website._ 2022. [**https://boehmcsse.org/events/cocomo-forum-2022/**](https://boehmcsse.org/events/cocomo-forum-2022/)

_This  source  explores  the  early  application  and  evaluation  of  BOSS causal discovery algorithm._

Carlos,  Paradis;  Kazman,  Rick;  &  Konrad,  Mike.  A  Socio- Technical Perspective on Software Vulnerabilities: A Causal Analysis. _Information and Software Technology._ Volume 176. December 2024. [**https://doi.org/10.1016/j.infsof.2024.107553**](https://doi.org/10.1016/j.infsof.2024.107553).

_This  article  explores  the  application  and  evaluation  of  BOSS  causal discovery algorithm in a time-series setting in order to understand the impact of social misbehaviors on productivity._

# Technology Transition

The SEI leverages best practices for socio-technical transition.  Application  of  these  best  practices  is  intended to improve the experience of adopting the AIR Tool for both initial AIR partners and support future adoption.

### Key sources

Miller,  Suzanne.  Five  Models  of  Technology  Transition to  Bridge  the  Gap  Between  Digital  Natives  and  Digital Immigrants [blog post]. _SEI Blog._ November 13, 2017. [**https://insights.sei.cmu.edu/blog/five-models-of-technology-transition-to-bridge-the-gap-between-digital-natives-and-digital-immigrants/**](https://insights.sei.cmu.edu/blog/five-models-of-technology-transition-to-bridge-the-gap-between-digital-natives-and-digital-immigrants/)   

Fowler,  Priscilla  &  Levine,  Linda.  _A  Conceptual  Framework for Software Technology Transition._ CMU/SEI-93-TR-031. Software Engineering Institute, Carnegie Mellon University. 1993. [**https://insights.sei.cmu.edu/library/a-conceptual-framework-for-software-technology-transition/**](https://insights.sei.cmu.edu/library/a-conceptual-framework-for-software-technology-transition/)  


