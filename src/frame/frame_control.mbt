///|
pub(all) struct FrameControlField {
  frame_type : FrameType
  security_enabled : Bool
  frame_pending : Bool
  ack_request : Bool
  pan_id_compression : Bool
  sequence_number_suppress : Bool
  dest_addr_mode : AddressMode
  frame_version : Int
  src_addr_mode : AddressMode
} derive(Eq, Debug)

///|
pub fn FrameControlField::new(
  frame_type? : FrameType = Data,
  security_enabled? : Bool = false,
  frame_pending? : Bool = false,
  ack_request? : Bool = true,
  pan_id_compression? : Bool = false,
  sequence_number_suppress? : Bool = false,
  dest_addr_mode? : AddressMode = Short16,
  frame_version? : Int = 1,
  src_addr_mode? : AddressMode = Short16,
) -> FrameControlField {
  {
    frame_type,
    security_enabled,
    frame_pending,
    ack_request,
    pan_id_compression,
    sequence_number_suppress,
    dest_addr_mode,
    frame_version,
    src_addr_mode,
  }
}

///|
pub fn FrameControlField::to_u16(self : FrameControlField) -> UInt {
  let type_bits = match self.frame_type {
    Beacon => 0U
    Data => 1U
    Ack => 2U
    MacCmd => 3U
    Reserved(n) => n.reinterpret_as_uint() & 0x7U
  }
  let sec_bit = if self.security_enabled { 1U } else { 0U }
  let pend_bit = if self.frame_pending { 1U } else { 0U }
  let ack_bit = if self.ack_request { 1U } else { 0U }
  let pan_comp_bit = if self.pan_id_compression { 1U } else { 0U }
  let seq_supp_bit = if self.sequence_number_suppress { 1U } else { 0U }

  let dest_mode_bits = match self.dest_addr_mode {
    None => 0U
    Short16 => 2U
    Extended64 => 3U
  }

  let ver_bits = (self.frame_version & 0x3).reinterpret_as_uint()

  let src_mode_bits = match self.src_addr_mode {
    None => 0U
    Short16 => 2U
    Extended64 => 3U
  }

  (type_bits & 0x7U) |
  (sec_bit << 3) |
  (pend_bit << 4) |
  (ack_bit << 5) |
  (pan_comp_bit << 6) |
  (seq_supp_bit << 8) |
  (dest_mode_bits << 10) |
  (ver_bits << 12) |
  (src_mode_bits << 14)
}

///|
pub fn FrameControlField::from_u16(val : UInt) -> FrameControlField {
  let type_num = (val & 0x7U).reinterpret_as_int()
  let frame_type = match type_num {
    0 => Beacon
    1 => Data
    2 => Ack
    3 => MacCmd
    n => Reserved(n)
  }

  let security_enabled = ((val >> 3) & 1U) != 0U
  let frame_pending = ((val >> 4) & 1U) != 0U
  let ack_request = ((val >> 5) & 1U) != 0U
  let pan_id_compression = ((val >> 6) & 1U) != 0U
  let sequence_number_suppress = ((val >> 8) & 1U) != 0U

  let dest_mode_num = ((val >> 10) & 0x3U).reinterpret_as_int()
  let dest_addr_mode = match dest_mode_num {
    2 => Short16
    3 => Extended64
    _ => None
  }

  let frame_version = ((val >> 12) & 0x3U).reinterpret_as_int()

  let src_mode_num = ((val >> 14) & 0x3U).reinterpret_as_int()
  let src_addr_mode = match src_mode_num {
    2 => Short16
    3 => Extended64
    _ => None
  }

  {
    frame_type,
    security_enabled,
    frame_pending,
    ack_request,
    pan_id_compression,
    sequence_number_suppress,
    dest_addr_mode,
    frame_version,
    src_addr_mode,
  }
}
