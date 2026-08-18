///|
pub(all) struct CRC32 {
  poly : UInt
} derive(Eq, Debug)

///|
pub fn CRC32::standard() -> CRC32 {
  { poly: 0xEDB88320U }
}

///|
pub fn CRC32::calculate(self : CRC32, data : Bytes) -> UInt {
  let mut crc : UInt = 0xFFFFFFFFU
  for i = 0; i < data.length(); i = i + 1 {
    let byte_val = data[i].to_int().reinterpret_as_uint()
    crc = crc ^ byte_val
    for bit = 0; bit < 8; bit = bit + 1 {
      let mask = (crc & 1U) != 0U
      crc = crc >> 1
      if mask {
        crc = crc ^ self.poly
      }
    }
  }
  crc ^ 0xFFFFFFFFU
}
