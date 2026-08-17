///|
test "spdx_creator_and_external_ref" {
  let creator = SpdxCreator::new(
    creator_type=Organization,
    name="CCF MoonBit Team",
    email="info@moonbitlang.cn",
  )
  assert_eq(
    creator.to_spdx_string(),
    "Organization: CCF MoonBit Team (info@moonbitlang.cn)",
  )

  let ext_ref = SpdxExternalRef::new(locator="pkg:generic/stm32-hal@1.4.0")
  assert_eq(ext_ref.locator, "pkg:generic/stm32-hal@1.4.0")

  let file_entry = SpdxFile::new(
    spdx_id="SPDXRef-File-main",
    file_name="main.c",
  )
  assert_eq(file_entry.file_name, "main.c")
}

///|
test "hardware_catalog_lookup" {
  let catalog = get_hardware_board_catalog()
  assert_true(catalog.length() >= 10)

  let found_stm32 = find_hardware_spec("STM32F407")
  assert_true(found_stm32 is Some(_))
  match found_stm32 {
    Some(spec) => assert_eq(spec.vendor, "STMicroelectronics")
    None => ()
  }
}
