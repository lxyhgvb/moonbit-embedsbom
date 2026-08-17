///|
/// Renders DependencyGraph as visual ASCII tree hierarchy string.
pub fn export_ascii_graph(
  graph : @graph.DependencyGraph,
  root_id? : String = "",
) -> String {
  let buf = StringBuilder::new()
  let visited : Map[String, Bool] = Map::from_array([])

  fn render_node(id : String, prefix : String, is_last : Bool) -> Unit {
    let branch = if is_last { "└── " } else { "├── " }
    let child_prefix = prefix + (if is_last { "    " } else { "│   " })

    let comp_label = match graph.get_node(id) {
      Some(comp) => comp.to_display_string()
      None => id
    }

    buf.write_string(prefix + branch + comp_label + "\n")

    if visited.contains(id) {
      buf.write_string(child_prefix + "└── (recursive cycle)\n")
      return
    }
    visited.set(id, true)

    let deps = graph.get_direct_dependencies(id)
    let len = deps.length()
    for i, child_id in deps {
      let last_child = i == len - 1
      render_node(child_id, child_prefix, last_child)
    }
  }

  if root_id != "" {
    render_node(root_id, "", true)
  } else {
    let roots : Array[String] = []
    for id, _ in graph.nodes {
      let parents = graph.get_direct_dependents(id)
      if parents.length() == 0 {
        roots.push(id)
      }
    }

    let len = roots.length()
    for i, root in roots {
      render_node(root, "", i == len - 1)
    }
  }

  buf.to_string()
}
