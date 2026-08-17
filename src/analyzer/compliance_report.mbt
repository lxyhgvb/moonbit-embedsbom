///|
/// AuditReport contains full compliance and security audit summary.
pub(all) struct AuditReport {
  document_id : String
  document_name : String
  embedded_info : @types.EmbeddedInfo
  license_issues : Array[LicenseIssue]
  version_issues : Array[VersionIssue]
  vulnerabilities : Array[VulnerabilityMatch]
  cycles : Array[Array[String]]
  duplicate_packages : Map[String, Array[String]]
  is_compliant : Bool
} derive(Eq, Debug)

///|
/// Conducts full comprehensive audit of an SbomDocument.
pub fn run_full_audit(
  doc : @types.SbomDocument,
  vuln_db? : Array[@types.Vulnerability] = [],
) -> AuditReport {
  let lic_issues = analyze_licenses(doc)
  let ver_issues = lint_versions(doc)
  let vulns = match_vulnerabilities(doc, vuln_db)

  let graph = @graph.DependencyGraph::from_document(doc)
  let detector = @graph.CycleDetector::new(graph)
  let cycles = detector.detect_cycles()
  let summary = @graph.compute_graph_summary(graph)

  let compliant = lic_issues.length() == 0 &&
    cycles.length() == 0 &&
    vulns.length() == 0

  {
    document_id: doc.id,
    document_name: doc.name,
    embedded_info: doc.embedded_info,
    license_issues: lic_issues,
    version_issues: ver_issues,
    vulnerabilities: vulns,
    cycles,
    duplicate_packages: summary.duplicate_packages,
    is_compliant: compliant,
  }
}
