///|
pub(all) struct MacFrameHeader {
  fcf : FrameControlField
  seq_num : Int
  dest_pan_id : UInt?
  dest_addr : MacAddress
  src_pan_id : UInt?
  src_addr : MacAddress
  aux_sec : AuxSecurityHeader?
} derive(Eq, Debug)

///|
pub(all) struct MacFrame {
  header : MacFrameHeader
  payload : Bytes
  fcs : UInt
} derive(Eq, Debug)

///|
pub fn MacFrame::new(
  header : MacFrameHeader,
  payload : Bytes,
  fcs? : UInt = 0U,
) -> MacFrame {
  { header, payload, fcs }
}
