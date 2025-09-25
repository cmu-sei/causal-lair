> Scenario Definition Worksheet

This worksheet can be used to collaboratively gather information needed
for application of the AIR tool to test for model robustness in a
scenario of interest.

Scenario Summary

*Describe the scenario of interest. Include the cause and effect you are
interested in as part of the scenario.*

Impact

*Describe why this scenario provides valuable insight, drives decision
making, etc.*

  --------------------- ----------------------- -------------------------
  Experimental Variable                         

  Variable Label                                

  Definition of                                 
  Treatment                                     

  Outcome Variable                              

  Variable Label                                

  Definition of Success                         
  --------------------- ----------------------- -------------------------

*Note: If more than one variable is to be tested, create the table above
for each variable of interest*

  -------------------- ------------- --------------------------------------------
  Scenario Data                      

  Data Selection       *Describe     
                       selection of  
                       training      
                       data,         
                       deployment    
                       data, or      
                       other data    
                       source, and   
                       impact on     
                       value of AIR  
                       results.*     

  Feature Engineering  *Describe     
  Required             known feature 
                       engineering   
                       required      
                       within the    
                       dataset*      

  Completeness of      *Describe if  
  Causal Data          the dataset   
                       contains all  
                       variables     
                       with causal   
                       impact on the 
                       scenario, or  
                       any known     
                       omissions     
                       from the      
                       dataset.*     

  Known Causal         *Confirm that 
  Hierarchies          SMEs have     
                       provided a    
                       rough logical 
                       hierarchy of  
                       causation     
                       between       
                       variables,    
                       noting any    
                       outstanding   
                       concerns or   
                       questions.*   
  -------------------- ------------- --------------------------------------------

+--------------------+-------------+-----------------------------------+
| Scenario Model     |             |                                   |
+--------------------+-------------+-----------------------------------+
| Model Input to AIR | ☐ Upload    |                                   |
|                    | model into  |                                   |
|                    | AIR         |                                   |
|                    |             |                                   |
|                    | ☐ Input     |                                   |
|                    | model       |                                   |
|                    | Average     |                                   |
|                    | Treatment   |                                   |
|                    | Effect      |                                   |
|                    | (ATE) value |                                   |
|                    |             |                                   |
|                    | ☐ Allow AIR |                                   |
|                    | to create   |                                   |
|                    | model       |                                   |
+--------------------+-------------+-----------------------------------+
| Version of Model   | *Describe   |                                   |
|                    | version,    |                                   |
|                    | owner,      |                                   |
|                    | training of |                                   |
|                    | model under |                                   |
|                    | test for    |                                   |
|                    | r           |                                   |
|                    | obustness.* |                                   |
+--------------------+-------------+-----------------------------------+
| Model ATE          | *Capture    |                                   |
|                    | Average     |                                   |
|                    | Treatment   |                                   |
|                    | Effect for  |                                   |
|                    | this        |                                   |
|                    | scenario as |                                   |
|                    | generated   |                                   |
|                    | by the      |                                   |
|                    | model, if   |                                   |
|                    | known.*     |                                   |
+--------------------+-------------+-----------------------------------+

Additional Notes

*Describe any other important information to understanding and analyzing
this scenario.*

Results

*Describe the results of analyzing the scenario (e.g., no bias found,
bias found but too small to make changes now, bias large enough to
require model updates).*

Issues

*Describe any issues or questions encountered during scenario
preparation, and possible resolutions.*
