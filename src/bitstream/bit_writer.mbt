///|
pub(all) struct BitWriter {
  buffer : Array[Byte]
  mut bit_pos : Int
  order : BitOrder
}

///|
pub fn BitWriter::new(
  capacity? : Int = 64,
  order? : BitOrder = MsbFirst,
) -> BitWriter {
  { buffer: Array::make(capacity, (0).to_byte()), bit_pos: 0, order }
}

///|
pub fn BitWriter::get_bit_count(self : BitWriter) -> Int {
  self.bit_pos
}

///|
pub fn BitWriter::get_byte_count(self : BitWriter) -> Int {
  (self.bit_pos + 7) / 8
}

///|
fn BitWriter::ensure_capacity(self : BitWriter, additional_bits : Int) -> Unit {
  let required_bytes = (self.bit_pos + additional_bits + 7) / 8
  while self.buffer.length() < required_bytes {
    self.buffer.push((0).to_byte())
  }
}

///|
pub fn BitWriter::write_bit(
  self : BitWriter,
  value : Bool,
) -> Result[Unit, BitStreamError] {
  self.ensure_capacity(1)
  let byte_idx = self.bit_pos / 8
  let bit_idx = self.bit_pos % 8
  let curr = self.buffer[byte_idx].to_int()
  let new_val = match self.order {
    MsbFirst => {
      let mask = 1 << (7 - bit_idx)
      if value {
        curr | mask
      } else {
        curr & mask.lnot()
      }
    }
    LsbFirst => {
      let mask = 1 << bit_idx
      if value {
        curr | mask
      } else {
        curr & mask.lnot()
      }
    }
  }
  self.buffer[byte_idx] = new_val.to_byte()
  self.bit_pos = self.bit_pos + 1
  Ok(())
}

///|
pub fn BitWriter::write_u32(
  self : BitWriter,
  value : UInt,
  count : Int,
) -> Result[Unit, BitStreamError] {
  if count <= 0 || count > 32 {
    return Err(InvalidBitWidth(count))
  }
  match self.order {
    MsbFirst =>
      for i = count - 1; i >= 0; i = i - 1 {
        let bit = ((value >> i) & 1U) != 0U
        match self.write_bit(bit) {
          Ok(_) => ()
          Err(e) => return Err(e)
        }
      }
    LsbFirst =>
      for i = 0; i < count; i = i + 1 {
        let bit = ((value >> i) & 1U) != 0U
        match self.write_bit(bit) {
          Ok(_) => ()
          Err(e) => return Err(e)
        }
      }
  }
  Ok(())
}

///|
pub fn BitWriter::write_u64(
  self : BitWriter,
  value : UInt64,
  count : Int,
) -> Result[Unit, BitStreamError] {
  if count <= 0 || count > 64 {
    return Err(InvalidBitWidth(count))
  }
  match self.order {
    MsbFirst =>
      for i = count - 1; i >= 0; i = i - 1 {
        let bit = ((value >> i) & 1UL) != 0UL
        match self.write_bit(bit) {
          Ok(_) => ()
          Err(e) => return Err(e)
        }
      }
    LsbFirst =>
      for i = 0; i < count; i = i + 1 {
        let bit = ((value >> i) & 1UL) != 0UL
        match self.write_bit(bit) {
          Ok(_) => ()
          Err(e) => return Err(e)
        }
      }
  }
  Ok(())
}

///|
pub fn BitWriter::write_bytes(
  self : BitWriter,
  bytes : Bytes,
) -> Result[Unit, BitStreamError] {
  for i = 0; i < bytes.length(); i = i + 1 {
    let byte_val = bytes[i].to_int()
    let u_val = byte_val.reinterpret_as_uint()
    match self.write_u32(u_val, 8) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  Ok(())
}

///|
pub fn BitWriter::align_to_byte(
  self : BitWriter,
  fill_with_ones? : Bool = false,
) -> Unit {
  let rem = self.bit_pos % 8
  if rem != 0 {
    let pad_count = 8 - rem
    for i = 0; i < pad_count; i = i + 1 {
      let _ = self.write_bit(fill_with_ones)
    }
  }
}

///|
pub fn BitWriter::to_bytes(self : BitWriter) -> Bytes {
  let total_bytes = self.get_byte_count()
  let result = Array::make(total_bytes, (0).to_byte())
  for i = 0; i < total_bytes; i = i + 1 {
    result[i] = self.buffer[i]
  }
  Bytes::from_array(result)
}
