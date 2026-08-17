///|
test "license_policy_engine_audit" {
  let engine = LicensePolicyEngine::new_strict_embedded_policy()
  let doc = @types.SbomDocument::new(name="Policy Test")

  let ok_comp = @types.Component::new(
    name="mit-lib",
    version="1.0",
    license_id="MIT",
  )
  let gpl_comp = @types.Component::new(
    name="gpl-driver",
    version="2.0",
    license_id="GPL-3.0",
  )

  doc.add_component(ok_comp)
  doc.add_component(gpl_comp)

  let issues = engine.audit_document(doc)
  assert_eq(issues.length(), 1)
  assert_eq(issues[0].issue_type, "POLICY_VIOLATION_DENIED")
}
