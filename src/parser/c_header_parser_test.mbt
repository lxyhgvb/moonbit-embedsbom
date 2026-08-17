///|
test "parse_c_header_macros" {
  let header_text =
    #|#ifndef VERSION_H
    #|#define VERSION_H
    #|#define FIRMWARE_VERSION "2.5.0"
    #|#define BUILD_NUMBER 1042
    #|#endif

  let macros = parse_c_header_macros(header_text)
  assert_true(macros.length() >= 2)
  let ver = extract_version_from_c_header(macros)
  assert_eq(ver, "2.5.0")
}
