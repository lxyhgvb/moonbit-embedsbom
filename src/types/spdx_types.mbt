///|
/// SpdxCreatorType specifies creator entity types in SPDX 2.3 documents.
pub(all) enum SpdxCreatorType {
  Person
  Organization
  Tool
} derive(Eq, Debug)

///|
/// SpdxCreator describes document author or generator tool information.
pub(all) struct SpdxCreator {
  creator_type : SpdxCreatorType
  name : String
  email : String
} derive(Eq, Debug)

///|
/// Creates a new SpdxCreator instance.
pub fn SpdxCreator::new(
  creator_type? : SpdxCreatorType = Tool,
  name? : String = "MoonBit embedsbom",
  email? : String = "",
) -> SpdxCreator {
  { creator_type, name, email }
}

///|
/// Formats SpdxCreator into standard SPDX string representation (e.g. "Tool: embedsbom").
pub fn SpdxCreator::to_spdx_string(self : SpdxCreator) -> String {
  let prefix = match self.creator_type {
    Person => "Person: "
    Organization => "Organization: "
    Tool => "Tool: "
  }
  let email_str = if self.email != "" { " (" + self.email + ")" } else { "" }
  prefix + self.name + email_str
}

///|
/// SpdxExternalRef specifies reference to external databases (e.g., PURL, CPE, NVD).
pub(all) struct SpdxExternalRef {
  category : String
  ref_type : String
  locator : String
  comment : String
} derive(Eq, Debug)

///|
/// Creates a new SpdxExternalRef structure.
pub fn SpdxExternalRef::new(
  category? : String = "PACKAGE-MANAGER",
  ref_type? : String = "purl",
  locator~ : String,
  comment? : String = "",
) -> SpdxExternalRef {
  { category, ref_type, locator, comment }
}

///|
/// SpdxAnnotation allows adding reviewer comments or timestamps to SPDX items.
pub(all) struct SpdxAnnotation {
  annotator : String
  date : String
  annotation_type : String
  comment : String
} derive(Eq, Debug)

///|
/// Creates a new SpdxAnnotation.
pub fn SpdxAnnotation::new(
  annotator? : String = "Security Auditor",
  date? : String = "2026-08-17T00:00:00Z",
  annotation_type? : String = "REVIEW",
  comment? : String = "Verified embedded firmware checksum",
) -> SpdxAnnotation {
  { annotator, date, annotation_type, comment }
}

///|
/// SpdxFile represents an individual source code or binary file in SPDX 2.3.
pub(all) struct SpdxFile {
  spdx_id : String
  file_name : String
  file_types : Array[String]
  checksums : Map[String, String]
  license_concluded : String
  license_info_in_files : Array[String]
  copyright_text : String
  comment : String
} derive(Eq, Debug)

///|
/// Creates a new SpdxFile descriptor.
pub fn SpdxFile::new(
  spdx_id~ : String,
  file_name~ : String,
  file_types? : Array[String] = ["BINARY"],
  license_concluded? : String = "MIT",
  copyright_text? : String = "Copyright (c) 2026",
  comment? : String = "",
) -> SpdxFile {
  {
    spdx_id,
    file_name,
    file_types,
    checksums: Map::from_array([]),
    license_concluded,
    license_info_in_files: [license_concluded],
    copyright_text,
    comment,
  }
}

///|
/// SpdxSnippet represents a code snippet extracted from a larger file.
pub(all) struct SpdxSnippet {
  snippet_id : String
  snippet_from_file_id : String
  byte_range : (Int, Int)
  line_range : (Int, Int)
  license_concluded : String
  copyright_text : String
} derive(Eq, Debug)

///|
/// Creates a new SpdxSnippet.
pub fn SpdxSnippet::new(
  snippet_id~ : String,
  snippet_from_file_id~ : String,
  start_byte? : Int = 0,
  end_byte? : Int = 1024,
  start_line? : Int = 1,
  end_line? : Int = 50,
  license_concluded? : String = "MIT",
  copyright_text? : String = "Copyright (c) 2026",
) -> SpdxSnippet {
  {
    snippet_id,
    snippet_from_file_id,
    byte_range: (start_byte, end_byte),
    line_range: (start_line, end_line),
    license_concluded,
    copyright_text,
  }
}
