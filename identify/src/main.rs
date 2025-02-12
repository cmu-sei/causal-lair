use petgraph::Graph;
use petgraph::Direction;
use petgraph::graph::{DiGraph, NodeIndex};
// use petgraph::dot::{Dot, Config};
use petgraph::visit::{Dfs, Walker};
// use petgraph::algo::toposort;
use std::collections::HashMap;
use std::fs;
use std::str::Lines;
use std::collections::BTreeSet;
use clap::Parser;

#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Cli {
    // First input parameter
    #[arg(long)]
    param1: String,

    // Second input parameter
    #[arg(long)]
    param2: String,
}

#[derive(Debug, Serialize, Deserialize)]struct OutputData {
    vector1: Vec<String>,
    vector2: Vec<String>,
}

fn main() {
    let tv = Cli::parse().param1.clone();
    let ov = Cli::parse().param2.clone();
    //let tv = "scenario_main_base".to_string();
    //let ov = "images_acquired".to_string();

    let graph = read_graph_from_file();
    
    /*
    // print nodes and edges to verify
    for node in graph.node_indices() {
        println!("Node {}: {}", node.index(), graph[node]);
    }

    for edge in graph.edge_indices() {
        let (source, target) = graph.edge_endpoints(edge).unwrap();
        println!("Edge from {} to {}", source.index(), target.index());
    }
    */
    
    // Find the NodeIndex for a given name
    let index = find_node_index_by_name(&graph, &tv);
    let ov_index = find_node_index_by_name(&graph, &ov);
    //println!("NodeIndex for {tv}: {:?}", index);
    //println!("NodeIndex for {ov}: {:?}", ov_index);

    // Example: Get children of 'TV'
    let _children = get_children_by_name(&graph, index);
    //println!("Children of {tv}: {:?}", children);

    // get parents of 'b'
    // let parents = get_parents(&graph, b);
    let parents = get_parents_by_name(&graph, index);
    //println!("Parents of {tv}: {:?}", parents);
    
    // get descendants of 'b'
    // let descendants = get_descendants(&graph, b);
    let descendants = get_descendants_by_name(&graph, index);
    //println!("Descendants of {tv}: {:?}", descendants);

    // get ancestors of 'b'
    // let ancestors = get_ancestors(&graph, b);
    //let ancestors = get_ancestors_by_name(&graph, index);
    //println!("Ancestors of b: {:?}", ancestors);
    let mut visited = BTreeSet::new();
    let ancestors = find_ancestors(&graph, index, &mut visited);

    // Convert NodeIndex to node names and print ancestors
    let _ancestor_names: Vec<_> = ancestors.iter().map(|&idx| &graph[idx]).collect();
    //println!("Ancestors of {tv}: {:?}", ancestor_names);

    // let's pull it all together and get an intersection
    let mut ov_visited = BTreeSet::new();
    let ov_ancestors = find_ancestors(&graph, ov_index, &mut ov_visited);
    let ov_ancestor_names: BTreeSet<String> = ov_ancestors.iter().map(|&idx| &graph[idx]).cloned().collect();
    let nodes_on_dir_path: Vec<_> = ov_ancestor_names.intersection(&descendants).collect();
    //println!("Z1: {:?}", parents);
    //println!("M: {:?}", nodes_on_dir_path);
    let mut confounder: BTreeSet<String> = BTreeSet::new();
    for node in nodes_on_dir_path {
        let idx = get_node_index_by_name(&graph, node.clone());
        match idx {
            Some(result) => {
                let parents_of_m = get_parents_by_name(&graph, result);
                let tmp_confounder = parents_of_m.difference(&descendants);
                let mut new_items: Vec<String> = Vec::new();
                for item in tmp_confounder{
                    new_items.push(item.clone());
                }
                confounder = new_items.into_iter().collect();
            }, 
            None => {
                //println!("Null case in index.");
                continue;
            }
        }

        // this is the confounders of intermediate variables, defined as the
        // what's left when you remove the parents of your intermediate
        // variables (nodes on the path from the treatment variable to the
        // outcome variable) from the descendants of the treatment variable.
    }
    //println!("Z2: {:?}", confounder);

    // pulling together return vectors
    let vector1 = parents.into_iter().collect();
    let vector2 = confounder.into_iter().collect();
    // prepping data to return
    let data = OutputData { 
        vector1,
        vector2,
    };

    // print as JSON to stdout so that R can parse
    println!("{}", serde_json::to_string(&data).unwrap());
    /*
    // compute intersection between sets
    // let intersection = intersection(&ancestors, &descendants);
    let intersection = intersection(&get_ancestors(&graph, &index), &get_descendants(&graph, &index));
    let intersection_names: Vec<_> = intersection
        .iter()
        .map(|&node| graph[node]) // convert to node names
        .collect();
    println!("Intersection of ancestors and descendants of b: {:?}", intersection_names);
*/
}

fn get_node_index_by_name(
    graph: &Graph<String, ()>,
    name: String
) -> Option<NodeIndex> {
    graph.node_indices().find(|&i| graph[i] == name)
}

fn read_graph_from_file() -> Graph<String, ()> {
    // Read the entire file content
    let file_content = fs::read_to_string("graphtxt.txt").expect("Cannot read stupid file");
        
    // Split the sections by "Graph Nodes:" and "Graph Edges:"
    // Note: This is a simplistic approach that assumes the file is structured
    // exactly as provided: first "Graph Nodes:" line, then the list of nodes,
    // then "Graph Edges:" line, then the list of edges.
    
    // 1. Identify the lines for Graph Nodes
    let lines = file_content.lines();

    let graph_input = parse_dotlike(lines);
    let parsed_graph = create_digraph(graph_input);
    return parsed_graph
}

fn find_node_index_by_name(graph: &DiGraph<String, ()>, name: &str) -> NodeIndex {
    graph.node_indices().find(|&idx| graph[idx] == name).unwrap()
}

fn parse_dotlike (lines: Lines) -> (Vec<String>,Vec<(String, String)>) {

    let mut node_names: Vec<String> = Vec::new();
    let mut edges: Vec<(String, String)> = Vec::new();
    
    // A small state machine: we look for "Graph Nodes:", then read until we hit
    // "Graph Edges:", at which point we parse edges.
    let mut in_node_section = false;
    let mut in_edge_section = false;
    
    for line in lines {
        // Trim line
        let line = line.trim();
        // Skip empty lines
        if line.is_empty() {
            continue;
        }
        
        // Check for headings
        if line.starts_with("Graph Nodes:") {
            // We have found the node section
            in_node_section = true;
            in_edge_section = false;
            continue;
        } else if line.starts_with("Graph Edges:") {
            // We have found the edge section
            in_node_section = false;
            in_edge_section = true;
            continue;
        }
        
        // If we're in the node section, parse node names
        if in_node_section {
            // The node names might all be on one line separated by semicolons
            // e.g. "image_A_captured;image_B_captured;A_dist;..."
            // We can split by semicolon:
            let node_split: Vec<&str> = line.split(';').collect();
            for ns in node_split {
                let trimmed = ns.trim();
                if !trimmed.is_empty() {
                    node_names.push(trimmed.to_string());
                }
            }
        }
        
        // If we're in the edge section, parse edges of the form:
        // "1. A_B_dist --> altitude"
        // We'll ignore the numeric prefix and just parse the "X --> Y"
        if in_edge_section {
            // Example line: "3. A_B_dist --> hard_landing"
            // 1) Strip off the leading "number + dot"
            // 2) Split on "-->"
            
            // Split off the leading index plus dot if it exists:
            let mut edge_line = line.to_string();
            if let Some(dot_index) = edge_line.find('.') {
                // remove everything up to and including that dot
                // e.g. "3. " -> remove that
                edge_line = edge_line[(dot_index+1)..].trim().to_string();
            }
            
            // Now we expect "X --> Y"
            let parts: Vec<&str> = edge_line.split("-->").collect();
            if parts.len() == 2 {
                let source = parts[0].trim().to_string();
                let target = parts[1].trim().to_string();
                edges.push((source, target));
            } else {
                eprintln!("Warning: could not parse edge line: {}", line);
            }
        }
    }
    return (node_names.clone(), edges.clone());
    //let mut node_names: Vec<String> = Vec::new();
    //let mut edges: Vec<(String, String)> = Vec::new();
}

fn create_digraph (graph_input:(Vec<String>,Vec<(String, String)>)) -> Graph<String, ()> {
    // Now we have node_names and edges
    // Create a directed graph using petgraph
    let mut graph: DiGraph<String, ()> = DiGraph::new();
    
    // Create a map from node name to NodeIndex
    let mut node_map: HashMap<String, NodeIndex> = HashMap::new();
    
    // Add each node to the graph
    let (node_names, edges) = graph_input;
    for name in &node_names {
        let idx = graph.add_node(name.clone());
        node_map.insert(name.clone(), idx);
    }
    
    // Add the edges
    for (src, dst) in edges {
        // Look up the NodeIndex
        if let (Some(&src_idx), Some(&dst_idx)) = (node_map.get(&src), node_map.get(&dst)) {
            graph.add_edge(src_idx, dst_idx, ());
        } else {
            eprintln!("Warning: Edge references unknown node(s): {} --> {}", src, dst);
        }
    }
    
    // Now graph is a DiGraph containing all nodes and edges.
    // You can verify or use the graph as needed. For instance:
    //println!("Number of nodes: {}", graph.node_count());
    //println!("Number of edges: {}", graph.edge_count());
    
    // You can iterate or do any petgraph operations here...
    return graph.clone(); 
}

// Function to get children of a node
fn _get_children(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<NodeIndex> {
    graph
        .neighbors_directed(node, Direction::Outgoing)
        .collect()
}

fn get_parents_by_name(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<String> {
    graph
        .neighbors_directed(node, petgraph::Direction::Incoming)
        .map(|node| graph[node].clone()) // Convert NodeIndex to names
        .collect()
}

fn get_children_by_name(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<String> {
    graph
        .neighbors_directed(node, petgraph::Direction::Outgoing)
        .map(|child| graph[child].clone()) // Convert NodeIndex to names
        .collect()
}

fn _get_ancestors_by_name_old(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<String> {
    // Use an incoming direction to find ancestors
    Dfs::new(graph, node)
        .iter(graph)
        .filter(|&n| n != node && graph.find_edge(n, node).is_some()) // Ensure it's an incoming edge
        .map(|nodes| graph[nodes].clone()) // Convert NodeIndex to names
        .collect()
}

fn _get_ancestors_by_name(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<String> {
    // base case is parent has no parent. this is oldest possible anctor. 
    //     when you reach this, add parent to set of all_parents
    // until you hit base case, it's going to be get_parents(node).
    let mut visited = BTreeSet::new();
    let ancestors = find_ancestors(&graph, node, &mut visited);

    // Convert NodeIndex to node names and print ancestors
    let ancestors_iterator = ancestors.iter();
    let ancestors_map = ancestors_iterator.map(|idx| graph[*idx].clone());
    ancestors_map.collect()
    
}

fn find_ancestors(
    graph: &DiGraph<String, ()>,
    node: NodeIndex,
    visited: &mut BTreeSet<NodeIndex>,
) -> BTreeSet<NodeIndex> {
    // If the node has already been visited, return an empty set
    if visited.contains(&node) {
        return BTreeSet::new();
    }

    // Mark this node as visited
    visited.insert(node);

    // Initialize an empty set to store ancestors
    let mut ancestors = BTreeSet::new();

    // Get immediate parents of the current node
    let parents: BTreeSet<NodeIndex> = graph
        .neighbors_directed(node, Direction::Incoming)
        .collect();

    // For each parent, recursively find their ancestors
    for parent in parents {
        ancestors.insert(parent);
        ancestors.extend(find_ancestors(graph, parent, visited));
    }

    ancestors
} 


fn get_descendants_by_name(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<String> {
    Dfs::new(graph, node)
        .iter(graph)
        .filter(|&n| n != node) // Exclude the starting node itself
        .map(|nodes| graph[nodes].clone()) // Convert NodeIndex to names
        .collect()
}

// function to get parents of a node
fn _get_parents(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<NodeIndex> {
    graph
        .neighbors_directed(node, Direction::Incoming)
        .collect()
}

// function to get descendants of a node
fn _get_descendants(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<NodeIndex> {
    Dfs::new(graph, node)
        .iter(graph)
        .filter(|&n| n != node) // Exclude the starting node itself
        .collect()
}

// function to get ancestors of a node
fn _get_ancestors(graph: &DiGraph<String, ()>, node: NodeIndex) -> BTreeSet<NodeIndex> {
    Dfs::new(graph, node)
        .iter(graph)
        .filter(|&n| n != node) // Exclude the starting node itself
        .collect()
}

fn _intersection(
    set1: &BTreeSet<NodeIndex>,
    set2: &BTreeSet<NodeIndex>,
) -> BTreeSet<NodeIndex> {
    set1.intersection(set2).cloned().collect()
}
