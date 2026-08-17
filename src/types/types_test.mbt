///|
test "component_type_conversion" {
  let fw = ComponentType::Firmware
  let drv = ComponentType::Driver
  let rtos = ComponentType::RtosKernel
  assert_eq(fw.to_string(), "firmware")
  assert_eq(drv.to_string(), "driver")
  assert_eq(rtos.to_string(), "rtos-kernel")
  assert_eq(ComponentType::from_string("firmware"), ComponentType::Firmware)
  assert_eq(ComponentType::from_string("rtos"), ComponentType::RtosKernel)
  assert_eq(ComponentType::from_string("bsp"), ComponentType::HardwareBsp)
}

///|
test "embedded_info_calculations" {
  let info = EmbeddedInfo::new(
    mcu_arch="cortex-m4",
    board_model="STM32F407",
    flash_size_kb=1024,
    ram_size_kb=192,
  )
  assert_true(info.is_arm_arch())
  assert_false(info.is_riscv_arch())
  assert_false(info.is_esp32_arch())
  let util = info.calc_flash_utilization(512 * 1024)
  assert_eq(util, 0.5)
}

///|
test "license_classification" {
  assert_eq(classify_spdx_license("MIT"), LicenseCategory::Permissive)
  assert_eq(classify_spdx_license("Apache-2.0"), LicenseCategory::Permissive)
  assert_eq(classify_spdx_license("GPL-3.0"), LicenseCategory::StrongCopyleft)
  assert_eq(classify_spdx_license("LGPL-3.0"), LicenseCategory::WeakCopyleft)
  assert_eq(classify_spdx_license("Proprietary"), LicenseCategory::Proprietary)

  let mit_info = resolve_license_info("MIT")
  assert_eq(mit_info.spdx_id, "MIT")
  assert_true(mit_info.is_approved)
}

///|
test "sbom_document_operations" {
  let doc = SbomDocument::new(name="Test Firmware")
  let comp1 = Component::new(
    name="stm32-hal",
    version="1.2.0",
    component_type=ComponentType::Driver,
  )
  let comp2 = Component::new(
    name="freertos-kernel",
    version="10.4.0",
    component_type=ComponentType::RtosKernel,
  )
  doc.add_component(comp1)
  doc.add_component(comp2)
  doc.add_relation("stm32-hal@1.2.0", "freertos-kernel@10.4.0")

  assert_eq(doc.component_count(), 2)
  let drivers = doc.filter_by_type(ComponentType::Driver)
  assert_eq(drivers.length(), 1)
  assert_eq(drivers[0].name, "stm32-hal")

  let found = doc.find_component_by_id("stm32-hal@1.2.0")
  assert_true(found is Some(_))
}
