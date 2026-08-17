///|
/// LicensePolicyRule defines explicit license governance rules (Allow, Deny, RequireReview).
pub(all) enum LicensePolicyAction {
  Allow
  Deny
  RequireReview
} derive(Eq, Debug)

///|
/// LicensePolicyRule specifies a rule entry for a license ID or category.
pub(all) struct LicensePolicyRule {
  target : String
  action : LicensePolicyAction
  reason : String
} derive(Eq, Debug)

///|
/// LicensePolicyEngine manages corporate and open source governance policies.
pub(all) struct LicensePolicyEngine {
  allowed_licenses : Array[String]
  denied_licenses : Array[String]
  rules : Array[LicensePolicyRule]
} derive(Eq, Debug)

///|
/// Creates a default strict embedded commercial LicensePolicyEngine.
pub fn LicensePolicyEngine::new_strict_embedded_policy() -> LicensePolicyEngine {
  {
    allowed_licenses: [
      "MIT", "Apache-2.0", "BSD-3-Clause", "BSD-2-Clause", "ISC", "CC0-1.0",
    ],
    denied_licenses: [
      "GPL-3.0", "GPL-3.0-only", "AGPL-3.0", "AGPL-3.0-only", "SSPL-1.0",
    ],
    rules: [
      {
        target: "LGPL-2.1",
        action: RequireReview,
        reason: "Dynamic linking requirement must be verified on MCU",
      },
      {
        target: "LGPL-3.0",
        action: RequireReview,
        reason: "Anti-tivoization clause check required for hardware",
      },
      {
        target: "MPL-2.0",
        action: Allow,
        reason: "Weak copyleft files must remain separate",
      },
    ],
  }
}

///|
/// Evaluates a single component license against the policy engine.
pub fn LicensePolicyEngine::evaluate_component(
  self : LicensePolicyEngine,
  comp : @types.Component,
) -> (LicensePolicyAction, String) {
  let lic = comp.license_id.trim().to_owned().to_upper()

  for denied in self.denied_licenses {
    if lic == denied.to_upper() {
      return (
        Deny,
        "License " + comp.license_id + " is explicitly blacklisted in policy",
      )
    }
  }

  for rule in self.rules {
    if lic == rule.target.to_upper() {
      return (rule.action, rule.reason)
    }
  }

  for allowed in self.allowed_licenses {
    if lic == allowed.to_upper() {
      return (Allow, "License " + comp.license_id + " is in approved whitelist")
    }
  }

  (
    RequireReview,
    "Unlisted license " + comp.license_id + " requires manual legal review",
  )
}

///|
/// Audits full SbomDocument against policy engine rules.
pub fn LicensePolicyEngine::audit_document(
  self : LicensePolicyEngine,
  doc : @types.SbomDocument,
) -> Array[LicenseIssue] {
  let issues : Array[LicenseIssue] = []
  for comp in doc.components {
    let (action, reason) = self.evaluate_component(comp)
    if action == Deny {
      issues.push({
        component_id: comp.id,
        license_id: comp.license_id,
        category: @types.classify_spdx_license(comp.license_id),
        issue_type: "POLICY_VIOLATION_DENIED",
        description: "Component " + comp.name + ": " + reason,
      })
    } else if action == RequireReview {
      issues.push({
        component_id: comp.id,
        license_id: comp.license_id,
        category: @types.classify_spdx_license(comp.license_id),
        issue_type: "POLICY_REQUIRE_REVIEW",
        description: "Component " + comp.name + ": " + reason,
      })
    }
  }
  issues
}
