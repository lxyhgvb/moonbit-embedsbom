///|
test "json_ast_serialization" {
  let obj = jobject([
    ("name", jstr("embedsbom")),
    ("version", jstr("1.0.0")),
    ("enabled", jbool(true)),
    ("count", jnum(42.0)),
    ("null_val", jnull()),
    ("tags", jarray([jstr("mcu"), jstr("spdx")])),
  ])
  let minified = obj.stringify(pretty=false)
  assert_true(minified.contains("\"name\":\"embedsbom\""))
  assert_true(minified.contains("\"enabled\":true"))
  assert_true(minified.contains("\"count\":42"))

  let pretty = obj.stringify(pretty=true)
  assert_true(pretty.contains("\n"))
}

///|
test "string_utilities" {
  assert_eq(pad_right("abc", 6), "abc   ")
  assert_eq(pad_left("abc", 6), "   abc")
  assert_eq(truncate_string("hello world", 8), "hello...")
  assert_eq(slugify_component_name("STM32 / HAL Driver"), "stm32---hal-driver")
  assert_eq(extract_basename("a/b/c/moon.mod"), "moon.mod")
}

///|
test "crc32_and_checksum_computation" {
  let crc = compute_crc32("hello moonbit")
  assert_eq(crc.length(), 8)
  let sha = compute_checksum("firmware_binary_data", "sha256")
  assert_eq(sha.length(), 64)
}
