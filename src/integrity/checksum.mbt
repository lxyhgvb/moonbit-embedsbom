///|
pub fn compute_internet_checksum(data : Bytes) -> UInt {
  let mut sum : UInt = 0U
  let len = data.length()
  let mut i = 0
  while i < len - 1 {
    let word = (data[i].to_int() << 8) | data[i + 1].to_int()
    sum = sum + word.reinterpret_as_uint()
    if sum > 0xFFFFU {
      sum = (sum & 0xFFFFU) + (sum >> 16)
    }
    i = i + 2
  }
  if i < len {
    let word = data[i].to_int() << 8
    sum = sum + word.reinterpret_as_uint()
    if sum > 0xFFFFU {
      sum = (sum & 0xFFFFU) + (sum >> 16)
    }
  }
  ((sum & 0xFFFFU) ^ 0xFFFFU) & 0xFFFFU
}

///|
pub fn compute_xor_checksum(data : Bytes) -> Byte {
  let mut acc : Int = 0
  for i = 0; i < data.length(); i = i + 1 {
    acc = acc ^ data[i].to_int()
  }
  acc.to_byte()
}
