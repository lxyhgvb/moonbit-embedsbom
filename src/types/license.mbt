///|
/// LicenseInfo provides structured license classification according to SPDX registry rules.
pub(all) struct LicenseInfo {
  spdx_id : String
  name : String
  category : LicenseCategory
  is_approved : Bool
  url : String
  notes : String
} derive(Eq, Debug)

///|
/// Creates a new LicenseInfo structure.
pub fn LicenseInfo::new(
  spdx_id~ : String,
  name? : String = "",
  category? : LicenseCategory = LicenseCategory::Unknown,
  is_approved? : Bool = true,
  url? : String = "",
  notes? : String = "",
) -> LicenseInfo {
  let final_name = if name == "" { spdx_id } else { name }
  { spdx_id, name: final_name, category, is_approved, url, notes }
}

///|
/// Helper to classify license identifier strings into standard license categories.
pub fn classify_spdx_license(id : String) -> LicenseCategory {
  let clean = id.to_upper().trim().to_owned()
  if clean == "MIT" ||
    clean == "APACHE-2.0" ||
    clean.has_prefix("BSD") ||
    clean == "ISC" ||
    clean == "CC0-1.0" ||
    clean == "UNLICENSE" {
    Permissive
  } else if clean == "LGPL-2.1" ||
    clean == "LGPL-3.0" ||
    clean == "MPL-2.0" ||
    clean == "EPL-2.0" {
    WeakCopyleft
  } else if clean.has_prefix("GPL") || clean.has_prefix("AGPL") {
    StrongCopyleft
  } else if clean == "PROPRIETARY" || clean == "COMMERCIAL" {
    Proprietary
  } else if clean == "" || clean == "NONE" || clean == "NOASSERTION" {
    Unknown
  } else {
    Permissive
  }
}

///|
/// Resolves a full LicenseInfo descriptor from an SPDX short ID string.
pub fn resolve_license_info(spdx_id : String) -> LicenseInfo {
  let clean_id = spdx_id.trim().to_owned()
  let upper = clean_id.to_upper()
  if upper == "MIT" {
    {
      spdx_id: "MIT",
      name: "MIT License",
      category: Permissive,
      is_approved: true,
      url: "https://spdx.org/licenses/MIT.html",
      notes: "Permissive free software license",
    }
  } else if upper == "APACHE-2.0" {
    {
      spdx_id: "Apache-2.0",
      name: "Apache License 2.0",
      category: Permissive,
      is_approved: true,
      url: "https://spdx.org/licenses/Apache-2.0.html",
      notes: "Permissive license with explicit patent grant",
    }
  } else if upper.has_prefix("BSD-3-CLAUSE") {
    {
      spdx_id: "BSD-3-Clause",
      name: "BSD 3-Clause Clear License",
      category: Permissive,
      is_approved: true,
      url: "https://spdx.org/licenses/BSD-3-Clause.html",
      notes: "Permissive license with non-endorsement clause",
    }
  } else if upper.has_prefix("GPL-3.0") {
    {
      spdx_id: "GPL-3.0-only",
      name: "GNU General Public License v3.0",
      category: StrongCopyleft,
      is_approved: true,
      url: "https://spdx.org/licenses/GPL-3.0-only.html",
      notes: "Strong copyleft license requiring source disclosure",
    }
  } else if upper.has_prefix("GPL-2.0") {
    {
      spdx_id: "GPL-2.0-only",
      name: "GNU General Public License v2.0",
      category: StrongCopyleft,
      is_approved: true,
      url: "https://spdx.org/licenses/GPL-2.0-only.html",
      notes: "Strong copyleft license popular in Linux kernel and drivers",
    }
  } else if upper.has_prefix("LGPL-3.0") {
    {
      spdx_id: "LGPL-3.0-only",
      name: "GNU Lesser General Public License v3.0",
      category: WeakCopyleft,
      is_approved: true,
      url: "https://spdx.org/licenses/LGPL-3.0-only.html",
      notes: "Weak copyleft library license",
    }
  } else if upper == "PROPRIETARY" {
    {
      spdx_id: "Proprietary",
      name: "Proprietary Commercial Firmware License",
      category: Proprietary,
      is_approved: false,
      url: "",
      notes: "Closed-source commercial embedded firmware license",
    }
  } else {
    let cat = classify_spdx_license(clean_id)
    {
      spdx_id: clean_id,
      name: clean_id,
      category: cat,
      is_approved: cat != Unknown && cat != Proprietary,
      url: "",
      notes: "Generic license entry",
    }
  }
}
