///|
/// Pre-configured hardware target profile presets for common microcontrollers.
pub fn get_hardware_preset(name : String) -> EmbeddedInfo {
  let lower = name.to_lower()
  if lower.contains("stm32f4") || lower.contains("stm32f407") {
    EmbeddedInfo::new(
      mcu_arch="arm-cortex-m4",
      firmware_version="1.0.0",
      build_target="thumbv7em-none-eabihf",
      bootloader_version="MCUBoot v2.0",
      board_model="STM32F407ZG-DISC",
      binary_hash="",
      flash_size_kb=1024,
      ram_size_kb=192,
      toolchain_version="arm-none-eabi-gcc 12.3.0",
    )
  } else if lower.contains("esp32") || lower.contains("esp32s3") {
    EmbeddedInfo::new(
      mcu_arch="xtensa-lx7",
      firmware_version="1.0.0",
      build_target="xtensa-esp32s3-espidf",
      bootloader_version="ESP-IDF Bootloader v5.1",
      board_model="ESP32-S3-DevKitC-1",
      binary_hash="",
      flash_size_kb=8192,
      ram_size_kb=512,
      toolchain_version="xtensa-esp32-elf-gcc 12.2.0",
    )
  } else if lower.contains("pico") ||
    lower.contains("rp2040") ||
    lower.contains("rp2350") {
    EmbeddedInfo::new(
      mcu_arch="arm-cortex-m0plus",
      firmware_version="1.0.0",
      build_target="thumbv6m-none-eabi",
      bootloader_version="Pico Boot ROM v2.0",
      board_model="Raspberry-Pi-Pico-2",
      binary_hash="",
      flash_size_kb=4096,
      ram_size_kb=520,
      toolchain_version="arm-none-eabi-gcc 13.2.0",
    )
  } else if lower.contains("riscv") || lower.contains("ch32v307") {
    EmbeddedInfo::new(
      mcu_arch="riscv32-rv32imafc",
      firmware_version="1.0.0",
      build_target="riscv32-unknown-elf",
      bootloader_version="WCH Bootloader",
      board_model="CH32V307-EVT-BOARD",
      binary_hash="",
      flash_size_kb=288,
      ram_size_kb=64,
      toolchain_version="riscv-none-embed-gcc 12.2.0",
    )
  } else {
    EmbeddedInfo::new()
  }
}
