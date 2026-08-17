///|
/// Generates JSON Schema representation for SPDX 2.3 embedded documents.
pub fn generate_spdx_json_schema() -> String {
  let schema = @utils.jobject([
    ("$schema", @utils.jstr("http://json-schema.org/draft-07/schema#")),
    ("title", @utils.jstr("SPDX 2.3 Embedded Schema")),
    ("type", @utils.jstr("object")),
    (
      "required",
      @utils.jarray([
        @utils.jstr("spdxVersion"),
        @utils.jstr("dataLicense"),
        @utils.jstr("SPDXID"),
        @utils.jstr("name"),
        @utils.jstr("packages"),
      ]),
    ),
    (
      "properties",
      @utils.jobject([
        ("spdxVersion", @utils.jobject([("type", @utils.jstr("string"))])),
        ("dataLicense", @utils.jobject([("type", @utils.jstr("string"))])),
        ("SPDXID", @utils.jobject([("type", @utils.jstr("string"))])),
        ("name", @utils.jobject([("type", @utils.jstr("string"))])),
        ("packages", @utils.jobject([("type", @utils.jstr("array"))])),
        ("relationships", @utils.jobject([("type", @utils.jstr("array"))])),
        ("embeddedMetadata", @utils.jobject([("type", @utils.jstr("object"))])),
      ]),
    ),
  ])
  schema.stringify(pretty=true)
}

///|
/// Generates JSON Schema representation for CycloneDX 1.5 documents.
pub fn generate_cyclonedx_json_schema() -> String {
  let schema = @utils.jobject([
    ("$schema", @utils.jstr("http://json-schema.org/draft-07/schema#")),
    ("title", @utils.jstr("CycloneDX 1.5 Embedded Schema")),
    ("type", @utils.jstr("object")),
    (
      "required",
      @utils.jarray([
        @utils.jstr("bomFormat"),
        @utils.jstr("specVersion"),
        @utils.jstr("version"),
        @utils.jstr("components"),
      ]),
    ),
    (
      "properties",
      @utils.jobject([
        ("bomFormat", @utils.jobject([("type", @utils.jstr("string"))])),
        ("specVersion", @utils.jobject([("type", @utils.jstr("string"))])),
        ("version", @utils.jobject([("type", @utils.jstr("number"))])),
        ("components", @utils.jobject([("type", @utils.jstr("array"))])),
        ("dependencies", @utils.jobject([("type", @utils.jstr("array"))])),
      ]),
    ),
  ])
  schema.stringify(pretty=true)
}
