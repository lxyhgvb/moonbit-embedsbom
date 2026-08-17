///|
/// LockedPackage represents a single locked dependency item in moon.lock.
pub(all) struct LockedPackage {
  name : String
  version : String
  checksum : String
  source : String
} derive(Eq, Debug)

///|
/// Parses lockfile string format into array of LockedPackage.
pub fn parse_moon_lock_content(content : String) -> Array[LockedPackage] {
  let packages : Array[LockedPackage] = []
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

  let mut cur_name = ""
  let mut cur_ver = ""
  let mut cur_hash = ""
  let mut cur_src = ""

  for line in lines {
    let trimmed = line.trim().to_owned()
    if trimmed.has_prefix("[") && trimmed.has_suffix("]") {
      if cur_name != "" {
        packages.push({
          name: cur_name,
          version: cur_ver,
          checksum: cur_hash,
          source: cur_src,
        })
        cur_name = ""
        cur_ver = ""
        cur_hash = ""
        cur_src = ""
      }
      cur_name = trimmed[1:trimmed.length() - 1].to_owned()
    } else {
      match extract_kv_pair(line) {
        Some((k, v)) =>
          if k == "version" {
            cur_ver = v
          } else if k == "checksum" || k == "hash" {
            cur_hash = v
          } else if k == "source" {
            cur_src = v
          }
        None => ()
      }
    }
  }

  if cur_name != "" {
    packages.push({
      name: cur_name,
      version: cur_ver,
      checksum: cur_hash,
      source: cur_src,
    })
  }

  packages
}

///|
/// Converts LockedPackage into standard Component.
pub fn LockedPackage::to_component(self : LockedPackage) -> @types.Component {
  let comp = @types.Component::new(
    name=self.name,
    version=if self.version == "" { "0.1.0" } else { self.version },
    supplier=if self.source == "" { "mooncakes.io" } else { self.source },
    component_type=@types.ComponentType::MoonBitPkg,
  )
  if self.checksum != "" {
    comp.add_checksum(@types.HashAlgorithm::SHA256, self.checksum)
  }
  comp
}
