///|
/// Component represents an individual software, driver, library or firmware item.
pub(all) struct Component {
  id : String
  name : String
  version : String
  supplier : String
  license_id : String
  homepage : String
  repository : String
  checksums : Map[String, String]
  component_type : ComponentType
  embedded_info : EmbeddedInfo
  dependencies : Array[String]
  description : String
} derive(Eq, Debug)

///|
/// DependencyRelation specifies directed relationship between parent and child components.
pub(all) struct DependencyRelation {
  parent_id : String
  child_id : String
  relation_type : RelationType
  comment : String
} derive(Eq, Debug)

///|
/// Constructor for Component structure with smart defaults.
pub fn Component::new(
  id? : String = "",
  name~ : String,
  version? : String = "0.1.0",
  supplier? : String = "Unknown",
  license_id? : String = "MIT",
  homepage? : String = "",
  repository? : String = "",
  component_type? : ComponentType = ComponentType::MoonBitPkg,
  embedded_info? : EmbeddedInfo = EmbeddedInfo::new(),
  dependencies? : Array[String] = [],
  description? : String = "",
) -> Component {
  let comp_id = if id == "" { name + "@" + version } else { id }
  {
    id: comp_id,
    name,
    version,
    supplier,
    license_id,
    homepage,
    repository,
    checksums: {},
    component_type,
    embedded_info,
    dependencies,
    description,
  }
}

///|
/// Adds a checksum key-value pair to the component.
pub fn Component::add_checksum(
  self : Component,
  algo : HashAlgorithm,
  hash_val : String,
) -> Unit {
  self.checksums.set(algo.to_string(), hash_val)
}

///|
/// Checks if the component has a valid non-empty version.
pub fn Component::has_valid_version(self : Component) -> Bool {
  let v = self.version.trim().to_owned()
  v != "" && v != "0.0.0" && v != "latest" && v != "unknown"
}

///|
/// Checks if the component license is specified.
pub fn Component::has_license(self : Component) -> Bool {
  let lic = self.license_id.trim().to_owned().to_upper()
  lic != "" && lic != "NONE" && lic != "NOASSERTION" && lic != "UNKNOWN"
}

///|
/// Converts Component information to compact display string.
pub fn Component::to_display_string(self : Component) -> String {
  self.name +
  " v" +
  self.version +
  " [" +
  self.component_type.to_string() +
  "] (" +
  self.license_id +
  ")"
}
