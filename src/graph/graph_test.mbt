///|
test "dependency_graph_building" {
  let doc = @types.SbomDocument::new(name="Graph Test")
  let comp1 = @types.Component::new(name="A", version="1.0")
  let comp2 = @types.Component::new(name="B", version="2.0")
  let comp3 = @types.Component::new(name="C", version="3.0")

  doc.add_component(comp1)
  doc.add_component(comp2)
  doc.add_component(comp3)
  doc.add_relation("A@1.0", "B@2.0")
  doc.add_relation("B@2.0", "C@3.0")

  let g = DependencyGraph::from_document(doc)
  assert_eq(g.node_count(), 3)
  assert_eq(g.get_direct_dependencies("A@1.0").length(), 1)
  assert_eq(g.get_direct_dependencies("A@1.0")[0], "B@2.0")
}

///|
test "cycle_detection" {
  let g = DependencyGraph::new()
  let comp1 = @types.Component::new(name="Node1", version="1.0")
  let comp2 = @types.Component::new(name="Node2", version="1.0")
  let comp3 = @types.Component::new(name="Node3", version="1.0")

  g.add_node(comp1)
  g.add_node(comp2)
  g.add_node(comp3)
  g.add_edge("Node1@1.0", "Node2@1.0")
  g.add_edge("Node2@1.0", "Node3@1.0")
  g.add_edge("Node3@1.0", "Node1@1.0")

  let detector = CycleDetector::new(g)
  assert_true(detector.has_cycle())
  let cycles = detector.detect_cycles()
  assert_true(cycles.length() >= 1)
}

///|
test "path_solving_and_stats" {
  let g = DependencyGraph::new()
  let comp1 = @types.Component::new(name="App", version="1.0")
  let comp2 = @types.Component::new(name="LibA", version="1.0")
  let comp3 = @types.Component::new(name="LibB", version="1.0")
  let comp4 = @types.Component::new(name="LibA", version="2.0")

  g.add_node(comp1)
  g.add_node(comp2)
  g.add_node(comp3)
  g.add_node(comp4)
  g.add_edge("App@1.0", "LibA@1.0")
  g.add_edge("LibA@1.0", "LibB@1.0")

  let path = find_shortest_path(g, "App@1.0", "LibB@1.0")
  assert_true(path is Some(_))
  match path {
    Some(p) => {
      assert_eq(p.length(), 3)
      assert_eq(p[0], "App@1.0")
      assert_eq(p[2], "LibB@1.0")
    }
    None => ()
  }

  let summary = compute_graph_summary(g)
  assert_eq(summary.node_count, 4)
  assert_eq(summary.duplicate_packages.length(), 1)
}
