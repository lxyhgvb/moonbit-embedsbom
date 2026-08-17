///|
/// ParsedMoonMod represents metadata extracted from moon.mod or moon.mod.json.
pub(all) struct ParsedMoonMod {
  mut name : String
  mut version : String
  mut license_id : String
  mut description : String
  mut repository : String
  mut dependencies : Array[String]
  mut keywords : Array[String]
} derive(Eq, Debug)

///|
/// Creates a empty ParsedMoonMod structure.
pub fn ParsedMoonMod::new() -> ParsedMoonMod {
  {
    name: "unnamed-module",
    version: "0.1.0",
    license_id: "MIT",
    description: "",
    repository: "",
    dependencies: [],
    keywords: [],
  }
}

///|
/// Extracts key value string from simple MoonBit mod format line (e.g. key = "value").
pub fn extract_kv_pair(line : String) -> (String, String)? {
  let trimmed = line.trim().to_owned()
  if trimmed == "" || trimmed.has_prefix("//") || trimmed.has_prefix("#") {
    None
  } else {
    let parts : Array[String] = []
    let mut current = StringBuilder::new()
    let mut in_quote = false
    for ch in trimmed {
      if ch == '"' {
        in_quote = !in_quote
      } else if ch == '=' && !in_quote {
        parts.push(current.to_string().trim().to_owned())
        current = StringBuilder::new()
      } else {
        current.write_char(ch)
      }
    }
    let last = current.to_string().trim().to_owned()
    if last != "" {
      parts.push(last)
    }
    if parts.length() >= 2 {
      let key = parts[0]
      let mut val = parts[1]
      if val.has_prefix("\"") && val.has_suffix("\"") && val.length() >= 2 {
        val = val[1:val.length() - 1].to_owned()
      }
      Some((key, val))
    } else {
      None
    }
  }
}

///|
/// Parses moon.mod file content string into ParsedMoonMod.
pub fn parse_moon_mod_content(content : String) -> ParsedMoonMod {
  let result = ParsedMoonMod::new()
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
    match extract_kv_pair(line) {
      Some((k, v)) =>
        if k == "name" {
          result.name = v
        } else if k == "version" {
          result.version = v
        } else if k == "license" {
          result.license_id = v
        } else if k == "description" {
          result.description = v
        } else if k == "repository" {
          result.repository = v
        }
      None => ()
    }
  }

  result
}

///|
/// Converts ParsedMoonMod into a standard Component.
pub fn ParsedMoonMod::to_component(self : ParsedMoonMod) -> @types.Component {
  @types.Component::new(
    name=self.name,
    version=self.version,
    supplier="MoonBit Developer",
    license_id=self.license_id,
    repository=self.repository,
    component_type=@types.ComponentType::MoonBitPkg,
    dependencies=self.dependencies,
    description=self.description,
  )
}
