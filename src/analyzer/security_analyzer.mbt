///|
/// VulnerabilityMatch links a vulnerability to a specific document component.
pub(all) struct VulnerabilityMatch {
  component_id : String
  component_name : String
  vulnerability : @types.Vulnerability
} derive(Eq, Debug)

///|
/// Matches document components against a provided list of CVE security advisories.
pub fn match_vulnerabilities(
  doc : @types.SbomDocument,
  db : Array[@types.Vulnerability],
) -> Array[VulnerabilityMatch] {
  let matches : Array[VulnerabilityMatch] = []

  for comp in doc.components {
    for vuln in db {
      let aff = vuln.affected_component.to_lower()
      let cname = comp.name.to_lower()
      if aff == cname || aff == "*" || cname.contains(aff) {
        matches.push({
          component_id: comp.id,
          component_name: comp.name,
          vulnerability: vuln,
        })
      }
    }
  }

  matches
}
