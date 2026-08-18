///|
pub(all) struct Position3D {
  x : Double
  y : Double
  z : Double
} derive(Eq, Debug)

///|
pub fn Position3D::distance(self : Position3D, other : Position3D) -> Double {
  let dx = self.x - other.x
  let dy = self.y - other.y
  let dz = self.z - other.z
  let sum_sq = dx * dx + dy * dy + dz * dz
  sum_sq.sqrt()
}

///|
pub(all) struct WirelessNode {
  node_id : UInt
  pan_id : UInt
  short_addr : UInt
  ext_addr : UInt64
  position : Position3D
  tx_power_dbm : Double
  rx_sensitivity_dbm : Double
} derive(Eq, Debug)

///|
pub fn WirelessNode::new(
  node_id : UInt,
  position : Position3D,
  pan_id? : UInt = 0x1234U,
  short_addr? : UInt = 0x0001U,
  tx_power_dbm? : Double = 0.0,
  rx_sensitivity_dbm? : Double = -95.0,
) -> WirelessNode {
  {
    node_id,
    pan_id,
    short_addr,
    ext_addr: node_id.to_uint64(),
    position,
    tx_power_dbm,
    rx_sensitivity_dbm,
  }
}

///|
pub fn WirelessNode::distance_to(
  self : WirelessNode,
  other : WirelessNode,
) -> Double {
  self.position.distance(other.position)
}
