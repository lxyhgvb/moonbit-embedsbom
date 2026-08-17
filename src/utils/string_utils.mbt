///|
/// Pads string on the right to target length.
pub fn pad_right(s : String, width : Int, char? : Char = ' ') -> String {
  let len = s.length()
  if len >= width {
    s
  } else {
    let buf = StringBuilder::new()
    buf.write_string(s)
    for _i in 0..<(width - len) {
      buf.write_char(char)
    }
    buf.to_string()
  }
}

///|
/// Pads string on the left to target length.
pub fn pad_left(s : String, width : Int, char? : Char = ' ') -> String {
  let len = s.length()
  if len >= width {
    s
  } else {
    let buf = StringBuilder::new()
    for _i in 0..<(width - len) {
      buf.write_char(char)
    }
    buf.write_string(s)
    buf.to_string()
  }
}

///|
/// Truncates string with ellipsis if longer than max_len.
pub fn truncate_string(s : String, max_len : Int) -> String {
  if s.length() <= max_len || max_len < 4 {
    s
  } else {
    let buf = StringBuilder::new()
    let mut count = 0
    for ch in s {
      if count >= max_len - 3 {
        break
      }
      buf.write_char(ch)
      count = count + 1
    }
    buf.write_string("...")
    buf.to_string()
  }
}

///|
/// Formats a key-value ASCII status line.
pub fn format_kv_line(
  key : String,
  value : String,
  width? : Int = 24,
) -> String {
  pad_right(key + ":", width) + " " + value
}

///|
/// Sanitizes component name to safe slug string.
pub fn slugify_component_name(s : String) -> String {
  let buf = StringBuilder::new()
  for ch in s {
    let code = ch.to_int()
    if (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      (code >= 48 && code <= 57) ||
      ch == '-' ||
      ch == '_' {
      buf.write_char(ch)
    } else if ch == ' ' || ch == '/' || ch == '.' {
      buf.write_char('-')
    }
  }
  buf.to_string().to_lower()
}

///|
/// Extracts basename from path string.
pub fn extract_basename(path : String) -> String {
  let clean = path.replace_all(old="\\", new="/")
  let parts : Array[String] = []
  let mut current = StringBuilder::new()
  for ch in clean {
    if ch == '/' {
      let str = current.to_string()
      if str != "" {
        parts.push(str)
      }
      current = StringBuilder::new()
    } else {
      current.write_char(ch)
    }
  }
  let last = current.to_string()
  if last != "" {
    parts.push(last)
  }
  if parts.length() > 0 {
    parts[parts.length() - 1]
  } else {
    path
  }
}
