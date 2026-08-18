///|
test "frame: FCF encoding and decoding" {
  let fcf = FrameControlField::new(
    frame_type=Data,
    security_enabled=false,
    ack_request=true,
    pan_id_compression=true,
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )
  let u16_val = fcf.to_u16()
  let decoded_fcf = FrameControlField::from_u16(u16_val)
  assert_eq(decoded_fcf.frame_type, Data)
  assert_eq(decoded_fcf.ack_request, true)
  assert_eq(decoded_fcf.pan_id_compression, true)
  assert_eq(decoded_fcf.dest_addr_mode, Short16)
  assert_eq(decoded_fcf.src_addr_mode, Short16)
}

///|
test "frame: MAC frame encode and decode roundtrip" {
  let fcf = FrameControlField::new(
    frame_type=Data,
    ack_request=true,
    pan_id_compression=true,
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )
  let header : MacFrameHeader = {
    fcf,
    seq_num: 42,
    dest_pan_id: Some(0x1234U),
    dest_addr: ShortAddress(0x0001U),
    src_pan_id: Some(0x1234U),
    src_addr: ShortAddress(0x0002U),
    aux_sec: None,
  }
  let payload = Bytes::from_array([
    (0x48).to_byte(),
    (0x65).to_byte(),
    (0x6C).to_byte(),
    (0x6C).to_byte(),
    (0x6F).to_byte(),
  ])
  let frame = MacFrame::new(header, payload)

  let encoded = encode_mac_frame(frame).unwrap()
  assert_true(encoded.length() > 5)

  let decoded = decode_mac_frame(encoded).unwrap()
  assert_eq(decoded.header.seq_num, 42)
  assert_eq(decoded.header.dest_pan_id, Some(0x1234U))
  assert_eq(decoded.header.dest_addr, ShortAddress(0x0001U))
  assert_eq(decoded.header.src_addr, ShortAddress(0x0002U))
  assert_eq(decoded.payload.length(), 5)
}

///|
test "frame: broadcast destination address" {
  let fcf = FrameControlField::new(
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )
  let header : MacFrameHeader = {
    fcf,
    seq_num: 1,
    dest_pan_id: Some(0xFFFFU),
    dest_addr: BroadcastAddress,
    src_pan_id: Some(0x1234U),
    src_addr: ShortAddress(0x0005U),
    aux_sec: None,
  }
  let payload = Bytes::from_array([(0x01).to_byte()])
  let frame = MacFrame::new(header, payload)

  let encoded = encode_mac_frame(frame).unwrap()
  let decoded = decode_mac_frame(encoded).unwrap()
  assert_eq(decoded.header.dest_addr, BroadcastAddress)
}
