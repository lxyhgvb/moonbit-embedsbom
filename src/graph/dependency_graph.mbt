///|
/// DependencyGraph manages nodes and directed dependency edges between software components.
pub(all) struct DependencyGraph {
  nodes : Map[String, @types.Component]
  adj_list : Map[String, Array[String]]
  rev_adj_list : Map[String, Array[String]]
} derive(Eq, Debug)

///|
/// Creates an empty DependencyGraph.
pub fn DependencyGraph::new() -> DependencyGraph {
  {
    nodes: Map::from_array([]),
    adj_list: Map::from_array([]),
    rev_adj_list: Map::from_array([]),
  }
}

///|
/// Adds a component node to the graph.
pub fn DependencyGraph::add_node(
  self : DependencyGraph,
  comp : @types.Component,
) -> Unit {
  self.nodes.set(comp.id, comp)
  if !self.adj_list.contains(comp.id) {
    self.adj_list.set(comp.id, [])
  }
  if !self.rev_adj_list.contains(comp.id) {
    self.rev_adj_list.set(comp.id, [])
  }
}

///|
/// Adds a directed edge from parent_id to child_id.
pub fn DependencyGraph::add_edge(
  self : DependencyGraph,
  parent_id : String,
  child_id : String,
) -> Unit {
  match self.adj_list.get(parent_id) {
    Some(list) => {
      let mut exists = false
      for item in list {
        if item == child_id {
          exists = true
          break
        }
      }
      if !exists {
        list.push(child_id)
      }
    }
    None => self.adj_list.set(parent_id, [child_id])
  }

  match self.rev_adj_list.get(child_id) {
    Some(list) => {
      let mut exists = false
      for item in list {
        if item == parent_id {
          exists = true
          break
        }
      }
      if !exists {
        list.push(parent_id)
      }
    }
    None => self.rev_adj_list.set(child_id, [parent_id])
  }
}

///|
/// Builds DependencyGraph from SbomDocument.
pub fn DependencyGraph::from_document(
  doc : @types.SbomDocument,
) -> DependencyGraph {
  let graph = DependencyGraph::new()
  for comp in doc.components {
    graph.add_node(comp)
    for dep_id in comp.dependencies {
      graph.add_edge(comp.id, dep_id)
    }
  }

  for rel in doc.relationships {
    graph.add_edge(rel.parent_id, rel.child_id)
  }

  graph
}

///|
/// Retrieves component node by ID.
pub fn DependencyGraph::get_node(
  self : DependencyGraph,
  id : String,
) -> @types.Component? {
  self.nodes.get(id)
}

///|
/// Returns direct dependency children IDs of a given parent node.
pub fn DependencyGraph::get_direct_dependencies(
  self : DependencyGraph,
  id : String,
) -> Array[String] {
  match self.adj_list.get(id) {
    Some(list) => list
    None => []
  }
}

///|
/// Returns direct parent IDs depending on a given child node.
pub fn DependencyGraph::get_direct_dependents(
  self : DependencyGraph,
  id : String,
) -> Array[String] {
  match self.rev_adj_list.get(id) {
    Some(list) => list
    None => []
  }
}

///|
/// Returns total number of component nodes.
pub fn DependencyGraph::node_count(self : DependencyGraph) -> Int {
  self.nodes.length()
}
