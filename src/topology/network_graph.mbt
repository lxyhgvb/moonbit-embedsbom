///|
pub(all) struct NetworkGraph {
  nodes : Array[WirelessNode]
  model : PathLossModel
} derive(Eq, Debug)

///|
pub fn NetworkGraph::new(
  model? : PathLossModel = FreeSpaceFriis(2400.0),
) -> NetworkGraph {
  { nodes: Array::new(), model }
}

///|
pub fn NetworkGraph::add_node(self : NetworkGraph, node : WirelessNode) -> Unit {
  self.nodes.push(node)
}

///|
pub fn NetworkGraph::get_node(
  self : NetworkGraph,
  node_id : UInt,
) -> WirelessNode? {
  for i = 0; i < self.nodes.length(); i = i + 1 {
    if self.nodes[i].node_id == node_id {
      return Some(self.nodes[i])
    }
  }
  None
}

///|
pub fn NetworkGraph::get_reachable_neighbors(
  self : NetworkGraph,
  node_id : UInt,
) -> Array[(UInt, Double, Int)] { // (neighbor_node_id, rssi_dbm, lqi)
  let result = Array::new()
  let src_node_opt = self.get_node(node_id)
  match src_node_opt {
    Some(src_node) =>
      for i = 0; i < self.nodes.length(); i = i + 1 {
        let dest = self.nodes[i]
        if dest.node_id != node_id {
          let dist = src_node.distance_to(dest)
          let rssi = calculate_rssi_dbm(self.model, src_node.tx_power_dbm, dist)
          if rssi >= dest.rx_sensitivity_dbm {
            let lqi = rssi_to_lqi(rssi, dest.rx_sensitivity_dbm)
            result.push((dest.node_id, rssi, lqi))
          }
        }
      }
    None => ()
  }
  result
}
