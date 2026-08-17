///|
/// Validates SPDX 2.3 JSON string for required fields and schema constraints.
pub fn validate_spdx_json_spec(json_str : String) -> Array[String] {
  let errors : Array[String] = []

  if !json_str.contains("\"spdxVersion\":\"SPDX-2.3\"") &&
    !json_str.contains("\"spdxVersion\": \"SPDX-2.3\"") {
    errors.push("Missing or invalid spdxVersion field (expected 'SPDX-2.3')")
  }
  if !json_str.contains("\"dataLicense\":\"CC0-1.0\"") &&
    !json_str.contains("\"dataLicense\": \"CC0-1.0\"") {
    errors.push("Missing dataLicense field (expected 'CC0-1.0')")
  }
  if !json_str.contains("\"SPDXID\":\"SPDXRef-DOCUMENT\"") &&
    !json_str.contains("\"SPDXID\": \"SPDXRef-DOCUMENT\"") {
    errors.push("Missing document SPDXID field")
  }
  if !json_str.contains("\"packages\"") {
    errors.push("Missing packages array in SPDX document")
  }

  errors
}

///|
/// Validates CycloneDX 1.5 JSON string for required fields and schema constraints.
pub fn validate_cyclonedx_json_spec(json_str : String) -> Array[String] {
  let errors : Array[String] = []

  if !json_str.contains("\"bomFormat\":\"CycloneDX\"") &&
    !json_str.contains("\"bomFormat\": \"CycloneDX\"") {
    errors.push("Missing or invalid bomFormat field (expected 'CycloneDX')")
  }
  if !json_str.contains("\"specVersion\":\"1.5\"") &&
    !json_str.contains("\"specVersion\": \"1.5\"") {
    errors.push("Missing specVersion field (expected '1.5')")
  }
  if !json_str.contains("\"components\"") {
    errors.push("Missing components array in CycloneDX document")
  }

  errors
}
