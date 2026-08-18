///|
test "cli: hex to bytes and bytes to hex roundtrip" {
  let original_hex = "01020304ABCD"
  let bytes = hex_to_bytes(original_hex).unwrap()
  assert_eq(bytes.length(), 6)

  let re_hex = bytes_to_hex(bytes)
  assert_eq(re_hex, original_hex)
}

///|
test "cli: invalid hex handling" {
  let res = hex_to_bytes("123") // odd length
  assert_true(res is Err(_))

  let res2 = hex_to_bytes("12ZZ")
  assert_true(res2 is Err(_))
}

///|
test "cli: frame summary formatter" {
  let fcf = @frame.FrameControlField::new(
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )
  let header : @frame.MacFrameHeader = {
    fcf,
    seq_num: 12,
    dest_pan_id: Some(0x1234U),
    dest_addr: ShortAddress(0x0001U),
    src_pan_id: Some(0x1234U),
    src_addr: ShortAddress(0x0002U),
    aux_sec: None,
  }
  let payload = Bytes::from_array([(0xAA).to_byte()])
  let frame = @frame.MacFrame::new(header, payload, fcs=0x9999U)

  let summary = format_mac_frame_summary(frame)
  assert_true(summary.contains("Seq Number: 12"))
  assert_true(summary.contains("FCS Checksum: 0x39321"))
}

///|
test "cli: simulation report generation" {
  let config = CliSimulationConfig::default()
  let report = run_cli_simulation(config)
  assert_true(report.contains("MoonBit Wireless Link Simulation Report"))
  assert_true(report.contains("Total Transmissions Sent: 100"))
}
