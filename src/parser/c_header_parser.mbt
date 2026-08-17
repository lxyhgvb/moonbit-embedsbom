///|
/// ParsedCHeaderMacro represents a macro definition extracted from C header file.
pub(all) struct ParsedCHeaderMacro {
  name : String
  value : String
} derive(Eq, Debug)

///|
/// Parses C/C++ `#define` macro lines from header file content string.
pub fn parse_c_header_macros(content : String) -> Array[ParsedCHeaderMacro] {
  let macros : Array[ParsedCHeaderMacro] = []
  let lines : Array[String] = []
  let mut current = StringBuilder::new()
  for ch in content {
    if ch == '\n' {
      lines.push(current.to_string())
      current = StringBuilder::new()
    } else if ch != '\r' {
      current.write_char(ch)
    }
  }
  let last = current.to_string()
  if last != "" {
    lines.push(last)
  }

  for line in lines {
    let trimmed = line.trim().to_owned()
    if trimmed.has_prefix("#define") || trimmed.has_prefix("#   define") {
      let parts : Array[String] = []
      let mut item = StringBuilder::new()
      let mut in_quote = false
      for ch in trimmed {
        if ch == '"' {
          in_quote = !in_quote
          item.write_char(ch)
        } else if (ch == ' ' || ch == '\t') && !in_quote {
          let str = item.to_string().trim().to_owned()
          if str != "" {
            parts.push(str)
          }
          item = StringBuilder::new()
        } else {
          item.write_char(ch)
        }
      }
      let end_str = item.to_string().trim().to_owned()
      if end_str != "" {
        parts.push(end_str)
      }

      if parts.length() >= 3 {
        let macro_name = parts[1]
        let mut macro_val = parts[2]
        if macro_val.has_prefix("\"") &&
          macro_val.has_suffix("\"") &&
          macro_val.length() >= 2 {
          macro_val = macro_val[1:macro_val.length() - 1].to_owned()
        }
        macros.push({ name: macro_name, value: macro_val })
      }
    }
  }

  macros
}

///|
/// Extracts firmware version from parsed C header macros.
pub fn extract_version_from_c_header(
  macros : Array[ParsedCHeaderMacro],
) -> String {
  for m in macros {
    let name = m.name.to_upper()
    if name == "VERSION" ||
      name == "FIRMWARE_VERSION" ||
      name == "APP_VERSION" ||
      name == "SDK_VERSION" ||
      name.contains("VERSION_STR") {
      return m.value
    }
  }
  "0.1.0"
}
