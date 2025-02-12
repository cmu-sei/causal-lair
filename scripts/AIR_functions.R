# AIR Tool
#
# Copyright 2024 Carnegie Mellon University.
#
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
# MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
# WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
# INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
# MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
# CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
# TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
#
# Licensed under a MIT (SEI)-style license, please see license.txt or contact
# permission_at_sei.cmu.edu for full terms.
#
# [DISTRIBUTION STATEMENT A] This material has been approved for public release
# and unlimited distribution.  Please see Copyright notice for non-US Government
# use and distribution.
#
# This Software includes and/or makes use of Third-Party Software each subject to
# its own license.
#
# DM24-1686

# change color of nodes in graph
change_node_color <- function(dot_code, node, color) {
  for (i in 1:length(node)) {
    # Create the node definition with the color
    node_definition <- paste0("\"", node[i], "\" [style=filled, fillcolor=", color, "];")
    
    # Append the new node definition to the beginning of the DOT code
    dot_code <- sub("digraph g \\{", paste0("digraph g {\r\n  ", node_definition), dot_code)
  }
  
  return(dot_code)
}
# AIR Tool Functions
AIR_getGraph <- function(data, knowledge){
  # Create a BOSS object with the data
  ts <- TetradSearch$new(data)
  
  # Optionally, add knowledge to specific tiers
  for (i in 1:nrow(knowledge)) {
    ts$add_to_tier(knowledge[i,]$level, knowledge[i,]$variable)
  }
  
  
  # Run the BOSS algorithm
  # graph <- ts$run_boss(penalty_discount = 2)
  ts$use_sem_bic(penalty_discount = 2)
  ts$use_fisher_z(alpha = 0.01)
  graph <- ts$run_boss()
  
  graphtxt <- object_string <- .jcall(ts$print_graph(graph), "Ljava/lang/String;", "toString")
  
  
  # graphtxt <- .jcall("edu/cmu/tetrad/graph/GraphSaveLoadUtils", "Ljava/lang/String;", "graphToDot", graph)
  
  write_file(x = graphtxt, file = "graphtxt.txt")
  
  return(graph)
}

scale_ <- function(x){
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}

runSuperLearner <- function(settings, AIRHome, tv_dir, tv_threshold, ov_dir, ov_threshold){ 
  Z_level <- settings$Z_level
  doc_title <- settings$doc_title
  
  confounders <- strsplit(x = settings$confounders, split = " ")[[1]]
  treatment <- settings$varName
  outcome =  df_vars[df_vars$var == "OV",]$val
  # mediators = df |> select(-c(treatment, outcome, confounders)) |> colnames() # unnecessary unless doing mediation analysis
  
  df <- read_csv(paste0(AIRHome,"/data/datafile.csv")) # can probably remove this as it's likely redundant
  if (tv_dir == ">") {
    df[[treatment]] <- ifelse(df[[treatment]] > tv_threshold, 1, 0)
  } else if (tv_dir == ">=") {
    df[[treatment]] <- ifelse(df[[treatment]] >= tv_threshold, 1, 0)
  } else if (tv_dir == "<") {
    df[[treatment]] <- ifelse(df[[treatment]] < tv_threshold, 1, 0)
  } else if (tv_dir == "<=") {
    df[[treatment]] <- ifelse(df[[treatment]] <= tv_threshold, 1, 0)
  } else if (tv_dir == "=") {
    df[[treatment]] <- ifelse(df[[treatment]] == tv_threshold, 1, 0)
  } 
  if (ov_dir == ">") {
    df[[outcome]] <- ifelse(df[[outcome]] > ov_threshold, 1, 0)
  } else if (ov_dir == ">=") {
    df[[outcome]] <- ifelse(df[[outcome]] >= ov_threshold, 1, 0)
  } else if (ov_dir == "<") {
    df[[outcome]] <- ifelse(df[[outcome]] < ov_threshold, 1, 0)
  } else if (ov_dir == "<=") {
    df[[outcome]] <- ifelse(df[[outcome]] <= ov_threshold, 1, 0)
  } else if (ov_dir == "=") {
    df[[outcome]] <- ifelse(df[[outcome]] == ov_threshold, 1, 0)
  } 

  #### TMLE -------------------------------------
  ##### Define Superlearner -------------------
  # sl3_list_learners("binomial") 
  
  lrnr_mean <- make_learner(Lrnr_mean)
  lrnr_glm <- make_learner(Lrnr_glm)
  # lrnr_pois <- make_learner(Lrnr_glm, family = 'poisson')
  lrnr_hal <- make_learner(Lrnr_hal9001)
  lrnr_nnet <- make_learner(Lrnr_nnet)
  lrnr_rforest <- make_learner(Lrnr_randomForest)
  lrnr_ranger <- make_learner(Lrnr_ranger)
  lrnr_glmnet <- make_learner(Lrnr_glmnet)
  lrnr_xgboost <- make_learner(Lrnr_xgboost, max_depth = 4, eta = 0.01, nrounds = 100)  
  lrnr_earth <- make_learner(Lrnr_earth)  
  
  if (length(confounders) > 1) {
    sl_ <- make_learner(Stack, unlist(list(lrnr_mean, 
                                           lrnr_glm,
                                           lrnr_hal,
                                           lrnr_ranger, 
                                           lrnr_rforest,
                                           lrnr_glmnet, # this is the difference. It needs 2+ confounders
                                           lrnr_xgboost,
                                           lrnr_earth,
                                           lrnr_nnet), 
                                      recursive = TRUE))
  } else {
    sl_ <- make_learner(Stack, unlist(list(lrnr_mean, 
                                           lrnr_glm,
                                           lrnr_hal,
                                           lrnr_ranger, 
                                           lrnr_rforest,
                                           lrnr_xgboost,
                                           lrnr_earth,
                                           lrnr_nnet), 
                                      recursive = TRUE))
  }
  # DEFINE SL_Y AND SL_A 
  # We only need one, because they're the same
  ##### Define Formulae --------------------------
  Q_learner <- Lrnr_sl$new(learners = sl_, 
                           metalearner = Lrnr_nnls$new(convex = T)) # output model
  g_learner <- Lrnr_sl$new(learners = sl_, 
                           metalearner = Lrnr_nnls$new(convex = T)) # treatment model
  learner_list <- list(Y = Q_learner,
                       A = g_learner)
  
  # PREPARE THE THINGS WE WANT TO FEED IN TO TMLE3
  ate_spec <- tmle_ATE(treatment_level = 1, control_level = 0)
  

  
  ##### Nodes ------------------
  nodes_ <- list(W = confounders, # covariates
                 A = treatment,
                 # Z = mediators, # unnecessary unless doing mediation analysis
                 Y = outcome)
  
  ##### RUN TMLE3 -------------------------------
  set.seed(123)
  tmle_fit_ <- tmle3(tmle_spec = ate_spec, 
                     data = df, 
                     node_list = nodes_, 
                     learner_list = learner_list)
  
  tmle_task <- ate_spec$make_tmle_task(df, nodes_)
  
  initial_likelihood <- ate_spec$make_initial_likelihood(
    tmle_task,
    learner_list
  )
  
  ## save propensity score for diagnosis
  propensity_score <- initial_likelihood$get_likelihoods(tmle_task)$A
  propensity_score <- propensity_score * df[,..treatment] + (1 - propensity_score) * (1 - df[,..treatment])
  
  plap_ <- tibble(exposure = df[,..treatment] |> pull(),
                  pscore = propensity_score |> pull())
  
  plap_$sw <- plap_$exposure * (mean(plap_$exposure)/propensity_score) + (1 - plap_$exposure) * ((1 - mean(plap_$exposure)) / (1 - propensity_score))
  
  ##### Save results ----------------------------
  # results to results file
  write.table(cbind(treatment, Z_level, tmle_fit_$summary[,c(8:10)], deparse.level = 0), 
              file = paste0(AIRHome, "/Results.csv"), 
              sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
  
  
  # save outcome predictions for diagnosis
  # initial_likelihood_preds was formerly labeled outcome_preds
  initial_likelihood_preds <- initial_likelihood$get_likelihoods(tmle_task,"Y")
  # define and fit likelihood
  factor_list <- list(
    define_lf(LF_emp, "W"),
    define_lf(LF_fit, "A", sl_),
    define_lf(LF_fit, "Y", sl_, type = "mean")
  )
  likelihood_def <- Likelihood$new(factor_list)
  likelihood <- likelihood_def$train(tmle_task)
  likelihood_values <- rowMeans(likelihood$get_likelihoods(tmle_task,"Y"))
  
  # print("super learner coefficients for PS model")
  g_fit <- tmle_fit_$likelihood$factor_list[["A"]]$learner
  # g_fit$fit_object$full_fit$learner_fits$Lrnr_nnls_TRUE
  
  # print("super learner coefficients for outcome model")
  Q_fit <- tmle_fit_$likelihood$factor_list[["Y"]]$learner
  # Q_fit$fit_object$full_fit$learner_fits$Lrnr_nnls_TRUE
  
  ## generate counterfactuals
  ### counterfactual where all treatments set to 1
  intervention1 <- define_lf(LF_static, "A", value = 1)
  
  cf_likelihood1 <- make_CF_Likelihood(likelihood, intervention1)
  
  cf_likelihood_values1 <- cf_likelihood1$get_likelihoods(tmle_task, "A")
  
  # We can then use this to construct a counterfactual likelihood:
  ### counterfactual where all treatments set to 0
  # set values
  intervention0 <- define_lf(LF_static, "A", value = 0)
  # generate counterfactual likelihood object
  cf_likelihood0 <- make_CF_Likelihood(likelihood, intervention0)
  # get likelihoods from object
  cf_likelihood_values0 <- cf_likelihood0$get_likelihoods(tmle_task, "A")
  # We see that the likelihood values for the A node are all either 0 or 1, as would be expected from an indicator likelihood function. In addition, the likelihood values for the non-intervention nodes have not changed.
  
  
  ## output individual row values
  # df_out <- df[,c(nodes_$A, nodes_$Y, nodes_$W)]
  df_out <- df |> select(nodes_$A, nodes_$Y, nodes_$W)
  df_out$exposure <- plap_$exposure
  df_out$rownum <- rownames(df_out)
  df_out$pscore <- plap_$pscore
  df_out$sw <- plap_$sw
  df_out$tmle_est <- tmle_fit_$estimates[[1]]$IC
  df_out$initial_likelihood_preds <- initial_likelihood_preds
  df_out$likelihood_values <- likelihood_values
  df_out$counterfactual_0 <- cf_likelihood_values0
  df_out$counterfactual_1 <- cf_likelihood_values1
  df_out$g_fit_pred <- g_fit$predict() 
  df_out$Q_fit_pred <- Q_fit$predict()
  
  write_csv(df_out, paste0(AIRHome, "/data/", settings$doc_title,"-data.csv"))
}

processResults <- function(settings, AIRHome, tv_dir, tv_threshold, ov_dir, ov_threshold, model_in){
  # setwd("~/Projects/20221005-MDLAR/Auto_Rmd/")
  treatment <- settings$varName
  outcome <- df_vars[df_vars$var == "OV",]$val
  confounders <-  unique(Zvars$Z) #strsplit(x = settings$confounders, split = " ")[[1]]
  doc_title <- settings$doc_title
  
  set.seed(123)
  
  df <- read_csv(paste0(AIRHome, "/data/datafile.csv"))
  if (tv_dir == ">") {
    df[[treatment]] <- ifelse(df[[treatment]] > tv_threshold, 1, 0)
  } else if (tv_dir == ">=") {
    df[[treatment]] <- ifelse(df[[treatment]] >= tv_threshold, 1, 0)
  } else if (tv_dir == "<") {
    df[[treatment]] <- ifelse(df[[treatment]] < tv_threshold, 1, 0)
  } else if (tv_dir == "<=") {
    df[[treatment]] <- ifelse(df[[treatment]] <= tv_threshold, 1, 0)
  } else if (tv_dir == "=") {
    df[[treatment]] <- ifelse(df[[treatment]] == tv_threshold, 1, 0)
  } 
  if (ov_dir == ">") {
    df[[outcome]] <- ifelse(df[[outcome]] > ov_threshold, 1, 0)
  } else if (ov_dir == ">=") {
    df[[outcome]] <- ifelse(df[[outcome]] >= ov_threshold, 1, 0)
  } else if (ov_dir == "<") {
    df[[outcome]] <- ifelse(df[[outcome]] < ov_threshold, 1, 0)
  } else if (ov_dir == "<=") {
    df[[outcome]] <- ifelse(df[[outcome]] <= ov_threshold, 1, 0)
  } else if (ov_dir == "=") {
    df[[outcome]] <- ifelse(df[[outcome]] == ov_threshold, 1, 0)
  } 
  
  #### read in data ------------------
  # I think these are not necessary...I added the code above to transform the treatment variable and am commenting out all the rest,  just like in the superlearner function
  # df[treatment] <- ifelse(df[treatment] >= 0, 1, 0)
  # df[confounders] <- ifelse(df[confounders] >= 0, 1, 0)
  # df[outcome] <- ifelse(df[outcome] >= 0, 1, 0) # removed the >= for >, because it makes more sense... hopefully that wasn't a mistake
  
  
  #### pre-process data ------------------
  
  #define function to scale values between 0 and 1
  # scale_values <- function(x){(x-min(x))/(max(x)-min(x))}
  # df$images_acquired <- rescale(df$images_acquired)
  
  # split into train/test datasets
  test_size = floor(0.3 * nrow(df))
  samp = sample(nrow(df), test_size, replace = FALSE)
  y_train = df |> select(all_of(outcome)) |> filter(!row_number() %in% samp) |> mutate(!!outcome := factor(.data[[outcome]]))
  x_train = df |> select(-all_of(outcome)) |> filter(!row_number() %in% samp) #since the first column is just ID
  y_test = df |> select(all_of(outcome)) |> filter(row_number() %in% samp) |> mutate(!!outcome := factor(.data[[outcome]]))
  x_test = df |> select(-all_of(outcome)) |> filter(row_number() %in% samp) #since the first column is just ID
  #convert labels to categorical
  # y_train = factor(ifelse(y_train >=0, 1,0))
  # y_test = factor(ifelse(y_test >=0, 1,0))
  
  #Create training set and testing set
  train = cbind(y_train,x_train)
  test = cbind(y_test,x_test)
  
  colnames(train)[1] = "label"
  colnames(test)[1] = "label"
  
  xtest_0 = mutate(x_test, !!treatment := 0)
  xtest_1 = mutate(x_test, !!treatment := 1)
  

  #### check if models need to be created, then do ------------
  if (model_yn == "No") {
    
    ### Regression ----------------
    model_lm <- lm(label~., data = train)
    pred_lm0 = predict(model_lm, xtest_0)
    pred_lm1 = predict(model_lm, xtest_1)
    
    lm_ate = mean(pred_lm1) - mean(pred_lm0)
    #[1] 0.008077147
    
    model_dt <- rpart(label~., data = train, method = "class") #rpart fails when all "labels" are the same value, so we're wrapping a stupid if logic around it to prevent errors
    pred_dt0 = predict(model_dt, xtest_0)[,2]
    pred_dt1 = predict(model_dt, xtest_1)[,2]
    # note: rpart returns two columns for prediction because it's a classifier predicting two classes. We only want its prediction for images_acquired being a success (i.e., '1'), so we just use the corresponding column from the predict() function
    
    dt_ate = mean(pred_dt1) - mean(pred_dt0)
    #[1] 0
    
    ### svm -----------------------------
    model_svm = svm(label ~ ., data = test)
    
    pred_svm0 = predict(model_svm, xtest_0)
    pred_svm1 = predict(model_svm, xtest_1)
    
    svm_ate = mean(as.numeric(pred_svm1)) - mean(as.numeric(pred_svm0))
    #[1] -0.07423194
    
    ### randomForest -------------------
    model_rf = randomForest(label~., data = train, importance = TRUE)
    ###  saving the model ------
    # saveRDS(model_rf, file = paste0(AIRHome, "/input/model.rda"))
    
    pred_rf0 = predict(model_rf, xtest_0)
    pred_rf1 = predict(model_rf, xtest_1)
    
    rf_ate = mean(as.numeric(pred_rf1)) - mean(as.numeric(pred_rf0))
    #[1] 0.0009401413
    
    
    covariate_list <- train |> 
      select(-label) |> names()
    ### superlearner example ----------------------
    task <- sl3::make_sl3_Task(
      data = train,
      outcome = "label",
      covariates = covariate_list
    )

    lrnr_glm <- Lrnr_glm$new()
    lrnr_hal <- Lrnr_hal9001$new()
    lrnr_ranger <- Lrnr_ranger$new()
    lrnr_rforest <- Lrnr_randomForest$new()
    lrnr_glmnet <- Lrnr_glmnet$new()
    lrnr_xgboost <- Lrnr_xgboost$new()
    lrnr_earth <- Lrnr_earth$new()
    lrnr_nnet <- Lrnr_nnet$new()
    lrnr_svm <- Lrnr_svm$new()
    
    sl_ <- sl3::make_learner(Stack, unlist(list(lrnr_glm,
                                                # lrnr_ranger,
                                                lrnr_rforest,
                                                lrnr_glmnet,
                                                lrnr_xgboost,
                                                lrnr_earth,
                                                lrnr_nnet,
                                                lrnr_svm),
                                           recursive = TRUE))
    
    stack <- Stack$new(lrnr_glm, lrnr_ranger,
                       lrnr_rforest, lrnr_glmnet, lrnr_xgboost,
                       lrnr_earth, lrnr_nnet, lrnr_svm )
    
    sl <- Lrnr_sl$new(learners = stack, metalearner = Lrnr_nnls$new())
    
    sl_fit <- sl_$train(task = task)

    sl_preds <- sl_fit$predict(task = task)
    
    
    
    
    prediction_task_0 <- make_sl3_Task(
      data = xtest_0, 
      covariates = names(xtest_0)
    )
    prediction_task_1 <- make_sl3_Task(
      data = xtest_1, 
      covariates = names(xtest_1)
    )
    sl_preds_0 <- rowMeans(sl_fit$predict(task = prediction_task_0))
    sl_preds_1 <- rowMeans(sl_fit$predict(task = prediction_task_1))
    
    # round(sl_preds_0$coefficients, 3)
    sl_ate = mean(sl_preds_1) - mean(sl_preds_0)
    #[1] -0.0158611
    # }
    ### combine and clean all results data ---------------
    results <- read_csv(paste0(AIRHome, "/Results.csv"))
    
    data.frame(results) |> 
      select(-Treatment) |>
      mutate(Group = tolower(Group)) |>
      pivot_longer(cols = -Group, names_to = "category", values_to = "value") |>
      unite("new_col_name", c("Group", "category"), sep = "_") |>
      pivot_wider(names_from = "new_col_name", values_from = "value") |>
      bind_cols(data.frame("algorithm" = c("Logistic Regression","Decision Tree","Random Forest","Support Vector Machine","Stacked Super Learner"),
                           "flag" = c(lm_ate,dt_ate,svm_ate,rf_ate, sl_ate))) |>
      bind_cols(data.frame("Treatment" = outcome)) |>
      mutate(z1_sig = case_when((flag > z1_LCI & flag > z1_UCI) | (flag < z1_LCI & flag < z1_UCI) ~ 1,
                                TRUE ~ 0),
             z2_sig = case_when((flag > z2_LCI & flag > z2_UCI) | (flag < z2_LCI & flag < z2_UCI) ~ 1,
                                TRUE ~ 0),
             significance = max(z1_sig, z2_sig)) |>
      rename(z1_ATE = z1_Mean, z1_ATE_LCI = z1_LCI, z1_ATE_UCI = z1_UCI,
             z2_ATE = z2_Mean, z2_ATE_LCI = z2_LCI, z2_ATE_UCI = z2_UCI) |>
      mutate(avg.cond.ef = (z1_ATE + z2_ATE) / 2,
             Lower.avg.cond.ef = min(z1_ATE_LCI, z2_ATE_LCI),
             Upper.avg.cond.ef = max(z1_ATE_UCI, z2_ATE_UCI)) |>
      write_csv(paste0(AIRHome, "/ResultsOut.csv"))
    
  } else {
    
    if (model_yn == "Yes") {
      # model_in <- read_rds("input/model.rda")
      pred_m0 = predict(model_in, xtest_0)
      pred_m1 = predict(model_in, xtest_1)
      # pred_m0 = predict(model_in, xtest_0)
      # pred_m1 = predict(model_in, xtest_1)
      
      m_ate = mean(as.numeric(pred_m1)) - mean(as.numeric(pred_m0))
    } else if (model_yn == "ATE") {
      m_ate = model_ate
    }
    ### combine and clean all results data ---------------
    results <- read_csv(paste0(AIRHome, "/Results.csv"))
    # results <- read_csv("../airtool_streamlined/data/Results.csv")
    
    data.frame(results) |> 
      select(-Treatment) |>
      mutate(Group = tolower(Group)) |>
      pivot_longer(cols = -Group, names_to = "category", values_to = "value") |> 
      unite("new_col_name", c("Group", "category"), sep = "_") |> 
      pivot_wider(names_from = "new_col_name", values_from = "value") |>
      bind_cols(data.frame("algorithm" = c("Existing Model"),
                           "flag" = c(m_ate))) |>
      bind_cols(data.frame("Treatment" = outcome)) |>
      mutate(z1_sig = case_when((flag > z1_LCI & flag > z1_UCI) | (flag < z1_LCI & flag < z1_UCI) ~ 1,
                                TRUE ~ 0),
             z2_sig = case_when((flag > z2_LCI & flag > z2_UCI) | (flag < z2_LCI & flag < z2_UCI) ~ 1,
                                TRUE ~ 0),
             significance = max(z1_sig, z2_sig)) |>
      rename(z1_ATE = z1_Mean, z1_ATE_LCI = z1_LCI, z1_ATE_UCI = z1_UCI,
             z2_ATE = z2_Mean, z2_ATE_LCI = z2_LCI, z2_ATE_UCI = z2_UCI) |>
      mutate(avg.cond.ef = (z1_ATE + z2_ATE) / 2,
             Lower.avg.cond.ef = min(z1_ATE_LCI, z2_ATE_LCI),
             Upper.avg.cond.ef = max(z1_ATE_UCI, z2_ATE_UCI)) |>
      write_csv(paste0(AIRHome, "/ResultsOut.csv"))
  }
  
  file.rename(from = paste0(AIRHome, "/Results.csv"),
              to = paste0(AIRHome, "/data/Results.csv"))
  
  file.rename(from = paste0(AIRHome, "/ResultsOut.csv"),
              to = paste0(AIRHome, "/data/ResultsOut.csv"))
  
}
