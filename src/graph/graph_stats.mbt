///|
/// GraphSummary provides analytical metrics for a DependencyGraph.
pub(all) struct GraphSummary {
  node_count : Int
  edge_count : Int
  max_depth : Int
  duplicate_packages : Map[String, Array[String]]
  isolated_nodes : Array[String]
  leaf_nodes : Array[String]
} derive(Eq, Debug)

///|
/// Computes complete analytical summary of DependencyGraph.
pub fn compute_graph_summary(graph : DependencyGraph) -> GraphSummary {
  let mut edge_cnt = 0
  let leaf_nodes : Array[String] = []
  let isolated_nodes : Array[String] = []
  let pkg_versions : Map[String, Array[String]] = Map::from_array([])

  for id, comp in graph.nodes {
    let deps = graph.get_direct_dependencies(id)
    let rev_deps = graph.get_direct_dependents(id)
    edge_cnt = edge_cnt + deps.length()

    if deps.length() == 0 {
      leaf_nodes.push(id)
    }
    if deps.length() == 0 && rev_deps.length() == 0 {
      isolated_nodes.push(id)
    }

    let pkg_name = comp.name
    match pkg_versions.get(pkg_name) {
      Some(ver_list) => {
        let mut ver_exists = false
        for v in ver_list {
          if v == comp.version {
            ver_exists = true
            break
          }
        }
        if !ver_exists {
          ver_list.push(comp.version)
        }
      }
      None => pkg_versions.set(pkg_name, [comp.version])
    }
  }

  let duplicates : Map[String, Array[String]] = Map::from_array([])
  for pkg_name, ver_list in pkg_versions {
    if ver_list.length() > 1 {
      duplicates.set(pkg_name, ver_list)
    }
  }

  let mut max_d = 0
  for id, _ in graph.nodes {
    let trans = get_all_transitive_dependencies(graph, id)
    if trans.length() > max_d {
      max_d = trans.length()
    }
  }

  {
    node_count: graph.node_count(),
    edge_count: edge_cnt,
    max_depth: max_d,
    duplicate_packages: duplicates,
    isolated_nodes,
    leaf_nodes,
  }
}
