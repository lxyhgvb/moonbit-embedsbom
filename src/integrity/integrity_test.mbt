///|
test "integrity: crc16 ccitt standard computation" {
  let sample = Bytes::from_array([
    (0x01).to_byte(),
    (0x02).to_byte(),
    (0x03).to_byte(),
    (0x04).to_byte(),
  ])
  let fcs = CRC16::compute_ieee802154_fcs(sample)
  assert_true(fcs > 0U)
}

///|
test "integrity: crc32 computation" {
  let sample = Bytes::from_array([
    (0x31).to_byte(),
    (0x32).to_byte(),
    (0x33).to_byte(),
    (0x34).to_byte(),
  ])
  let crc_engine = CRC32::standard()
  let val = crc_engine.calculate(sample)
  assert_true(val > 0U)
}

///|
test "integrity: internet checksum and xor checksum" {
  let sample = Bytes::from_array([
    (0x00).to_byte(),
    (0x01).to_byte(),
    (0xF2).to_byte(),
    (0x03).to_byte(),
  ])
  let chk = compute_internet_checksum(sample)
  assert_true(chk <= 0xFFFFU)

  let xor_chk = compute_xor_checksum(sample)
  assert_eq(xor_chk, (0xF0).to_byte())
}

///|
test "integrity: error injection and diagnostics" {
  let sample = Bytes::from_array([
    (0xAA).to_byte(),
    (0xBB).to_byte(),
    (0xCC).to_byte(),
  ])
  let corrupted = inject_bit_flip(sample, 0, 0)
  assert_eq(corrupted[0], (0xAB).to_byte())

  let burst = inject_burst_error(sample, 1, 2)
  assert_eq(burst[1], (0x44).to_byte())
  assert_eq(burst[2], (0x33).to_byte())
}
