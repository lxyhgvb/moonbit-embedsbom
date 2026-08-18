///|
test "filter: unicast address matching accept and reject" {
  let config = AddressFilterConfig::default()
  let filter = AddressFilter::new(config)

  let fcf = @frame.FrameControlField::new(
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )

  let matching_header : @frame.MacFrameHeader = {
    fcf,
    seq_num: 1,
    dest_pan_id: Some(0x1234U),
    dest_addr: ShortAddress(0x0001U),
    src_pan_id: Some(0x1234U),
    src_addr: ShortAddress(0x0002U),
    aux_sec: None,
  }
  assert_eq(filter.evaluate_header(matching_header), Accept)

  let mismatch_header : @frame.MacFrameHeader = {
    fcf,
    seq_num: 2,
    dest_pan_id: Some(0x1234U),
    dest_addr: ShortAddress(0x0009U),
    src_pan_id: Some(0x1234U),
    src_addr: ShortAddress(0x0002U),
    aux_sec: None,
  }
  assert_eq(filter.evaluate_header(mismatch_header), RejectAddressMismatch)
}

///|
test "filter: promiscuous mode override" {
  let config : AddressFilterConfig = {
    local_pan_id: 0x1234U,
    local_short_addr: 0x0001U,
    local_ext_addr: 0x0000000000000001UL,
    promiscuous_mode: true,
    allow_broadcast: true,
  }
  let filter = AddressFilter::new(config)

  let fcf = @frame.FrameControlField::new(
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )
  let foreign_header : @frame.MacFrameHeader = {
    fcf,
    seq_num: 1,
    dest_pan_id: Some(0x9999U),
    dest_addr: ShortAddress(0x9999U),
    src_pan_id: Some(0x9999U),
    src_addr: ShortAddress(0x8888U),
    aux_sec: None,
  }
  assert_eq(filter.evaluate_header(foreign_header), Accept)
}
