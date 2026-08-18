///|
pub(all) struct CRC16 {
  poly : UInt
  initial_seed : UInt
} derive(Eq, Debug)

///|
pub fn CRC16::ccitt_standard() -> CRC16 {
  { poly: 0x1021U, initial_seed: 0x0000U }
}

///|
pub fn CRC16::ccitt_kermit() -> CRC16 {
  { poly: 0x8408U, initial_seed: 0x0000U }
}

///|
pub fn CRC16::calculate_bitwise(self : CRC16, data : Bytes) -> UInt {
  let mut crc = self.initial_seed
  for i = 0; i < data.length(); i = i + 1 {
    let byte_val = data[i].to_int().reinterpret_as_uint()
    crc = crc ^ (byte_val << 8)
    for bit = 0; bit < 8; bit = bit + 1 {
      if (crc & 0x8000U) != 0U {
        crc = ((crc << 1) ^ self.poly) & 0xFFFFU
      } else {
        crc = (crc << 1) & 0xFFFFU
      }
    }
  }
  crc
}

///|
pub fn CRC16::compute_ieee802154_fcs(data : Bytes) -> UInt {
  let crc_engine = CRC16::ccitt_standard()
  crc_engine.calculate_bitwise(data)
}
