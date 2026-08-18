///|
pub(all) enum FrameType {
  Beacon
  Data
  Ack
  MacCmd
  Reserved(Int)
} derive(Eq, Debug)

///|
pub(all) enum AddressMode {
  None
  Short16
  Extended64
} derive(Eq, Debug)

///|
pub(all) enum MacAddress {
  NoneAddress
  ShortAddress(UInt)
  ExtendedAddress(UInt64)
  BroadcastAddress
} derive(Eq, Debug)

///|
pub fn MacAddress::to_address_mode(self : MacAddress) -> AddressMode {
  match self {
    NoneAddress => None
    ShortAddress(_) => Short16
    ExtendedAddress(_) => Extended64
    BroadcastAddress => Short16
  }
}
