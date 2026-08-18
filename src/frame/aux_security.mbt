///|
pub(all) struct AuxSecurityHeader {
  security_level : Int // 3 bits (0-7)
  key_id_mode : Int // 2 bits (0-3)
  frame_counter : UInt
  key_source : Bytes
  key_index : Int
} derive(Eq, Debug)

///|
pub fn AuxSecurityHeader::new(
  security_level? : Int = 0,
  key_id_mode? : Int = 0,
  frame_counter? : UInt = 0U,
  key_source? : Bytes = Bytes::new(0),
  key_index? : Int = 0,
) -> AuxSecurityHeader {
  { security_level, key_id_mode, frame_counter, key_source, key_index }
}

///|
pub fn AuxSecurityHeader::encode(self : AuxSecurityHeader) -> Bytes {
  let sec_ctrl = ((self.security_level & 0x7) | ((self.key_id_mode & 0x3) << 3)).to_byte()
  let arr = Array::new(capacity=10)
  arr.push(sec_ctrl)

  arr.push((self.frame_counter & 0xFFU).to_byte())
  arr.push(((self.frame_counter >> 8) & 0xFFU).to_byte())
  arr.push(((self.frame_counter >> 16) & 0xFFU).to_byte())
  arr.push(((self.frame_counter >> 24) & 0xFFU).to_byte())

  for i = 0; i < self.key_source.length(); i = i + 1 {
    arr.push(self.key_source[i])
  }
  if self.key_id_mode > 0 {
    arr.push(self.key_index.to_byte())
  }

  Bytes::from_array(arr)
}
