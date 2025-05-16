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
getLocalTags <- function() {
  if (!isLocal()) {
    return(NULL)
  }
  
  htmltools::tagList(
    htmltools::tags$script(paste0(
      "$(function() {",
      "  $(document).on('shiny:disconnected', function(event) {",
      "    $('#ss-connect-dialog').show();",
      "    $('#ss-overlay').show();",
      "  })",
      "});"
    )),
    htmltools::tags$div(
      id="ss-connect-dialog", style="display: none;",
      htmltools::tags$a(id="ss-reload-link", href="#", onclick="window.location.reload(true);")
    ),
    htmltools::tags$div(id="ss-overlay", style="display: none;")
  )
}

isLocal <- function() {
  Sys.getenv("SHINY_PORT", "") == ""
}

disconnectMessage <- function(
    text = "An error occurred. Please refresh the page and try again.",
    refresh = "Refresh",
    width = 450,
    top = 50,
    size = 22,
    background = "white",
    colour = "#444444",
    overlayColour = "black",
    overlayOpacity = 0.6,
    refreshColour = "#337ab7",
    css = ""
) {
  
  checkmate::assert_string(text, min.chars = 1)
  checkmate::assert_string(refresh)
  checkmate::assert_numeric(size, lower = 0)
  checkmate::assert_string(background)
  checkmate::assert_string(colour)
  checkmate::assert_string(overlayColour)
  checkmate::assert_number(overlayOpacity, lower = 0, upper = 1)
  checkmate::assert_string(refreshColour)
  checkmate::assert_string(css)
  
  if (width == "full") {
    width <- "100%"
  } else if (is.numeric(width) && width >= 0) {
    width <- paste0(width, "px")
  } else {
    stop("disconnectMessage: 'width' must be either an integer, or the string \"full\".", call. = FALSE)
  }
  
  if (top == "center") {
    top <- "50%"
    ytransform <- "-50%"
  } else if (is.numeric(top) && top >= 0) {
    top <- paste0(top, "px")
    ytransform <- "0"
  } else {
    stop("disconnectMessage: 'top' must be either an integer, or the string \"center\".", call. = FALSE)
  }
  
  htmltools::tagList(
    getLocalTags(),
    htmltools::tags$head(
      htmltools::tags$style(
        glue::glue(
          .open = "{{", .close = "}}",
          
          "#shiny-disconnected-overlay { display: none !important; }",
          
          "#ss-overlay {
             background-color: {{overlayColour}} !important;
             opacity: {{overlayOpacity}} !important;
             position: fixed !important;
             top: 0 !important;
             left: 0 !important;
             bottom: 0 !important;
             right: 0 !important;
             z-index: 99998 !important;
             overflow: hidden !important;
             cursor: not-allowed !important;
          }",
          
          "#ss-connect-dialog {
             background: {{background}} !important;
             color: {{colour}} !important;
             width: {{width}} !important;
             transform: translateX(-50%) translateY({{ytransform}}) !important;
             font-size: {{size}}px !important;
             top: {{top}} !important;
             position: fixed !important;
             bottom: auto !important;
             left: 50% !important;
             padding: 0.8em 1.5em !important;
             text-align: center !important;
             height: auto !important;
             opacity: 1 !important;
             z-index: 99999 !important;
             border-radius: 3px !important;
             box-shadow: rgba(0, 0, 0, 0.3) 3px 3px 10px !important;
          }",
          
          "#ss-connect-dialog::before { content: '{{text}}' }",
          
          "#ss-connect-dialog label { display: none !important; }",
          
          "#ss-connect-dialog a {
             display: {{ if (refresh == '') 'none' else 'block' }} !important;
             color: {{refreshColour}} !important;
             font-size: 0 !important;
             margin-top: {{size}}px !important;
             font-weight: normal !important;
          }",
          
          "#ss-connect-dialog a::before {
            content: '{{refresh}}';
            font-size: {{size}}px;
          }",
          
          "#ss-connect-dialog { {{ htmltools::HTML(css) }} }"
        )
      )
    )
  )
}

#' Show a nice message when a shiny app disconnects or errors
#'
#' This function is a version of disconnectMessage() with a pre-set combination
#' of parameters that results in a large centered message.
#' @export
disconnectMessage2 <- function() {
  disconnectMessage(
    text = "Your session has timed out.",
    refresh = "",
    size = 70,
    colour = "white",
    background = "rgba(64, 64, 64, 0.9)",
    width = "full",
    top = "center",
    overlayColour = "#999",
    overlayOpacity = 0.7,
    css = "padding: 15px !important; box-shadow: none !important;"
  )
}

fix_knowledge <- function(df){
  # Store original column names
  original_colnames <- colnames(df)
  
  # Detect numeric vs non-numeric columns
  numeric_cols <- sapply(df, function(col) all(!is.na(suppressWarnings(as.numeric(as.character(col))))))
  # check if column header is missing and data conform to expectations. If so, process and return
  if (any(!is.na(suppressWarnings(as.numeric(original_colnames))))) {
    
    # Confirm exactly one numeric and one character-type column exist
    if (sum(numeric_cols) == 1 && sum(!numeric_cols) == 1) {
      new_colnames <- c("level", "variable")
      new_colnames_ordered <- rep(NA, length(df))
      new_colnames_ordered[numeric_cols] <- "level"
      new_colnames_ordered[!numeric_cols] <- "variable"
      
      # Move original column names to first row
      df <- rbind(setNames(as.list(original_colnames), names(df)), df)
      
      # Now assign the new column names
      colnames(df) <- new_colnames_ordered
    } else {
      return("Unable to read knowledge file data. Please make sure file contains a header with the following column names: level, variable. 'variable' should contain the name of each variable used, and 'level' should be a numeric value to represent an estimated causal hierarchy (see readme file for a detailed description).")
    }  
  } else if (sum(numeric_cols) == 1 && sum(!numeric_cols) == 1) {
      colnames(df)[numeric_cols] <- "level"
      colnames(df)[!numeric_cols] <- "variable"
    } else {
      return("Unable to read knowledge file data. Please make sure file contains a header with the following column names: level, variable. 'variable' should contain the name of each variable used, and 'level' should be a numeric value to represent an estimated causal hierarchy (see readme file for a detailed description).")
    }
  
  return(df)
}

# change color of nodes in graph
# change_node_color <- function(dot_code, node, color) {
#   for (i in 1:length(node)) {
#     # Create the node definition with the color
#     node_definition <- paste0("\"", node[i], "\" [style=filled, fillcolor=", color, "];")
#     
#     # Append the new node definition to the beginning of the DOT code
#     dot_code <- sub("digraph g \\{", paste0("digraph g {\r\n  ", node_definition), dot_code)
#   }
#   
#   return(dot_code)
# }
# 
# change_node_color <- function(dot_code, node, color) {
#   # Create all node definitions as a single string with a single newline separator
#   node_definitions <- paste0("\"", node, "\" [style=filled, fillcolor=", color, "];", collapse = "\n  ")
#   
#   # Replace once, inserting all node definitions
#   dot_code <- sub("digraph g \\{", paste0("digraph g {\n  ", node_definitions), dot_code)
#   
#   return(dot_code)
# }

change_node_color <- function(dot_code, node, color) {
  # Remove any accidental extra quotes from the color string
  color <- trimws(gsub("['\"]", "", color))
  node_definition <- paste0("\"", node, "\" [style=filled, fillcolor=\"", color, "\"];")
  dot_code <- sub("digraph g \\{", paste0("digraph g {\n  ", node_definition), dot_code)
  dot_code <- gsub("\'", "\"", dot_code)
  return(dot_code)
}

AIR_getGraph <- function(data, knowledge){
  headers_string <- "PD\tfrac_ind\tfrac_dep\tunif\t \tBIC\t \t#edges\tn_tests_ind\tn_tests_dep"
  cat(headers_string, "\n")
  
  
  # initialize whether a cpdag meeting the MC threshold has already been found (used in for loop)
  MC_passing_cpdag_already_found = FALSE 
  
  for (i in seq(0,15)) {
    pd <- 0.5 + (i * 0.1)
    # select printing destination
    sink("/dev/null")  # suppress any printing, initially, at each iteration
    
    # Create a BOSS object with the data
    ts <- TetradSearch$new(data)
    
    # Add knowledge to specific tiers
    for (j in 1:nrow(knowledge)) {
      ts$add_to_tier(knowledge[j,]$level, knowledge[j,]$variable)
    }

    # Run the BOSS algorithm
    ts$use_sem_bic(penalty_discount = pd)
    ts$run_boss()
    g2 <- ts$get_java()
    sink()
    sink(sprintf("graphtext%.1f.txt", pd)) # print graph to an external file
    sink()
    
    bic <- g2$getAttribute("BIC")
    num_edges <- g2$getNumEdges()
    
    sink("/dev/null")
    ts$use_fisher_z(use_for_mc = TRUE)
    
    ret <- ts$markov_check(g2)
    sink()
    
    cpdag_graph_when_PD_is_1 <- g2
    if (ret$ad_ind > 0.1) {
      print_param_and_results_string <- 
        sprintf("%.1f\t%.4f  \t%.4f   \t%.4f  \t%.2f  \t%.0f  \t%.0f  \t\t%.0f", 
                pd, ret$frac_dep_ind, ret$frac_dep_dep, ret$ad_ind, bic, num_edges, 
                ret$num_tests_ind, ret$num_tests_dep) 
      cat(print_param_and_results_string, "\n")
      if (MC_passing_cpdag_already_found == FALSE) {
        best_cpdag_seen_so_far <- g2
        best_cpdag_seen_so_far_num_edges <- num_edges
        best_cpdag_seen_so_far_params <- print_param_and_results_string
        MC_passing_cpdag_already_found <- TRUE
      }
      # this needs to be separate
      if (num_edges < best_cpdag_seen_so_far_num_edges) {
        best_cpdag_seen_so_far <- g2
        best_cpdag_seen_so_far_num_edges <- num_edges
        best_cpdag_seen_so_far_params <- print_param_and_results_string
      }
    }
  }
  
  cat("\nThe best cpdag (the one with fewest edges among those for which unif > 0.1) has these attributes:\n")
  cat(headers_string, "\n")
  cat(best_cpdag_seen_so_far_params, "\n")
  
  if (MC_passing_cpdag_already_found == TRUE) {
    graphtxt <- .jcall(best_cpdag_seen_so_far, "Ljava/lang/String;", "toString")
  } else {
    graphtxt <- .jcall(cpdag_graph_when_PD_is_1, "Ljava/lang/String;", "toString")
  }
  
  readr::write_file(x = graphtxt, file = "graphtxt.txt")

  return(list(graphtxt, ts, 
              MC_passing_cpdag_already_found,
              best_cpdag_seen_so_far))
}

AIR_getAdjSets <- function(ts, tv, ov, MC_passing_cpdag_already_found, best_cpdag_seen_so_far){
  TREATMENT_NAME = tv
  RESPONSE_NAME = ov
  MAX_NUM_SETS = 3
  MAX_DISTANCE_FROM_POINT = 4
  MAX_PATH_LENGTH = 4
  NEAR_TREATMENT = 1
  NEAR_RESPONSE = 2
  
  
  cat("Identification parameters: \n")
  cat("    maximum number of adjustment sets = ", MAX_NUM_SETS, "\n")  
  cat("    maximum distance from target endpoint (TREATMENT or RESPONSE) = ", MAX_DISTANCE_FROM_POINT, "\n")  
  cat("    maximum path length = ", MAX_PATH_LENGTH, "\n")  
  
  if (MC_passing_cpdag_already_found == TRUE) {
    cat("Searching for adjustment set(s) on the *** Treatment *** side:\n")
    # Z1
    adj_sets_treatment = ts$get_adjustment_sets(best_cpdag_seen_so_far, TREATMENT_NAME, RESPONSE_NAME,
                                                MAX_NUM_SETS,
                                                MAX_DISTANCE_FROM_POINT,
                                                NEAR_TREATMENT,
                                                MAX_PATH_LENGTH)
    
    ts$print_adjustment_sets(adj_sets_treatment)
    
    cat("Searching for adjustment sets on the *** Response *** side:\n")
    # Z2
    adj_sets_response  = ts$get_adjustment_sets(best_cpdag_seen_so_far, TREATMENT_NAME, RESPONSE_NAME,
                                                MAX_NUM_SETS,
                                                MAX_DISTANCE_FROM_POINT,
                                                NEAR_RESPONSE,
                                                MAX_PATH_LENGTH)
    
    ts$print_adjustment_sets(adj_sets_response)
  } 
  
  ## Initialize flag variables to indicate to AIR Step 3 that no/only one adjustment set is yet found
  flag_no_adjustment_set_found = FALSE
  flag_only_one_adjustment_set_found = FALSE
  
  # Determine the union and differences of the two adjustment sets
  union_of_two_lists = union(adj_sets_treatment, adj_sets_response)
  near_treatment_not_near_response = setdiff(adj_sets_treatment, adj_sets_response)
  near_response_not_near_treatment = setdiff(adj_sets_response, adj_sets_treatment)
  
  cat("Total number of adjustment sets encountered (ignoring duplicates) = ", length(union_of_two_lists), "\n")
  cat("Size of Treatment - Response adjustment sets = ", length(near_treatment_not_near_response), "\n")
  cat("Size of Response - Treatment adjustment sets = ", length(near_response_not_near_treatment), "\n")
  
  ## Now consider all cases where either set (or both sets) of adjustment sets is (are) empty.
  # if both empty, we need to set the corresponding flag:
  if (length(union_of_two_lists) == 0) {
    # Then no adjustment sets and we must be working with a cpdag (at least one undirected
    #   edge) rather than a DAG. (For a DAG, there's always an adjustment set--namely the
    #   set of parents of the treatment variable, which can be empty, but that's still
    #   a valid adjustment set.) There are multiple solutions here, but get the end-user
    #   involved.
    cat("*** No adjustment set found. Either: ")
    cat("Revise knowledge (see AIR job aid) so search result has no undirected edges. ***\n")
    flag_no_adjustment_set_found = TRUE    
  } else if (length(union_of_two_lists)==1) {
    # Only one adjustment set is found altogether, and so we set the corresponding flag:
    flag_only_one_adjustment_set_found = TRUE
    return_first_adj_set  = union_of_two_lists[[1]]
    return_second_adj_set = union_of_two_lists[[1]]  # same adjustment set
  } else {
    # We have at least two distinct adjustment sets; we prefer ones only from each side if practical, so, test alternatives first.
    cat("At least two adjustment sets found. \n")
    
    # if no adjustment set found near response that was not already near treatment:
    if (length(near_response_not_near_treatment) == 0) {
      cat("In this case, there is no adjustment set near response that is not also near treatment.\n")
      return_first_adj_set  = adj_sets_treatment[[1]]
      return_second_adj_set = adj_sets_treatment[[2]]
    } else if (length(near_treatment_not_near_response) == 0) {
      cat("In this case, there is no adjustment set near treatment that is not also near response.\n")
      return_first_adj_set  = adj_sets_response[[1]]
      return_second_adj_set = adj_sets_response[[2]]
    } else {
      # At least one adjustment set is near treatment but not response, and vice versa.
      #   This is the ideal case to obtain greater diversity of adjustment sets, which 
      #   is also why we might want to set max_num_sets higher.
      #   Return two distinct adjustment sets, one from each side.
      cat("In this case, we have found at least one adjustment set near treatment but not near response; and vice versa.\n")
      return_first_adj_set  = near_treatment_not_near_response[[1]]
      return_second_adj_set = near_response_not_near_treatment[[1]]
    }
  }
  
  cat("Summary of results: \n")
  cat("First adjustment set to return: ", return_first_adj_set, "\n")
  cat("Second adjustment set to return: ", return_second_adj_set, "\n")
  cat("Flag status for no adjustment set found: ", flag_no_adjustment_set_found, "\n")
  cat("Flag status for only one adjustment set found: ", flag_only_one_adjustment_set_found, "\n")
  
  ### return the two adjustment sets plus the two flags instead.
  return(list(return_first_adj_set, return_second_adj_set))
}

scale_ <- function(x){
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}

runSuperLearner <- function(settings, AIRHome, tv_dir, tv_threshold, ov_dir, ov_threshold, log_file){ 
  cat(paste0(Sys.time(), " - ","Started superlearner with ",
             paste(c(settings, AIRHome, tv_dir, tv_threshold, ov_dir, ov_threshold), collapse = ", ")), "\n", 
      file = log_file, 
      append = TRUE)
  Z_level <- settings$Z_level
  doc_title <- settings$doc_title
  
  cat("Reading in data\n", file = log_file, append = TRUE)
  confounders <- as.character(strsplit(x = settings$confounders, split = " ")[[1]])
  treatment <- as.character(settings$varName)
  outcome =  as.character(df_vars[df_vars$var == "OV",]$val)
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
  
  cat("Building learner list\n", file = log_file, append = TRUE)
  lrnr_mean <- sl3::make_learner(sl3::Lrnr_mean)
  lrnr_glm <- sl3::make_learner(sl3::Lrnr_glm)
  lrnr_hal <- sl3::make_learner(sl3::Lrnr_hal9001)
  lrnr_nnet <- sl3::make_learner(sl3::Lrnr_nnet)
  lrnr_rforest <- sl3::make_learner(sl3::Lrnr_randomForest)
  lrnr_ranger <- sl3::make_learner(sl3::Lrnr_ranger)
  lrnr_glmnet <- sl3::make_learner(sl3::Lrnr_glmnet)
  lrnr_xgboost <- sl3::make_learner(sl3::Lrnr_xgboost, max_depth = 4, eta = 0.01, nrounds = 100)  
  lrnr_earth <- sl3::make_learner(sl3::Lrnr_earth)  
  if (length(confounders) > 1) {
    sl_ <- sl3::make_learner(sl3::Stack, unlist(list(lrnr_mean, 
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
    sl_ <- sl3::make_learner(sl3::Stack, unlist(list(lrnr_mean, 
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
  Q_learner <- sl3::Lrnr_sl$new(learners = sl_, 
                           metalearner = sl3::Lrnr_nnls$new(convex = T)) # output model
  g_learner <- sl3::Lrnr_sl$new(learners = sl_, 
                           metalearner = sl3::Lrnr_nnls$new(convex = T)) # treatment model
  learner_list <- list(Y = Q_learner,
                       A = g_learner)
  
  # PREPARE THE THINGS WE WANT TO FEED IN TO TMLE3
  ate_spec <- tmle3::tmle_ATE(treatment_level = 1, control_level = 0)
  

  
  ##### Nodes ------------------
  nodes_ <- list(W = confounders, # covariates
                 A = treatment,
                 # Z = mediators, # unnecessary unless doing mediation analysis
                 Y = outcome)
  
  ##### RUN TMLE3 -------------------------------
  set.seed(123)
  ### this is where the parallel is breaking
  cat("Starting TMLE\n", file = log_file, append = TRUE)
  tryCatch({
    tmle_fit_ <- tmle3::tmle3(tmle_spec = ate_spec,
                 data = df,
                 node_list = nodes_,
                 learner_list = learner_list)
  }, error = function(e) {
    cat(sprintf("Error in tmle3 call: %s\n", conditionMessage(e)), 
        file = log_file, append = TRUE)
    stop(e)
  })
  cat("Pulling out TMLE scores\n", file = log_file, append = TRUE)
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
    tmle3::define_lf(LF_emp, "W"),
    tmle3::define_lf(LF_fit, "A", sl_),
    tmle3::define_lf(LF_fit, "Y", sl_, type = "mean")
  )
  likelihood_def <- tmle3::Likelihood$new(factor_list)
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
  intervention1 <- tmle3::define_lf(LF_static, "A", value = 1)
  
  cf_likelihood1 <- tmle3::make_CF_Likelihood(likelihood, intervention1)
  
  cf_likelihood_values1 <- cf_likelihood1$get_likelihoods(tmle_task, "A")
  
  # We can then use this to construct a counterfactual likelihood:
  ### counterfactual where all treatments set to 0
  # set values
  intervention0 <- tmle3::define_lf(LF_static, "A", value = 0)
  # generate counterfactual likelihood object
  cf_likelihood0 <- tmle3::make_CF_Likelihood(likelihood, intervention0)
  # get likelihoods from object
  cf_likelihood_values0 <- cf_likelihood0$get_likelihoods(tmle_task, "A")
  # We see that the likelihood values for the A node are all either 0 or 1, as would be expected from an indicator likelihood function. In addition, the likelihood values for the non-intervention nodes have not changed.
  cat("Building Output\n", file = log_file, append = TRUE)
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
  cat("Finished SuperLearner\n", file = log_file, append = TRUE)
}

processResults <- function(settings, AIRHome, tv_dir, tv_threshold, ov_dir, ov_threshold, model_in, model_yn, model_ate, log_file, move_results = FALSE){
  
  # setwd("~/Projects/20221005-MDLAR/Auto_Rmd/")
  cat(paste0(Sys.time(), " - ","Started processResults() with ",
             paste(c(settings, AIRHome, tv_dir, tv_threshold, ov_dir, ov_threshold, model_yn, model_ate, log_file), collapse = ", ")), "\n", 
      file = log_file, 
      append = TRUE)
  
  treatment <- as.character(settings$varName)
  outcome <- as.character(df_vars[df_vars$var == "OV",]$val)
  confounders <-  as.character(unique(Zvars$Z)) #strsplit(x = settings$confounders, split = " ")[[1]]
  doc_title <- settings$doc_title
  
  set.seed(123)
  cat("Assigned variables\n", file = log_file, append = TRUE)
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
  cat("Read in and stratified data\n", file = log_file, append = TRUE)

  #### check if models need to be created, then do ------------
  if (model_yn == "No") {
    cat("model_yn == no\n", file = log_file, append = TRUE)
    cat("Setting up ML Classifiers\n", file = log_file, append = TRUE)
    
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

    lrnr_glm <- sl3::Lrnr_glm$new()
    lrnr_hal <- sl3::Lrnr_hal9001$new()
    lrnr_ranger <- sl3::Lrnr_ranger$new()
    lrnr_rforest <- sl3::Lrnr_randomForest$new()
    lrnr_glmnet <- sl3::Lrnr_glmnet$new()
    lrnr_xgboost <- sl3::Lrnr_xgboost$new()
    lrnr_earth <- sl3::Lrnr_earth$new()
    lrnr_nnet <- sl3::Lrnr_nnet$new()
    lrnr_svm <- sl3::Lrnr_svm$new()
    
    sl_ <- sl3::make_learner(sl3::Stack, unlist(list(lrnr_glm,
                                                # lrnr_ranger,
                                                lrnr_rforest,
                                                lrnr_glmnet,
                                                lrnr_xgboost,
                                                lrnr_earth,
                                                lrnr_nnet,
                                                lrnr_svm),
                                           recursive = TRUE))
    
    stack <- sl3::Stack$new(lrnr_glm, lrnr_ranger,
                            lrnr_rforest, lrnr_glmnet, lrnr_xgboost,
                            lrnr_earth, lrnr_nnet, lrnr_svm )
    
    sl <- sl3::Lrnr_sl$new(learners = stack, metalearner = sl3::Lrnr_nnls$new())
    
    cat("Fitting ML Classifiers\n", file = log_file, append = TRUE)
    
    sl_fit <- sl3::sl_$train(task = task)

    cat("Pulling ML Classifier Scores\n", file = log_file, append = TRUE)
    
    sl_preds <- sl3::sl_fit$predict(task = task)
    
    prediction_task_0 <- sl3::make_sl3_Task(
      data = xtest_0, 
      covariates = names(xtest_0)
    )
    prediction_task_1 <- sl3::make_sl3_Task(
      data = xtest_1, 
      covariates = names(xtest_1)
    )
    sl_preds_0 <- rowMeans(sl_fit$predict(task = prediction_task_0))
    sl_preds_1 <- rowMeans(sl_fit$predict(task = prediction_task_1))
    
    # round(sl_preds_0$coefficients, 3)
    sl_ate = mean(sl_preds_1) - mean(sl_preds_0)
    #[1] -0.0158611
    # }
    cat("Processing ML Output\n", file = log_file, append = TRUE)
    
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
    cat("model_yn != no\n", file = log_file, append = TRUE)
    if (model_yn == "Yes") {
      cat("model_yn == yes\n", file = log_file, append = TRUE)
      # model_in <- read_rds("input/model.rda")
      pred_m0 = predict(model_in, xtest_0)
      pred_m1 = predict(model_in, xtest_1)
      # pred_m0 = predict(model_in, xtest_0)
      # pred_m1 = predict(model_in, xtest_1)
      
      m_ate = mean(as.numeric(pred_m1)) - mean(as.numeric(pred_m0))
    } else if (model_yn == "ATE") {
      cat("model_yn == ate\n", file = log_file, append = TRUE)
      m_ate = model_ate
    }
    cat("process ate results\n", file = log_file, append = TRUE)
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
  
  if (move_results) {
    cat("moving results files\n", file = log_file, append = TRUE)
    file.rename(from = paste0(AIRHome, "/Results.csv"),
                to = paste0(AIRHome, "/data/Results.csv"))
    
    file.rename(from = paste0(AIRHome, "/ResultsOut.csv"),
                to = paste0(AIRHome, "/data/ResultsOut.csv"))
  }
  
}



## Create four simple methods to help parse a line

# Is the first character of a line a nonzero digit? If yes, then that line specifies an edge.
is_edge_line <- function(line) {
  # regular expression
  return(grepl("^[1-9]", line))
}

# Split a string of space-delimited substrings into a list of those substrings
split_line <- function(input_string) {
  return(strsplit(input_string, " "))
}

# Return the first node from a line specifying an edge (after the line number)
first_node <- function(line) {
  line_components <- split_line(line)
  return(line_components[[1]][2])
}
# Return the second node from a line specifying an edge (after the line number)
second_node <- function(line) {
  line_components <- split_line(line)
  return(line_components[[1]][4])
}

## The key methods defined here are descendants (and its dual: ancestors)
descendants <- function(node, children) {
  checked_so_far <- set()
  seen_not_checked <- set(node)
  while (!set_is_empty(seen_not_checked)) {
    check_these <- seen_not_checked
    for (n in check_these) {
      for (m in children[[n]]) {
        if ( !(m %e% checked_so_far)) {
          seen_not_checked <- seen_not_checked | set(m)
        }
      }
      seen_not_checked <- seen_not_checked - set(n)
      checked_so_far <- checked_so_far | set(n)
    }
  }
  return(checked_so_far)
}

get_X_descendents <- function(TV, PATH) {
  lines <- readLines(paste(PATH, "/graphtxt.txt", sep = ""))
  
  nodes <- set()
  for (line in lines) {
    if (is_edge_line(line)) {
      if (!(first_node(line)  %e% nodes)) {
        nodes <- nodes | set(first_node(line))
      }
      if (!(second_node(line) %e% nodes)) {
        nodes <- nodes | set(second_node(line))
      }
    }
  }

  ## Create children and parents dictionaries
  children <- hash()
  for (n in nodes) {
    children_of_n <- set()
    for (line in lines) {
      if (is_edge_line(line)) {
        if ((first_node(line)  == n) && (!(second_node(line) %e% children_of_n))) {
          children_of_n <- children_of_n | set(second_node(line))
        }
      }
    }
    children[[n]] <- children_of_n
  }
  return(unlist(descendants(TV, children)))
}


get_ribbon_plot <- function(AIRHome) {
  dfr <- read_csv(paste0(AIRHome, "/data/ResultsOut.csv"))
  
  # code for generating ribbon plot
  if (any(dfr$flag >= dfr$z1_ATE_LCI & dfr$flag <= dfr$z1_ATE_UCI)) {
    inZ1 <- TRUE
  } else { inZ1 <- FALSE }
  if (any(dfr$flag >= dfr$z2_ATE_LCI & dfr$flag <= dfr$z2_ATE_UCI)) {
    inZ2 <- TRUE
  } else { inZ2 <- FALSE }
  
  summary_color <- case_when(
    inZ1 == TRUE & inZ2 == TRUE ~ "#378855",
    inZ1 == TRUE | inZ2 == TRUE ~ "#FCB514",
    inZ1 == FALSE & inZ2 == FALSE ~ "#C00000"
  )
  
  dfr0 <- dfr[1,]
  p <- ggplot(dfr0, aes(x = Treatment)) +
    # ggplot(dfr0, aes(x = Treatment)) +
    ## background
    geom_linerange(aes(ymin = -1.05, ymax = 1.05),
                   lwd = 6,
                   col = "black",
                   alpha = 1,
                   stat = "unique",
                   lineend = "round",
                   position = position_nudge(x = 0)) +
    ## Annotations for '-' and '+'
    # annotate("text", x = 0.92, y = -1.07, label = "-", hjust = 0, vjust = 0, size = 5, color = "white") +
    # annotate("text", x = 0.88, y = 1.025,  label = "+", hjust = 0, vjust = 0, size = 5, color = "white") +
    annotate("text", 
             x = 1,  # Position on the left side within the black background
             y = -1,  # Center vertically within the black background
             label = "-", 
             hjust = 2.5, 
             vjust = 0.25, 
             size = 5, 
             color = "white") +
    annotate("text", 
             x = 1,  # Position on the right side within the black background (adjust based on x-axis limits)
             y = 1,  # Center vertically within the black background
             label = "+", 
             hjust = -0.75, 
             vjust = 0.4, 
             size = 5, 
             color = "white") +## algorithm estimates
    ## Z1
    geom_linerange(aes(ymin = z1_ATE_LCI, ymax = z1_ATE_UCI),
                   lwd = 3.5,
                   col = "#9394A2",
                   alpha = 1,
                   stat = "unique",
                   lineend = "round",
                   position = position_nudge(x = 1)) +
    geom_point(aes(y = z1_ATE),
               col = "white",
               cex = 3,
               pch = 1,
               stroke = 1.25,
               position = position_nudge(x = 1)) +
    ## Z2
    geom_linerange(aes(ymin = z2_ATE_LCI, ymax = z2_ATE_UCI),
                   lwd = 3.5,
                   col = "#D4C7C7",
                   alpha = 1,
                   stat = "unique",
                   lineend = "round",
                   position = position_nudge(x = 0.5)) +
    geom_point(aes(y = z2_ATE),
               col = "white",
               cex = 3,
               pch = 1,
               stroke = 1.25,
               position = position_nudge(x = 0.5)) +
    # creating the ribbon
    geom_linerange(aes(ymin = -1, ymax = 1),
                   lwd = 3.5,
                   col = "#C00000",
                   alpha = 1,
                   stat = "unique",
                   lineend = "round",
                   position = position_nudge(x = 0)) +
    geom_linerange(aes(ymin = min(dfr$z1_ATE_LCI, dfr$z2_ATE_LCI), ymax = max(dfr$z1_ATE_UCI, dfr$z2_ATE_UCI)),
                   lwd = 3.5,
                   col = "#FCB514",
                   alpha = 1,
                   stat = "unique",
                   lineend = "round",
                   position = position_nudge(x = 0)) +
    geom_linerange(aes(ymin = max(dfr$z1_ATE_LCI, dfr$z2_ATE_LCI), ymax = min(dfr$z1_ATE_UCI, dfr$z2_ATE_UCI)),
                   lwd = 3.5,
                   col = "#378855",
                   alpha = 1,
                   stat = "unique",
                   lineend = "round",
                   position = position_nudge(x = 0)) +
    geom_segment(aes(x = 0.6, xend = 1.35, y = 0, yend = 0), lwd = 1.2) +
    ## algorithm estimates
    labs(y = "",
         x = "") +
    geom_segment(data = dfr,
                 aes(x = 2.5, xend = 1.25, y = flag, yend = flag, color = algorithm),
                 arrow = arrow(length = unit(0.5, "cm")),
                 lwd = 1.2,
                 color = "#0F9ED5") +
    geom_point(data = dfr,
               aes(x = 2.5, y = flag, shape = algorithm),
               size = 3,  # Adjust size as needed
               color = "#0F9ED5") +  # Or any desired color
    coord_flip(clip = "off") +
    ## Adjust Scales to Remove Expansion and Compress Vertically
    scale_x_discrete(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0),
                       limits = c(-1.1, 1.1)) +  # Tighten y-axis limits
    ## Theme Adjustments to Minimize White Space
    theme_void(base_size = 10) +
    # theme(
    #   # panel.spacing = unit(0, "pt"),
    #   panel.background = element_rect(fill = "transparent", color = NA),
    #   plot.background = element_rect(fill = "transparent", color = NA),
    #   aspect.ratio = 0.2
    # )
    theme(
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA),
      aspect.ratio = 0.2
    )
}

get_figure_caption <- function(AIRHome, df_vars) {
  caption <- paste0("Risk Difference: This chart represents the difference in outcomes resulting from a change in your experimental variable,",df_vars[1,][[2]],". The x-axis ranges from negative to positive effect, where the treatment, ", df_vars[2,][[2]]," either increases the likelihood of the outcome or decreases it, respectively. The midpoint corresponds to 'no significant effect.")
  return(caption)
}

get_ui_interpretation <- function(AIRHome, df_vars, Zvars) {
  dfr <- read_csv(paste0(AIRHome, "/data/ResultsOut.csv"))
  
  interpretation <- "What we can learn from these results"
  dfr$zmax <- max(dfr$z1_ATE_UCI, dfr$z2_ATE_UCI)
  dfr$zmin <- min(dfr$z1_ATE_LCI, dfr$z2_ATE_LCI)
  
  if ((all(dfr$z1_ATE_UCI < dfr$z2_ATE) & all(dfr$z2_ATE_LCI > dfr$z1_ATE)) |
      (all(dfr$z1_ATE_LCI > dfr$z2_ATE) & all(dfr$z2_ATE_UCI < dfr$z1_ATE))) {
    interpretation <- "Inconsistent Causal ATE suggests not enough information to properly train a model."
  } else if (all(dfr$flag > dfr$zmin & dfr$flag < dfr$zmax)) {
    interpretation <- "Classifier Predictions match Causally-Derived ATE estimates. Your Classifier is healthy!"
  } else if (all(dfr$flag > dfr$zmax) | all(dfr$flag < dfr$zmin)) {
    interpretation <- "Classifier Predictions do not match Causally-Derived ATE estimates. Your Classifier is to be considered unreliable. Consider looking into why this might be."
  } else {
    interpretation <- "Classifier Predictions are mixed with respect to Causally-Derived ATE estimates. Use with caution and consider looking into why."
  }
  
  
  if (any(between(dfr$flag, dfr$z1_ATE_LCI[1], dfr$z1_ATE_UCI[1]))) {
    inZ1 <- TRUE
  } else { inZ1 <- FALSE }
  if (any(between(dfr$flag, dfr$z2_ATE_LCI[1], dfr$z2_ATE_UCI[1]))) {
    inZ2 <- TRUE
  } else { inZ2 <- FALSE }
  
  maxflag <- max(dfr$z1_ATE_LCI, dfr$z1_ATE_UCI, dfr$z2_ATE_LCI, dfr$z2_ATE_UCI)
  minflag <- min(dfr$z1_ATE_LCI, dfr$z1_ATE_UCI, dfr$z2_ATE_LCI, dfr$z2_ATE_UCI)
  flagdir <- case_when(maxflag < 0 ~ "a negative",
                       minflag > 0 ~ "a positive",
                       TRUE ~ "no")
  effect_estimation <- case_when(any(abs(dfr$flag) < min(abs(maxflag), abs(minflag))) ~ "underestimating",
                                 any(abs(dfr$flag) > max(abs(maxflag), abs(minflag))) ~ "overestimating",
                                 TRUE ~ "correctly estimating")
  effect_percent <- case_when(effect_estimation == "underestimating" ~ paste0(" by ", round(abs(maxflag) - abs(mean(dfr$flag)), 2)*100, "-",round(abs(minflag) - abs(mean(dfr$flag)), 2)*100, "%"),
                              effect_estimation == "overestimating" ~ paste0(" by ", round(abs(mean(dfr$flag)) - abs(minflag), 2)*100, "-",round(abs(mean(dfr$flag)) - abs(maxflag), 2)*100, "%"),
                              TRUE ~ "")
  effect_fortune <- case_when(inZ1 & inZ2 ~ "Fortunately",
                              TRUE ~ "Unfortunately")
  
  result_text <- paste0("Your classifier is ",
                        effect_estimation, 
                        " the effect that ", 
                        df_vars[1,][[2]], 
                        " is having on ", 
                        df_vars[2,][[2]], 
                        effect_percent, 
                        ". AIR predicts that ", 
                        df_vars[1,][[2]], 
                        " should be having ", 
                        flagdir, 
                        " effect on ", 
                        df_vars[2,][[2]],
                        ". As ", 
                        df_vars[1,][[2]], 
                        " changes, the outcome of ", 
                        df_vars[2,][[2]], 
                        " is ", 
                        case_when(flagdir == "a negative" ~ paste0("between ", round(min(abs(minflag),abs(maxflag)), 2)*100,"-",round(max(abs(minflag),abs(maxflag)), 2)*100,"% less likely to occur. "),
                                  flagdir == "a positive" ~ paste0("between ", round(min(abs(minflag),abs(maxflag)), 2)*100,"-",round(max(abs(minflag),abs(maxflag)), 2)*100,"% more likely to occur. "),
                                  TRUE ~ "unlikely to change. "),
                        effect_fortune,
                        ", your classifier is producing ",
                        case_when(inZ1 & inZ2 ~ "un",
                                  inZ1 | inZ2 ~ "potentially-",
                                  TRUE ~ ""),
                        "biased results, suggesting ",
                        case_when(effect_estimation == "underestimating" ~ "a decreased ",
                                  effect_estimation == "overestimating" ~ "an increased ",
                                  TRUE ~ "an appropriate "),
                        "change in likelihood of ", 
                        df_vars[2,][[2]],
                        " as ",
                        df_vars[1,][[2]],
                        " changes. ",
                        case_when(inZ1 & inZ2 ~ "No bias is detected at this time.",
                                  inZ1 == TRUE & inZ2 == FALSE ~ paste0("Bias is likely being introduced into the training process at variable(s): ", paste0(Zvars$Z[2], collapse = ", "), " (see graph)."),
                                  inZ2 == TRUE & inZ1 == FALSE ~ paste0("Bias is likely being introduced into the training process at variable(s): ", paste0(Zvars$Z[1], collapse = ", "), " (see graph)."),
                                  TRUE ~ paste0("Bias is likely being introduced into the training process at variable(s): ", paste0(Zvars$Z[1], collapse = ", "), " and/or ", paste0(Zvars$Z[2], collapse = ", ")," (see graph)."))
  )
  return(result_text)
}

get_histogram_x <- function(df, xvar, tv_dir, tv_threshold) {
  data <- df[[xvar]]
  
  # Ensure the selected variable is numeric
  # validate(
  #   need(is.numeric(data), "Selected variable must be numeric.")
  # )
  
  # Define treatment condition based on operator and threshold
  if (tv_dir == ">") {
    treated <- data > tv_threshold
    treated_label <- paste0("Treated (>", tv_threshold, ")")
    untreated_label <- paste0("Untreated (≤ ", tv_threshold, ")")
  } else if (tv_dir == "<") {
    treated <- data < tv_threshold
    treated_label <- paste0("Treated (<", tv_threshold, ")")
    untreated_label <- paste0("Untreated (≥ ", tv_threshold, ")")
  } else if (tv_dir == ">=") {
    treated <- data >= tv_threshold
    treated_label <- paste0("Treated (>=", tv_threshold, ")")
    untreated_label <- paste0("Untreated (> ", tv_threshold, ")")
  } else if (tv_dir == "<=") {
    treated <- data < tv_threshold
    treated_label <- paste0("Treated (<=", tv_threshold, ")")
    untreated_label <- paste0("Untreated (> ", tv_threshold, ")")
  } else if (tv_dir == "=") {
    treated <- data == tv_threshold
    treated_label <- paste0("Treated (= ", tv_threshold, ")")
    untreated_label <- "Untreated (≠)"
  }
  
  # Create a dataframe for plotting
  plot_df <- data.frame(
    x = data,
    Treatment = ifelse(treated, "Treated", "Untreated")
  )
  
  # Define colors
  colors <- c("Treated" = "#5D9AFF", "Untreated" = "#EAE1D7")
  
  # Generate the histogram
  ggplot(plot_df, aes(x = x, fill = Treatment, color = Treatment)) +
    geom_rug(sides = "b") +
    geom_histogram(binwidth = (max(data) - min(data)) / 30, color = "black") +#, alpha = 0.7) +
    scale_fill_manual(values = colors, labels = c(untreated_label, treated_label)) +
    scale_color_manual(values = colors, labels = c(untreated_label, treated_label)) +
    geom_vline(xintercept = tv_threshold, color = "gray20", linetype = "dashed", linewidth = 1) +
    labs(
      title = paste("Distribution of ", xvar),
      x = NULL,
      # y = "Count",
      fill = "Treatment Status"
    ) +
    guides(color = "none") +  
    theme_minimal() + 
    theme(text = element_text(color = "#666666", face = "bold"),
          panel.background = element_rect(fill = "transparent", color = NA),
          plot.background  = element_rect(fill = "transparent", color = NA)) 
}

get_histogram_y <- function(df, yvar, ov_dir, ov_threshold) {
  data <- df[[yvar]]
  
  # Ensure the selected variable is numeric
  # validate(
  #   need(is.numeric(data), "Selected variable must be numeric.")
  # )
  
  # Define treatment condition based on operator and threshold
  if (ov_dir == ">") {
    success <- data > ov_threshold
    success_label <- paste0("Success (>", ov_threshold, ")")
    fail_label <- paste0("Fail (≤ ", ov_threshold, ")")
  } else if (ov_dir == "<") {
    success <- data < ov_threshold
    success_label <- paste0("Success (<", ov_threshold, ")")
    fail_label <- paste0("Fail (≥ ", ov_threshold, ")")
  } else if (ov_dir == ">=") {
    success <- data >= ov_threshold
    success_label <- paste0("Success (>=", ov_threshold, ")")
    fail_label <- paste0("Fail (> ", ov_threshold, ")")
  } else if (ov_dir == "<=") {
    success <- data < ov_threshold
    success_label <- paste0("Success (<=", ov_threshold, ")")
    fail_label <- paste0("Fail (> ", ov_threshold, ")")
  } else if (ov_dir == "=") {
    success <- data == ov_threshold
    success_label <- paste0("Success (= ", ov_threshold, ")")
    fail_label <- "Fail (≠)"
  }
  
  # Create a dataframe for plotting
  plot_df <- data.frame(
    x = data,
    success = ifelse(success, "Success", "Fail")
  )
  
  # Define colors
  colors <- c("Success" = "#5D9AFF", "Fail" = "#EAE1D7")
  # Generate the histogram
  
  ggplot(plot_df, aes(x = x, fill = success, color = success)) +
    geom_rug(sides = "b") +
    geom_histogram(binwidth = (max(data) - min(data)) / 30, color = "black") +#, alpha = 0.7) +
    scale_fill_manual(values = colors, labels = c(fail_label, success_label)) +
    scale_color_manual(values = colors, labels = c(fail_label, success_label)) +
    geom_vline(xintercept = ov_threshold, color = "gray20", linetype = "dashed", linewidth = 1) +
    labs(
      title = paste("Distribution of ", yvar),
      x = NULL,
      # y = "Count",
      fill = "Treatment Status"
    ) +
    guides(color = "none") +  
    theme_minimal() + 
    theme(text = element_text(color = "#666666", face = "bold"),
          panel.background = element_rect(fill = "transparent", color = NA),
          plot.background  = element_rect(fill = "transparent", color = NA)) 
}

get_updated_graph <- function(AIRHome, graph_update, xvar, yvar, Zvars) { 
  dot <- readLines(paste0(AIRHome, "/dotfile.txt"))  
  if (graph_update) {
    dot <- change_node_color(dot, xvar, "'#FFC107'")
    dot <- change_node_color(dot, yvar, "'#FFC107'")
    dot <- change_node_color(dot, Zvars[Zvars$grp == "Z1",]$Z, "'#9394A2'")
    dot <- change_node_color(dot, Zvars[Zvars$grp == "Z2",]$Z, "'#D4C7C7'")
  }
  return(dot)
}

get_final_graph <- function(AIRHome, xvar, yvar, Zvars) {
  dot <- readLines(paste0(AIRHome, "/dotfile.txt"))
  dot <- change_node_color(dot, xvar, "'#FFC107'")
  dot <- change_node_color(dot, yvar, "'#FFC107'")
  # dot <- change_node_color(dot, xvar, "yellow")
  # dot <- change_node_color(dot, yvar, "yellow")
  
  dfr <- read_csv(paste0(AIRHome, "/data/ResultsOut.csv"))
  Z1 <- Zvars[Zvars$grp == "Z1",]$Z
  Z2 <- Zvars[Zvars$grp == "Z2",]$Z
  
  # code for generating ribbon plot
  if (any(dfr$flag > dfr$z1_ATE_UCI & dfr$flag < dfr$z2_ATE_UCI)) {
    dot <- change_node_color(dot, Z2, "'#FFC107'")
  } else if (any(dfr$flag > dfr$z1_ATE_LCI & dfr$flag < dfr$z2_ATE_LCI)) {
    dot <- change_node_color(dot, Z1, "'#FFC107'")
  } else if (any(dfr$flag > dfr$z1_ATE_UCI & dfr$flag > dfr$z2_ATE_UCI)) {
    dot <- change_node_color(dot, Z1, "'#C00000'")
    dot <- change_node_color(dot, Z2, "'#C00000'")
  } else if (any(dfr$flag < dfr$z1_ATE_UCI & dfr$flag < dfr$z2_ATE_UCI)) {
    dot <- change_node_color(dot, Z1, "'#C00000'")
    dot <- change_node_color(dot, Z2, "'#C00000'")
  } 
  
  return(dot)
}

save_ggplot_to_png <- function(plot_obj, filename, width = 8, height = 6, dpi = 300) {
  # Use ggsave to write the ggplot object to a file
  ggsave(filename = filename, plot = plot_obj, width = width, height = height, dpi = dpi)
}

save_graphviz_to_png <- function(dot_code, filename) {
  # Write the DOT code to a temporary file
  dot_file <- tempfile(fileext = ".dot")
  # writeLines(dot_code, dot_file)
  dot <- paste(dot_code, collapse = "\n")
  cat(dot, file = dot_file)
  
  # Call Graphviz's dot command to convert DOT to PNG
  # Ensure that 'dot' is installed and available in your system PATH.
  cmd <- sprintf('dot -Tpng -o "%s" "%s"', filename, dot_file)
  system(cmd)
}
