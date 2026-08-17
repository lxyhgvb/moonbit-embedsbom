///|
/// VersionIssue describes a component version formatting or compatibility problem.
pub(all) struct VersionIssue {
  component_id : String
  version : String
  issue_type : String
  description : String
} derive(Eq, Debug)

///|
/// Audits version quality and semver rules across document components.
pub fn lint_versions(doc : @types.SbomDocument) -> Array[VersionIssue] {
  let issues : Array[VersionIssue] = []

  for comp in doc.components {
    if !comp.has_valid_version() {
      issues.push({
        component_id: comp.id,
        version: comp.version,
        issue_type: "INVALID_VERSION",
        description: "Component " +
        comp.name +
        " has missing or placeholder version: '" +
        comp.version +
        "'",
      })
    } else {
      let v = comp.version.trim().to_owned()
      if v.has_prefix("v") || v.has_prefix("V") {
        issues.push({
          component_id: comp.id,
          version: comp.version,
          issue_type: "NON_CANONICAL_SEMVER",
          description: "Component " +
          comp.name +
          " version starts with 'v' prefix: " +
          comp.version,
        })
      }
    }
  }

  issues
}
