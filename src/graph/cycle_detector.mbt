///|
/// CycleDetector performs DFS traversal on DependencyGraph to detect cycles.
pub(all) struct CycleDetector {
  graph : DependencyGraph
} derive(Eq, Debug)

///|
/// Creates a CycleDetector instance for a target graph.
pub fn CycleDetector::new(graph : DependencyGraph) -> CycleDetector {
  { graph, }
}

///|
/// Helper DFS function for cycle detection.
fn dfs_cycle(
  graph : DependencyGraph,
  node : String,
  visited : Map[String, Int],
  path : Array[String],
  cycles : Array[Array[String]],
) -> Unit {
  visited.set(node, 1) // 1 = visiting
  path.push(node)

  let neighbors = graph.get_direct_dependencies(node)
  for child in neighbors {
    match visited.get(child) {
      Some(1) => {
        // Found cycle!
        let cycle_path : Array[String] = []
        let mut in_cycle = false
        for item in path {
          if item == child {
            in_cycle = true
          }
          if in_cycle {
            cycle_path.push(item)
          }
        }
        cycle_path.push(child)
        cycles.push(cycle_path)
      }
      Some(0) | None => dfs_cycle(graph, child, visited, path, cycles)
      _ => ()
    }
  }

  visited.set(node, 2) // 2 = visited
  let _ = path.pop()
}

///|
/// Detects all circular dependency paths present in the graph.
pub fn CycleDetector::detect_cycles(
  self : CycleDetector,
) -> Array[Array[String]] {
  let visited : Map[String, Int] = Map::from_array([])
  let cycles : Array[Array[String]] = []

  for node, _ in self.graph.nodes {
    visited.set(node, 0)
  }

  for node, _ in self.graph.nodes {
    match visited.get(node) {
      Some(0) => dfs_cycle(self.graph, node, visited, [], cycles)
      _ => ()
    }
  }

  cycles
}

///|
/// Returns true if graph contains any cyclic dependencies.
pub fn CycleDetector::has_cycle(self : CycleDetector) -> Bool {
  self.detect_cycles().length() > 0
}
