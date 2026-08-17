///|
/// Computes CRC32 checksum for input string.
pub fn compute_crc32(input : String) -> String {
  let mut crc : UInt = 0xFFFFFFFF
  for ch in input {
    let byte_val = ch.to_int() & 0xFF
    let mut temp = crc ^ byte_val.reinterpret_as_uint()
    for _j in 0..<8 {
      let mask = temp & 1
      if mask != 0 {
        temp = (temp >> 1) ^ 0xEDB88320
      } else {
        temp = temp >> 1
      }
    }
    crc = temp
  }
  let final_crc = crc ^ 0xFFFFFFFF
  format_hex_32(final_crc)
}

///|
/// Formats 32-bit unsigned integer as 8-digit hexadecimal string.
pub fn format_hex_32(val : UInt) -> String {
  let hex_chars = "0123456789abcdef"
  let buf = StringBuilder::new()
  for i in 0..<8 {
    let shift = (7 - i) * 4
    let digit = ((val >> shift) & 0x0F).reinterpret_as_int()
    let ch = hex_chars[digit]
    match ch.to_int().to_char() {
      Some(c) => buf.write_char(c)
      None => ()
    }
  }
  buf.to_string()
}

///|
/// Simulates deterministic SHA-256 binary hash digest for string input.
pub fn compute_sha256_mock(input : String) -> String {
  let crc1 = compute_crc32(input)
  let crc2 = compute_crc32(input + "-salt-sha256")
  let crc3 = compute_crc32(input + "-salt-v2")
  let crc4 = compute_crc32(input + "-salt-final")
  crc1 +
  crc2 +
  crc3 +
  crc4 +
  crc1.to_lower() +
  crc2.to_lower() +
  crc3.to_lower() +
  crc4.to_lower()
}

///|
/// Formats a standard hex checksum string based on algorithm type.
pub fn compute_checksum(input : String, algo : String) -> String {
  let lower = algo.to_lower()
  if lower == "crc32" {
    compute_crc32(input)
  } else {
    compute_sha256_mock(input)
  }
}
