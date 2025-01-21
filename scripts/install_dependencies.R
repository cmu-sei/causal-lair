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

# scripts/install_dependencies.R

# Define required CRAN packages
cran_packages <- c(
    "assertthat", "caret", "delayed", "devtools", "DiagrammeR", "dplyr", "ggplot2", "gifski", "hash",
    "here", "igraph", "jsonlite", "knitr", "magick", "origami", "readr", "rJava", "rmarkdown",
    "rsconnect", "sets", "shiny", "shinyWidgets", "tidyr"
)

more_cran_packages <- c(
    "AIPW", "e1071", "earth", "nnet", "randomForest", "ranger", "xgboost"
)

# Function to install CRAN packages
install_cran_packages <- function(packages) {
  missing_pkgs <- packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(missing_pkgs)) {
    message("Installing CRAN packages: ", paste(missing_pkgs, collapse = ", "))
    install.packages(missing_pkgs, dependencies = TRUE, repos = 'https://cloud.r-project.org/')
  } else {
    message("All CRAN packages are already installed.")
  }
}

# Define required GitHub packages
github_packages <- list(
  "sl3" = "tlverse/sl3@devel",
  "tmle3" = "tlverse/tmle3@devel",
  "hal9001" = "tlverse/hal9001"
)

# Function to install GitHub packages
install_github_packages <- function(packages) {
  for (pkg in names(packages)) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message(paste("Installing GitHub package:", packages[[pkg]]))
      tryCatch(
        {
          devtools::install_github(packages[[pkg]], dependencies = FALSE)
          message(paste("Successfully installed:", pkg))
        },
        error = function(e) {
          message(paste("Failed to install:", pkg))
          message(e)
        }
      )
    } else {
      message(paste("GitHub package already installed:", pkg))
    }
  }
}

# Install CRAN packages
install_cran_packages(cran_packages)
install_cran_packages(more_cran_packages)

# Install 'imputeMissings' from URL
imputeMissings_url <- "https://cran.r-project.org/src/contrib/Archive/imputeMissings/imputeMissings_0.0.3.tar.gz"

if (!requireNamespace("imputeMissings", quietly = TRUE)) {
  message("Installing 'imputeMissings' from URL: ", imputeMissings_url)
  tryCatch(
    {
      install.packages(imputeMissings_url, repos = NULL, type = "source")
      message("'imputeMissings' installed successfully.")
    },
    error = function(e) {
      message("Failed to install 'imputeMissings'.")
      message(e)
    }
  )
} else {
  message("'imputeMissings' is already installed.")
}

# Install GitHub packages
install_github_packages(github_packages)

# Verify RJava installation
message("Verifying RJava installation...")
if (!requireNamespace("rJava", quietly = TRUE)) {
  stop("rJava failed to install.")
} else {
  library(rJava)
  .jinit()
  java_version <- .jcall("java/lang/System", "S", "getProperty", "java.version")
  if (java_version == "") {
    stop("rJava failed to initialize correctly.")
  } else {
    message(paste("rJava initialized successfully with Java version:", java_version))
  }
}
