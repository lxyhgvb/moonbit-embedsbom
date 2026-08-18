///|
pub(all) enum FilterDecision {
  Accept
  RejectPanMismatch(UInt, UInt) // expected, actual
  RejectAddressMismatch
  RejectDisabled
} derive(Eq, Debug)

///|
pub(all) struct AddressFilterConfig {
  local_pan_id : UInt
  local_short_addr : UInt
  local_ext_addr : UInt64
  promiscuous_mode : Bool
  allow_broadcast : Bool
} derive(Eq, Debug)

///|
pub fn AddressFilterConfig::default() -> AddressFilterConfig {
  {
    local_pan_id: 0x1234U,
    local_short_addr: 0x0001U,
    local_ext_addr: 0x0000000000000001UL,
    promiscuous_mode: false,
    allow_broadcast: true,
  }
}

///|
pub(all) struct AddressFilter {
  config : AddressFilterConfig
} derive(Eq, Debug)

///|
pub fn AddressFilter::new(config : AddressFilterConfig) -> AddressFilter {
  { config, }
}

///|
pub fn AddressFilter::evaluate_header(
  self : AddressFilter,
  header : @frame.MacFrameHeader,
) -> FilterDecision {
  if self.config.promiscuous_mode {
    return Accept
  }

  // PAN ID Check
  match header.dest_pan_id {
    Some(pan) =>
      if pan != 0xFFFFU && pan != self.config.local_pan_id {
        return RejectPanMismatch(self.config.local_pan_id, pan)
      }
    None => ()
  }

  // Address Check
  match header.dest_addr {
    BroadcastAddress =>
      if self.config.allow_broadcast {
        Accept
      } else {
        RejectAddressMismatch
      }
    ShortAddress(addr) =>
      if addr == self.config.local_short_addr {
        Accept
      } else {
        RejectAddressMismatch
      }
    ExtendedAddress(addr) =>
      if addr == self.config.local_ext_addr {
        Accept
      } else {
        RejectAddressMismatch
      }
    NoneAddress => Accept
  }
}
