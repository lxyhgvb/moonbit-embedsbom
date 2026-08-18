///|
test "bitstream: reader and writer roundtrip MSB" {
  let writer = BitWriter::new(order=MsbFirst)
  let _ = writer.write_u32(0b101101U, 6)
  let _ = writer.write_u32(0x1234U, 16)
  let _ = writer.write_bit(true)
  let _ = writer.write_bit(false)
  writer.align_to_byte()

  let bytes = writer.to_bytes()
  let reader = BitReader::new(bytes, order=MsbFirst)

  let v1 = reader.read_u32(6).unwrap()
  assert_eq(v1, 0b101101U)

  let v2 = reader.read_u32(16).unwrap()
  assert_eq(v2, 0x1234U)

  let b1 = reader.read_bit().unwrap()
  assert_eq(b1, true)

  let b2 = reader.read_bit().unwrap()
  assert_eq(b2, false)
}

///|
test "bitstream: reader and writer roundtrip LSB" {
  let writer = BitWriter::new(order=LsbFirst)
  let _ = writer.write_u32(0xABU, 8)
  let _ = writer.write_u32(0x7U, 3)
  writer.align_to_byte()

  let bytes = writer.to_bytes()
  let reader = BitReader::new(bytes, order=LsbFirst)

  let v1 = reader.read_u32(8).unwrap()
  assert_eq(v1, 0xABU)

  let v2 = reader.read_u32(3).unwrap()
  assert_eq(v2, 0x7U)
}

///|
test "bitstream: u64 read and write" {
  let writer = BitWriter::new(order=MsbFirst)
  let val : UInt64 = 0x123456789ABCDEF0UL
  let _ = writer.write_u64(val, 64)
  let bytes = writer.to_bytes()

  let reader = BitReader::new(bytes, order=MsbFirst)
  let read_val = reader.read_u64(64).unwrap()
  assert_eq(read_val, val)
}

///|
test "bitstream: out of bounds error" {
  let bytes = Bytes::from_array([(0xAA).to_byte()])
  let reader = BitReader::new(bytes)
  let _ = reader.read_u32(8).unwrap()
  let res = reader.read_bit()
  assert_true(res is Err(_))
}
