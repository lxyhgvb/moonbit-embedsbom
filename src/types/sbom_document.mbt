///|
/// SbomDocument is the top-level container for an entire embedded software bill of materials document.
pub(all) struct SbomDocument {
  id : String
  name : String
  doc_namespace : String
  version : String
  creator : String
  created_at : String
  embedded_info : EmbeddedInfo
  components : Array[Component]
  relationships : Array[DependencyRelation]
  vulnerabilities : Array[Vulnerability]
} derive(Eq, Debug)

///|
/// Creates a empty or pre-populated SbomDocument.
pub fn SbomDocument::new(
  id? : String = "DOCUMENT-001",
  name? : String = "Embedded Firmware SBOM",
  doc_namespace? : String = "https://spdx.org/spdxdocs/moonbit-embedsbom",
  version? : String = "1.0.0",
  creator? : String = "MoonBit embedsbom CLI",
  created_at? : String = "2026-08-17T00:00:00Z",
  embedded_info? : EmbeddedInfo = EmbeddedInfo::new(),
) -> SbomDocument {
  {
    id,
    name,
    doc_namespace,
    version,
    creator,
    created_at,
    embedded_info,
    components: [],
    relationships: [],
    vulnerabilities: [],
  }
}

///|
/// Adds a component to the document if not already present by ID.
pub fn SbomDocument::add_component(
  self : SbomDocument,
  comp : Component,
) -> Unit {
  let mut exists = false
  for existing in self.components {
    if existing.id == comp.id {
      exists = true
      break
    }
  }
  if !exists {
    self.components.push(comp)
  }
}

///|
/// Adds a dependency relation to the document.
pub fn SbomDocument::add_relation(
  self : SbomDocument,
  parent_id : String,
  child_id : String,
  relation_type? : RelationType = RelationType::DependsOn,
  comment? : String = "",
) -> Unit {
  let rel = { parent_id, child_id, relation_type, comment }
  self.relationships.push(rel)
}

///|
/// Adds a vulnerability record to the document.
pub fn SbomDocument::add_vulnerability(
  self : SbomDocument,
  vuln : Vulnerability,
) -> Unit {
  self.vulnerabilities.push(vuln)
}

///|
/// Finds a component by its unique ID.
pub fn SbomDocument::find_component_by_id(
  self : SbomDocument,
  id : String,
) -> Component? {
  for comp in self.components {
    if comp.id == id {
      return Some(comp)
    }
  }
  None
}

///|
/// Returns all components of a specific ComponentType.
pub fn SbomDocument::filter_by_type(
  self : SbomDocument,
  ctype : ComponentType,
) -> Array[Component] {
  let result = []
  for comp in self.components {
    if comp.component_type == ctype {
      result.push(comp)
    }
  }
  result
}

///|
/// Returns total count of components in document.
pub fn SbomDocument::component_count(self : SbomDocument) -> Int {
  self.components.length()
}

///|
/// Checks if the document contains any critical/high security vulnerabilities.
pub fn SbomDocument::has_high_vulnerabilities(self : SbomDocument) -> Bool {
  for v in self.vulnerabilities {
    if v.is_critical_or_high() {
      return true
    }
  }
  false
}
