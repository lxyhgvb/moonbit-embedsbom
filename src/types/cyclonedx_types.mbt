///|
/// CycloneDxOrganizationalEntity describes vendor or contact organization.
pub(all) struct CycloneDxOrganizationalEntity {
  name : String
  url : Array[String]
  contact_name : String
  contact_email : String
} derive(Eq, Debug)

///|
/// Creates a CycloneDxOrganizationalEntity instance.
pub fn CycloneDxOrganizationalEntity::new(
  name~ : String,
  url? : Array[String] = [],
  contact_name? : String = "",
  contact_email? : String = "",
) -> CycloneDxOrganizationalEntity {
  { name, url, contact_name, contact_email }
}

///|
/// CycloneDxHash describes a single cryptographic hash entry in CycloneDX.
pub(all) struct CycloneDxHash {
  alg : String
  content : String
} derive(Eq, Debug)

///|
/// Creates a CycloneDxHash instance.
pub fn CycloneDxHash::new(alg~ : String, content~ : String) -> CycloneDxHash {
  { alg, content }
}

///|
/// CycloneDxService describes an external service or network API used by the embedded system.
pub(all) struct CycloneDxService {
  bom_ref : String
  name : String
  version : String
  endpoints : Array[String]
  authenticated : Bool
  x_trust_boundary : Bool
} derive(Eq, Debug)

///|
/// Creates a CycloneDxService instance.
pub fn CycloneDxService::new(
  bom_ref~ : String,
  name~ : String,
  version? : String = "1.0.0",
  endpoints? : Array[String] = [],
  authenticated? : Bool = true,
  x_trust_boundary? : Bool = false,
) -> CycloneDxService {
  { bom_ref, name, version, endpoints, authenticated, x_trust_boundary }
}

///|
/// CycloneDxPedigree describes source code commits and patch histories for components.
pub(all) struct CycloneDxPedigree {
  ancestors : Array[String]
  descendants : Array[String]
  commits : Array[String]
  patches : Array[String]
  notes : String
} derive(Eq, Debug)

///|
/// Creates a CycloneDxPedigree instance.
pub fn CycloneDxPedigree::new(
  ancestors? : Array[String] = [],
  descendants? : Array[String] = [],
  commits? : Array[String] = [],
  patches? : Array[String] = [],
  notes? : String = "",
) -> CycloneDxPedigree {
  { ancestors, descendants, commits, patches, notes }
}

///|
/// CycloneDxEvidence provides license or copyright evidence verification details.
pub(all) struct CycloneDxEvidence {
  licenses : Array[String]
  copyright_text : String
} derive(Eq, Debug)

///|
/// Creates a CycloneDxEvidence instance.
pub fn CycloneDxEvidence::new(
  licenses? : Array[String] = [],
  copyright_text? : String = "",
) -> CycloneDxEvidence {
  { licenses, copyright_text }
}
