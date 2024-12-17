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

## identify.R

# Purpose: Given Treatment (TV) and Outcome (OV) variables; and graph text file (saved from Tetrad) that
#   encodes a DAG, compute the de-confounding sets Z1 and Z2 (based on those described in MDLAR Final Report).
#   Caution: depending on the quality of the graph (and Markovianity), Z1 and Z2 might not actually be
#   de-confounding sets. For example, there might be some unmeasured parents of the treatment variable (TV) or
#   of other key variables.
#   (This is why we need to have a good dataset to begin with and good-quality CD algorithm. We might not nail
#   all conditions completely and tightly, but we may come close enough.)
#
# Prerequisite: Not checked, but we assume the DAG largely satisfies the Markov Condition (MC) and Faithfulness (FC)
#   relative to a reference dataset.
#   In particular, this means that there is no reason to believe there is a *significant* unmeasured confounder of TV and OV.
#
# TODO: Expansions for this program include:
# (a) Multiple outcome variables (OV) [easy?]
# (b) Multiple treatment variables (TV) [harder]
# (c) Not just DAGs where all edges are directed but CPDAGs? [difficulty unknown]
#
# Assumptions:
#   1. The hash and sets libraries are installed. (The info about sets is found here: https://quantifyinghealth.com/sets-in-r/)
#   2. The graph spec text file has each edge specified in a numbered line in the format: "line_num. node1 --> node2"

library("hash")
library("sets")

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
descendants <- function(node) {
    checked_so_far <- set()
    seen_not_checked <- set(node)
    while ( ! set_is_empty(seen_not_checked)) {
        check_these <- seen_not_checked
        for (n in check_these) {
            for (m in children[[n]]) {
                if ( ! (m %e% checked_so_far)) {
                    seen_not_checked <- seen_not_checked | set(m)
                }
            }
            seen_not_checked <- seen_not_checked - set(n)
            checked_so_far <- checked_so_far | set(n)
        }
    }
    return(checked_so_far)
}

ancestors <- function(node) {
    checked_so_far <- set()
    seen_not_checked <- set(node)
    while ( ! set_is_empty(seen_not_checked)) {
        check_these <- seen_not_checked
        for (n in check_these) {
            for (m in parents[[n]]) {
                if ( ! (m %e% checked_so_far)) {
                    seen_not_checked <- seen_not_checked | set(m)
                }
            }
            seen_not_checked <- seen_not_checked - set(n)
            checked_so_far <- checked_so_far | set(n)
        }
    }
    return(checked_so_far)
}

## Main

## Several domain-specific initializations:

## Set verbose printing on (TRUE) or off (not TRUE)
PRINT_STATE <- !TRUE

## Set USE_INIITIAL_ALGM to TRUE for 2022 version or not TRUE for 2024 version
USE_INITIAL_ALGM <- TRUE

## Specify which variables are the TV and OV; and which file has the graph spec
# First block of lines support UAV demo application.
# Second block of lines support Engine health demo application.

# First block:
# TV <- 'scenario_main_base'
# OV <- 'images_acquired'  # TODO: test to see if different from TV
# GRAPH_FILE <- 'graph6.txt'  # TODO: test to see if it includes TV and OV

# Second block:
TV <- df_vars$val[1]
OV <- df_vars$val[2]  # TODO: test to see if different from TV
GRAPH_FILE <- 'graphtxt.txt'  # TODO: test to see if it includes TV and OV

## Read in graph
PATH <- getwd()
lines <- readLines(paste(PATH, "/", GRAPH_FILE, sep=""))

## Create a set of the nodes in the graph
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
if (PRINT_STATE) {
    print(nodes)
}

## Create children and parents dictionaries
children <- hash()
parents <- hash()
for (n in nodes) {
    children_of_n <- set()
    parents_of_n <- set()
    for (line in lines) {
        if (is_edge_line(line)) {
            if ((first_node(line)  == n) && (!(second_node(line) %e% children_of_n))) {
                children_of_n <- children_of_n | set(second_node(line))
            }
            if ((second_node(line) == n) && (!(first_node(line)  %e% parents_of_n))) {
                parents_of_n <- parents_of_n | set(first_node(line))
            }
        }
    }
    children[[n]] <- children_of_n
    parents[[n]]  <- parents_of_n
}
if (PRINT_STATE) {
    print(children)
    print(parents)
}

## Print all ancestors and descendants
for (n in nodes) {
    if (PRINT_STATE) {
        print(paste(n, " has these descendants: "))
        print(descendants(n))
        print(paste(n, " has these ancestors: "))
        print(ancestors(n))
    }
}

## Construct "deconfounding" sets Z1 and Z2 that include selected parents of
#    the nodes in descendants({TV}).

# Z1 is just the parents of TV. Not all will be measured, but take what's available
Z1 <- parents[[TV]]
# TODO: Can we do this: if there are no paths between such a parent and OV not through TV, then don't add it to Z1.

# Per the 2022 (2024) algorithm, Z2 is just the parents of:
#   (a) nodes on any directed path from TV to OV; inclusive of OV, but exclusive of TV (2022)
#   (b) proper descendants of TV (2024)
#   that are not themselves descendants of TV (both 2022 and 2024).
Z2 <- set()
desc_TV <- descendants(TV)
prop_desc_TV <- desc_TV - set(TV)
prop_anc_TV <- ancestors(TV) - set(TV)
if (PRINT_STATE) {print(prop_anc_TV)}

if (USE_INITIAL_ALGM) {
  nodes_on_dir_path <- intersect(prop_desc_TV, ancestors(OV))
  for (node in nodes_on_dir_path) {
    parent_of_node_on_dir_path_not_a_desc <- (parents[[node]] - desc_TV)
    if (PRINT_STATE) {
      print(paste("----node is: ", node))
      print(parents[[node]])
      print(parent_of_node_on_dir_path_not_a_desc)
    }
    for (parent in parent_of_node_on_dir_path_not_a_desc) {
      # if there's a trek between TV and parent, then add to Z2
      if (PRINT_STATE) {print(paste("----parent considered: ", parent))}
      if (!length(intersect(prop_anc_TV, ancestors(parent)))==0) {
        if (PRINT_STATE) {print(unlist(intersect(prop_anc_TV, ancestors(parent))))}
        Z2 <- Z2 | set(parent)
      }
    }
  }
} else {
  for (node in prop_desc_TV) {
    parent_of_prop_desc_not_a_desc <- parents[[node]] - desc_TV
    Z2 <- Z2 | parent_of_prop_desc_not_a_desc
    if (PRINT_STATE) {print(paste(node, parent_of_prop_desc_not_a_desc))}
    }
  }

## print out these sets as ordered lists
unlist_Z1 <- unlist(Z1)
unlist_Z2 <- unlist(Z2)
print(unlist_Z1[order(unlist_Z1)])
print(unlist_Z2[order(unlist_Z2)])
