///|
test "parse_moon_mod_content" {
  let text =
    #|name = "lxyhgvb/moonbit-embedsbom"
    #|version = "0.1.0"
    #|license = "Apache-2.0"
    #|description = "Embedded SBOM Tool"
    #|repository = "https://github.com/lxyhgvb/moonbit-embedsbom"

  let parsed = parse_moon_mod_content(text)
  assert_eq(parsed.name, "lxyhgvb/moonbit-embedsbom")
  assert_eq(parsed.version, "0.1.0")
  assert_eq(parsed.license_id, "Apache-2.0")
  let comp = parsed.to_component()
  assert_eq(comp.name, "lxyhgvb/moonbit-embedsbom")
}

///|
test "parse_moon_pkg_content" {
  let text =
    #|import {
    #|  "moonbitlang/x@0.4.6" @x,
    #|}
    #|pkgtype(kind: "executable")

  let parsed = parse_moon_pkg_content(text, pkg_name="main")
  assert_true(parsed.is_executable)
  assert_eq(parsed.imports.length(), 1)
  assert_eq(parsed.imports[0], "moonbitlang/x@0.4.6")
}

///|
test "parse_moon_lock_content" {
  let text =
    #|[moonbitlang/x]
    #|version = "0.4.6"
    #|checksum = "abc123hash"
    #|source = "mooncakes.io"

  let pkgs = parse_moon_lock_content(text)
  assert_eq(pkgs.length(), 1)
  assert_eq(pkgs[0].name, "moonbitlang/x")
  assert_eq(pkgs[0].version, "0.4.6")
}

///|
test "parse_embedded_manifest" {
  let csv_text =
    #|# Embedded components inventory
    #|stm32-hal, 1.4.0, driver, BSD-3-Clause, STMicroelectronics, STM32F4
    #|freertos-kernel, 10.4.6, rtos, MIT, Amazon Web Services, FreeRTOS
    #|mcuboot, 2.0.0, bootloader, Apache-2.0, MCUboot Project, MCUBoot

  let entries = parse_embedded_manifest(csv_text)
  assert_eq(entries.length(), 3)
  assert_eq(entries[0].name, "stm32-hal")
  assert_eq(entries[1].name, "freertos-kernel")
  assert_eq(entries[2].name, "mcuboot")
}

///|
test "parse_firmware_spec" {
  let spec_text =
    #|arch = "cortex-m4"
    #|board = "STM32F407G-DISC1"
    #|version = "2.1.0"
    #|target = "thumbv7em-none-eabihf"
    #|bootloader = "1.2.0"
    #|flash = "1024"
    #|ram = "256"

  let info = parse_firmware_spec(spec_text)
  assert_eq(info.mcu_arch, "cortex-m4")
  assert_eq(info.board_model, "STM32F407G-DISC1")
  assert_eq(info.firmware_version, "2.1.0")
  assert_eq(info.flash_size_kb, 1024)
}
