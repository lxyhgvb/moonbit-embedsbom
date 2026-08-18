///|
pub(all) enum FrameIntegrityStatus {
  Valid
  ChecksumMismatch(UInt, UInt) // expected, actual
  LengthMismatch(Int, Int) // declared, actual
  InvalidHeader
  CorruptedPayload
} derive(Eq, Debug)

///|
pub(all) struct IntegrityReport {
  status : FrameIntegrityStatus
  error_bit_count : Int
  details : String
} derive(Eq, Debug)

///|
pub fn inject_bit_flip(data : Bytes, byte_idx : Int, bit_idx : Int) -> Bytes {
  if byte_idx < 0 || byte_idx >= data.length() || bit_idx < 0 || bit_idx > 7 {
    return data
  }
  let arr = Array::make(data.length(), (0).to_byte())
  for i = 0; i < data.length(); i = i + 1 {
    arr[i] = data[i]
  }
  let curr = arr[byte_idx].to_int()
  let flipped = curr ^ (1 << bit_idx)
  arr[byte_idx] = flipped.to_byte()
  Bytes::from_array(arr)
}

///|
pub fn inject_burst_error(data : Bytes, start_byte : Int, len : Int) -> Bytes {
  let arr = Array::make(data.length(), (0).to_byte())
  for i = 0; i < data.length(); i = i + 1 {
    arr[i] = data[i]
  }
  let end_byte = if start_byte + len < data.length() {
    start_byte + len
  } else {
    data.length()
  }
  for i = start_byte; i < end_byte; i = i + 1 {
    arr[i] = (arr[i].to_int() ^ 0xFF).to_byte()
  }
  Bytes::from_array(arr)
}

///|
pub fn verify_frame_checksum(
  data : Bytes,
  expected_fcs : UInt,
) -> IntegrityReport {
  let computed_fcs = CRC16::compute_ieee802154_fcs(data)
  if computed_fcs == expected_fcs {
    { status: Valid, error_bit_count: 0, details: "Frame FCS valid" }
  } else {
    {
      status: ChecksumMismatch(expected_fcs, computed_fcs),
      error_bit_count: 1,
      details: "FCS mismatch",
    }
  }
}
