///|
fn hex_code_to_val(code : Int) -> Result[Int, String] {
  if code >= 0x30 && code <= 0x39 {
    Ok(code - 0x30)
  } else if code >= 0x61 && code <= 0x66 {
    Ok(code - 0x61 + 10)
  } else if code >= 0x41 && code <= 0x46 {
    Ok(code - 0x41 + 10)
  } else {
    Err("Invalid hex character")
  }
}

///|
pub fn hex_to_bytes(hex_str : String) -> Result[Bytes, String] {
  let clean_str = hex_str.trim()
  if clean_str.length() % 2 != 0 {
    return Err("Hex string length must be even")
  }
  let len = clean_str.length() / 2
  let arr = Array::make(len, (0).to_byte())
  for i = 0; i < len; i = i + 1 {
    let c1 = clean_str[i * 2].to_int()
    let c2 = clean_str[i * 2 + 1].to_int()
    let v1 = match hex_code_to_val(c1) {
      Ok(v) => v
      Err(e) => return Err(e)
    }
    let v2 = match hex_code_to_val(c2) {
      Ok(v) => v
      Err(e) => return Err(e)
    }
    arr[i] = ((v1 << 4) | v2).to_byte()
  }
  Ok(Bytes::from_array(arr))
}

///|
fn val_to_hex_char(v : Int) -> Char {
  match v & 0xF {
    0 => '0'
    1 => '1'
    2 => '2'
    3 => '3'
    4 => '4'
    5 => '5'
    6 => '6'
    7 => '7'
    8 => '8'
    9 => '9'
    10 => 'A'
    11 => 'B'
    12 => 'C'
    13 => 'D'
    14 => 'E'
    15 => 'F'
    _ => '0'
  }
}

///|
pub fn bytes_to_hex(bytes : Bytes) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < bytes.length(); i = i + 1 {
    let b = bytes[i].to_int()
    let hi = (b >> 4) & 0xF
    let lo = b & 0xF
    buf.write_char(val_to_hex_char(hi))
    buf.write_char(val_to_hex_char(lo))
  }
  buf.to_string()
}
