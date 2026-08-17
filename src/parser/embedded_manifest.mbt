///|
/// EmbeddedManifestEntry represents an embedded component inventory item.
pub(all) struct EmbeddedManifestEntry {
  name : String
  version : String
  category : String
  license_id : String
  vendor : String
  bsp_model : String
  checksum : String
  dependencies : Array[String]
} derive(Eq, Debug)

///|
/// Creates empty EmbeddedManifestEntry.
pub fn EmbeddedManifestEntry::new(
  name~ : String,
  version? : String = "1.0.0",
  category? : String = "driver",
  license_id? : String = "BSD-3-Clause",
  vendor? : String = "STMicroelectronics",
  bsp_model? : String = "STM32F4xx",
  checksum? : String = "",
  dependencies? : Array[String] = [],
) -> EmbeddedManifestEntry {
  {
    name,
    version,
    category,
    license_id,
    vendor,
    bsp_model,
    checksum,
    dependencies,
  }
}

///|
/// Converts EmbeddedManifestEntry to standard Component with EmbeddedInfo attached.
pub fn EmbeddedManifestEntry::to_component(
  self : EmbeddedManifestEntry,
  embedded~ : @types.EmbeddedInfo,
) -> @types.Component {
  let ctype = @types.ComponentType::from_string(self.category)
  let comp = @types.Component::new(
    name=self.name,
    version=self.version,
    supplier=self.vendor,
    license_id=self.license_id,
    component_type=ctype,
    embedded_info=embedded,
    dependencies=self.dependencies,
    description="Embedded component for " + self.bsp_model,
  )
  if self.checksum != "" {
    comp.add_checksum(@types.HashAlgorithm::SHA256, self.checksum)
  }
  comp
}

///|
/// Parses simple CSV/KV format embedded components manifest.
pub fn parse_embedded_manifest(
  content : String,
) -> Array[EmbeddedManifestEntry] {
  let entries : Array[EmbeddedManifestEntry] = []
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
    if trimmed == "" || trimmed.has_prefix("#") || trimmed.has_prefix("//") {
      continue
    }

    let parts : Array[String] = []
    let mut item = StringBuilder::new()
    for ch in trimmed {
      if ch == ',' || ch == ';' {
        parts.push(item.to_string().trim().to_owned())
        item = StringBuilder::new()
      } else {
        item.write_char(ch)
      }
    }
    let end_item = item.to_string().trim().to_owned()
    if end_item != "" {
      parts.push(end_item)
    }

    if parts.length() >= 4 {
      let name = parts[0]
      let version = parts[1]
      let category = parts[2]
      let license_id = parts[3]
      let vendor = if parts.length() >= 5 { parts[4] } else { "Vendor" }
      let bsp_model = if parts.length() >= 6 { parts[5] } else { "Generic" }
      entries.push({
        name,
        version,
        category,
        license_id,
        vendor,
        bsp_model,
        checksum: "",
        dependencies: [],
      })
    }
  }

  entries
}
