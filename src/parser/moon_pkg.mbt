///|
/// ParsedMoonPkg contains package metadata extracted from moon.pkg.
pub(all) struct ParsedMoonPkg {
  mut is_executable : Bool
  mut imports : Array[String]
  mut pkg_name : String
} derive(Eq, Debug)

///|
/// Creates empty ParsedMoonPkg.
pub fn ParsedMoonPkg::new() -> ParsedMoonPkg {
  { is_executable: false, imports: [], pkg_name: "" }
}

///|
/// Parses moon.pkg text content to extract imports and executable flag.
pub fn parse_moon_pkg_content(
  content : String,
  pkg_name? : String = "",
) -> ParsedMoonPkg {
  let pkg = ParsedMoonPkg::new()
  pkg.pkg_name = pkg_name

  if content.contains("executable") {
    pkg.is_executable = true
  }

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
    if trimmed.has_prefix("\"") && trimmed.contains("@") {
      let mut imp_name = ""
      let mut in_q = false
      let buf = StringBuilder::new()
      for ch in trimmed {
        if ch == '"' {
          if in_q {
            imp_name = buf.to_string()
            break
          } else {
            in_q = true
          }
        } else if in_q {
          buf.write_char(ch)
        }
      }
      if imp_name != "" {
        pkg.imports.push(imp_name)
      }
    }
  }

  pkg
}
