///|
test "topology: 3D distance and node properties" {
  let p1 : Position3D = { x: 0.0, y: 0.0, z: 0.0 }
  let p2 : Position3D = { x: 3.0, y: 4.0, z: 0.0 }
  assert_eq(p1.distance(p2), 5.0)

  let node1 = WirelessNode::new(1U, p1, tx_power_dbm=0.0)
  let node2 = WirelessNode::new(2U, p2, tx_power_dbm=0.0)
  assert_eq(node1.distance_to(node2), 5.0)
}

///|
test "topology: path loss and RSSI calculation" {
  let model = PathLossModel::FreeSpaceFriis(2400.0)
  let loss = calculate_path_loss_db(model, 1.0)
  assert_true(loss > 30.0)

  let rssi = calculate_rssi_dbm(model, 10.0, 1.0)
  assert_true(rssi < 0.0)

  let lqi = rssi_to_lqi(-70.0, -95.0)
  assert_eq(lqi, 125)
}

///|
test "topology: network graph reachability" {
  let graph = NetworkGraph::new(model=PathLossModel::FreeSpaceFriis(2400.0))
  let n1 = WirelessNode::new(
    1U,
    { x: 0.0, y: 0.0, z: 0.0 },
    tx_power_dbm=10.0,
    rx_sensitivity_dbm=-130.0,
  )
  let n2 = WirelessNode::new(
    2U,
    { x: 10.0, y: 0.0, z: 0.0 },
    tx_power_dbm=10.0,
    rx_sensitivity_dbm=-130.0,
  )
  let n3 = WirelessNode::new(
    3U,
    { x: 100000.0, y: 0.0, z: 0.0 },
    tx_power_dbm=0.0,
    rx_sensitivity_dbm=-90.0,
  )

  graph.add_node(n1)
  graph.add_node(n2)
  graph.add_node(n3)

  let neighbors = graph.get_reachable_neighbors(1U)
  assert_eq(neighbors.length(), 1)
  assert_eq(neighbors[0].0, 2U)
}
