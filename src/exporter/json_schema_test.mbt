///|
test "json_schema_generation" {
  let spdx_schema = generate_spdx_json_schema()
  assert_true(spdx_schema.contains("SPDX 2.3 Embedded Schema"))

  let cd_schema = generate_cyclonedx_json_schema()
  assert_true(cd_schema.contains("CycloneDX 1.5 Embedded Schema"))
}
