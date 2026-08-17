///|
/// LicenseIssue describes a license compliance violation or warning.
pub(all) struct LicenseIssue {
  component_id : String
  license_id : String
  category : @types.LicenseCategory
  issue_type : String
  description : String
} derive(Eq, Debug)

///|
/// Evaluates license compatibility between parent license and child dependency license.
pub fn is_license_compatible(
  parent_cat : @types.LicenseCategory,
  child_cat : @types.LicenseCategory,
) -> Bool {
  match (parent_cat, child_cat) {
    (Proprietary, StrongCopyleft) => false
    (Commercial, StrongCopyleft) => false
    (Permissive, StrongCopyleft) => false
    (WeakCopyleft, StrongCopyleft) => false
    (Proprietary, WeakCopyleft) => false
    _ => true
  }
}

///|
/// Audits license compliance across all components and relationships in SbomDocument.
pub fn analyze_licenses(doc : @types.SbomDocument) -> Array[LicenseIssue] {
  let issues : Array[LicenseIssue] = []

  // 1. Check individual component licenses
  for comp in doc.components {
    if !comp.has_license() {
      issues.push({
        component_id: comp.id,
        license_id: "MISSING",
        category: @types.LicenseCategory::Unknown,
        issue_type: "UNLICENSED_COMPONENT",
        description: "Component " + comp.name + " does not specify a license",
      })
    } else {
      let info = @types.resolve_license_info(comp.license_id)
      if info.category == @types.LicenseCategory::Unknown {
        issues.push({
          component_id: comp.id,
          license_id: comp.license_id,
          category: @types.LicenseCategory::Unknown,
          issue_type: "UNKNOWN_LICENSE",
          description: "License " +
          comp.license_id +
          " is not recognized in SPDX registry",
        })
      }
    }
  }

  // 2. Check dependency edge license compatibility
  let graph = @graph.DependencyGraph::from_document(doc)
  for parent_id, parent_comp in graph.nodes {
    let parent_lic = @types.resolve_license_info(parent_comp.license_id)
    let deps = graph.get_direct_dependencies(parent_id)

    for child_id in deps {
      match graph.get_node(child_id) {
        Some(child_comp) => {
          let child_lic = @types.resolve_license_info(child_comp.license_id)
          if !is_license_compatible(parent_lic.category, child_lic.category) {
            issues.push({
              component_id: parent_id,
              license_id: parent_comp.license_id,
              category: parent_lic.category,
              issue_type: "LICENSE_INCOMPATIBILITY",
              description: "Parent component " +
              parent_comp.name +
              " (" +
              parent_lic.spdx_id +
              ") depends on incompatible child " +
              child_comp.name +
              " (" +
              child_lic.spdx_id +
              ")",
            })
          }
        }
        None => ()
      }
    }
  }

  issues
}
