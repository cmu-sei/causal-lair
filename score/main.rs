// AIR Tool
// 
// Copyright 2024 Carnegie Mellon University.
// 
// NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
// MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
// WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
// INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
// MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
// CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
// TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
// 
// Licensed under a MIT (SEI)-style license, please see license.txt or contact
// permission_at_sei.cmu.edu for full terms.
// 
// [DISTRIBUTION STATEMENT A] This material has been approved for public release
// and unlimited distribution.  Please see Copyright notice for non-US Government
// use and distribution.
// 
// This Software includes and/or makes use of Third-Party Software each subject to
// its own license.
// 
// DM24-1686

use boss_scoring::{ScoringMethod, DiscreteBicScore, ContinuousBicScore};
use ndarray::array;

fn main() {
    // 1. Example usage with discrete data
    let discrete_data = vec![
        // row-major: each row is a sample, each column is a variable
        vec![0, 1, 0],
        vec![0, 0, 0],
        vec![1, 1, 0],
        vec![1, 0, 1],
    ];
    let num_categories = vec![2, 2, 2]; // assume each var is binary
    
    let discrete_score = DiscreteBicScore::new(
        discrete_data,
        num_categories,
        1.0,    // penalty_discount
        0.0     // structure_prior
    );

    // Example DAG (3 variables). Suppose:
    // Node 0 has parents []
    // Node 1 has parents [0]
    // Node 2 has parents [0, 1]
    let dag_parents = vec![
        vec![],    // for node 0
        vec![0],   // for node 1
        vec![0,1]  // for node 2
    ];

    let mut total_score = 0.0;
    for (node, parents) in dag_parents.iter().enumerate() {
        let s = discrete_score.local_score(node, parents);
        total_score += s;
        println!("Discrete local score for node {} is {}", node, s);
    }
    println!("Total discrete DAG score = {}", total_score);


    // 2. Example usage with continuous data
    // We'll build a 4 x 3 array: 4 samples, 3 variables
    let continuous_data = array![
        [2.3, 1.1, 0.0],
        [2.1, 0.9, 0.1],
        [3.0, 1.2, 0.0],
        [4.2, 2.2, 0.1],
    ];
    let cont_score = ContinuousBicScore::new(
        continuous_data,
        1.0,  // penalty_discount
        0.0   // structure_prior
    );

    // Let's define a new DAG: node 0 <- no parents, node 1 <- [0], node 2 <- [0,1]
    let cont_dag_parents = vec![
        vec![],
        vec![0],
        vec![0,1],
    ];

    let mut cont_total = 0.0;
    for (node, parents) in cont_dag_parents.iter().enumerate() {
        let s = cont_score.local_score(node, parents);
        cont_total += s;
        println!("Continuous local score for node {} is {}", node, s);
    }
    println!("Total continuous DAG score = {}", cont_total);
}
