///|
pub(all) struct BitReader {
  buffer : Bytes
  mut bit_pos : Int
  order : BitOrder
}

///|
pub fn BitReader::new(
  buffer : Bytes,
  order? : BitOrder = MsbFirst,
) -> BitReader {
  { buffer, bit_pos: 0, order }
}

///|
pub fn BitReader::from_array(
  bytes : Array[Byte],
  order? : BitOrder = MsbFirst,
) -> BitReader {
  BitReader::new(Bytes::from_array(bytes), order~)
}

///|
pub fn BitReader::remaining_bits(self : BitReader) -> Int {
  let total = self.buffer.length() * 8
  if self.bit_pos >= total {
    0
  } else {
    total - self.bit_pos
  }
}

///|
pub fn BitReader::get_position(self : BitReader) -> BitPosition {
  { byte_offset: self.bit_pos / 8, bit_offset: self.bit_pos % 8 }
}

///|
pub fn BitReader::set_position(self : BitReader, pos : BitPosition) -> Unit {
  self.bit_pos = pos.byte_offset * 8 + pos.bit_offset
}

///|
pub fn BitReader::is_aligned(self : BitReader) -> Bool {
  self.bit_pos % 8 == 0
}

///|
pub fn BitReader::align_to_byte(self : BitReader) -> Unit {
  let rem = self.bit_pos % 8
  if rem != 0 {
    self.bit_pos = self.bit_pos + (8 - rem)
  }
}

///|
pub fn BitReader::read_bit(self : BitReader) -> Result[Bool, BitStreamError] {
  if self.remaining_bits() < 1 {
    return Err(OutOfBounds(1, self.remaining_bits()))
  }
  let byte_idx = self.bit_pos / 8
  let bit_idx = self.bit_pos % 8
  let byte_val = self.buffer[byte_idx].to_int()
  let bit_val = match self.order {
    MsbFirst => ((byte_val >> (7 - bit_idx)) & 1) != 0
    LsbFirst => ((byte_val >> bit_idx) & 1) != 0
  }
  self.bit_pos = self.bit_pos + 1
  Ok(bit_val)
}

///|
pub fn BitReader::read_u32(
  self : BitReader,
  count : Int,
) -> Result[UInt, BitStreamError] {
  if count <= 0 || count > 32 {
    return Err(InvalidBitWidth(count))
  }
  if self.remaining_bits() < count {
    return Err(OutOfBounds(count, self.remaining_bits()))
  }
  let mut acc : UInt = 0U
  for i = 0; i < count; i = i + 1 {
    let bit = match self.read_bit() {
      Ok(true) => 1U
      Ok(false) => 0U
      Err(err) => return Err(err)
    }
    match self.order {
      MsbFirst => acc = (acc << 1) | bit
      LsbFirst => acc = acc | (bit << i)
    }
  }
  Ok(acc)
}

///|
pub fn BitReader::read_u64(
  self : BitReader,
  count : Int,
) -> Result[UInt64, BitStreamError] {
  if count <= 0 || count > 64 {
    return Err(InvalidBitWidth(count))
  }
  if self.remaining_bits() < count {
    return Err(OutOfBounds(count, self.remaining_bits()))
  }
  let mut acc : UInt64 = 0UL
  for i = 0; i < count; i = i + 1 {
    let bit = match self.read_bit() {
      Ok(true) => 1UL
      Ok(false) => 0UL
      Err(err) => return Err(err)
    }
    match self.order {
      MsbFirst => acc = (acc << 1) | bit
      LsbFirst => acc = acc | (bit << i)
    }
  }
  Ok(acc)
}

///|
pub fn BitReader::read_bytes(
  self : BitReader,
  length : Int,
) -> Result[Bytes, BitStreamError] {
  if self.remaining_bits() < length * 8 {
    return Err(OutOfBounds(length * 8, self.remaining_bits()))
  }
  let arr = Array::make(length, (0).to_byte())
  for i = 0; i < length; i = i + 1 {
    match self.read_u32(8) {
      Ok(v) => arr[i] = v.to_byte()
      Err(err) => return Err(err)
    }
  }
  Ok(Bytes::from_array(arr))
}

///|
pub fn BitReader::peek_u32(
  self : BitReader,
  count : Int,
) -> Result[UInt, BitStreamError] {
  let saved = self.bit_pos
  let res = self.read_u32(count)
  self.bit_pos = saved
  res
}
