///|
test "license_compatibility_checks" {
  let ok = is_license_compatible(
    @types.LicenseCategory::Permissive,
    @types.LicenseCategory::Permissive,
  )
  assert_true(ok)
  let bad = is_license_compatible(
    @types.LicenseCategory::Proprietary,
    @types.LicenseCategory::StrongCopyleft,
  )
  assert_false(bad)
}

///|
test "full_audit_execution" {
  let doc = @types.SbomDocument::new(name="Audit Test")
  let comp1 = @types.Component::new(
    name="app",
    version="v1.0.0",
    license_id="Proprietary",
  )
  let comp2 = @types.Component::new(
    name="gpl-lib",
    version="2.0",
    license_id="GPL-3.0",
  )
  let comp3 = @types.Component::new(
    name="no-lic",
    version="0.0.0",
    license_id="NONE",
  )

  doc.add_component(comp1)
  doc.add_component(comp2)
  doc.add_component(comp3)
  doc.add_relation("app@v1.0.0", "gpl-lib@2.0")

  let report = run_full_audit(doc)
  assert_false(report.is_compliant)
  assert_true(report.license_issues.length() >= 1)
  assert_true(report.version_issues.length() >= 1)
}
