///|
/// Finds all transitive dependency IDs starting from start_id.
pub fn get_all_transitive_dependencies(
  graph : DependencyGraph,
  start_id : String,
) -> Array[String] {
  let visited : Map[String, Bool] = Map::from_array([])
  let result : Array[String] = []

  fn bfs(current : String) -> Unit {
    let queue : Array[String] = [current]
    visited.set(current, true)

    let mut head = 0
    while head < queue.length() {
      let node = queue[head]
      head = head + 1

      if node != current {
        result.push(node)
      }

      let deps = graph.get_direct_dependencies(node)
      for child in deps {
        match visited.get(child) {
          Some(true) => ()
          _ => {
            visited.set(child, true)
            queue.push(child)
          }
        }
      }
    }
  }

  bfs(start_id)
  result
}

///|
/// Solves shortest dependency path between src_id and dst_id.
pub fn find_shortest_path(
  graph : DependencyGraph,
  src_id : String,
  dst_id : String,
) -> Array[String]? {
  if src_id == dst_id {
    return Some([src_id])
  }

  let parent_map : Map[String, String] = Map::from_array([])
  let visited : Map[String, Bool] = Map::from_array([])
  let queue : Array[String] = [src_id]
  visited.set(src_id, true)

  let mut head = 0
  let mut found = false

  while head < queue.length() {
    let node = queue[head]
    head = head + 1

    if node == dst_id {
      found = true
      break
    }

    let deps = graph.get_direct_dependencies(node)
    for child in deps {
      match visited.get(child) {
        Some(true) => ()
        _ => {
          visited.set(child, true)
          parent_map.set(child, node)
          queue.push(child)
        }
      }
    }
  }

  if found {
    let path : Array[String] = []
    let mut curr = dst_id
    path.push(curr)
    while curr != src_id {
      match parent_map.get(curr) {
        Some(p) => {
          path.push(p)
          curr = p
        }
        None => break
      }
    }
    let reversed : Array[String] = []
    let len = path.length()
    for i in 0..<len {
      reversed.push(path[len - 1 - i])
    }
    Some(reversed)
  } else {
    None
  }
}
