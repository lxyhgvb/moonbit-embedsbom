///|
/// EmbeddedInfo encapsulates metadata specific to microcontrollers, solid hardware, and binary targets.
pub(all) struct EmbeddedInfo {
  mcu_arch : String
  firmware_version : String
  build_target : String
  bootloader_version : String
  board_model : String
  binary_hash : String
  flash_size_kb : Int
  ram_size_kb : Int
  toolchain_version : String
} derive(Eq, Debug)

///|
/// Default constructor for EmbeddedInfo.
pub fn EmbeddedInfo::new(
  mcu_arch? : String = "arm-cortex-m4",
  firmware_version? : String = "1.0.0",
  build_target? : String = "thumbv7em-none-eabihf",
  bootloader_version? : String = "0.5.0",
  board_model? : String = "generic-mcu-board",
  binary_hash? : String = "",
  flash_size_kb? : Int = 512,
  ram_size_kb? : Int = 128,
  toolchain_version? : String = "arm-none-eabi-gcc 12.3.0",
) -> EmbeddedInfo {
  {
    mcu_arch,
    firmware_version,
    build_target,
    bootloader_version,
    board_model,
    binary_hash,
    flash_size_kb,
    ram_size_kb,
    toolchain_version,
  }
}

///|
/// Checks if the microcontroller architecture is ARM-based.
pub fn EmbeddedInfo::is_arm_arch(self : EmbeddedInfo) -> Bool {
  let arch = self.mcu_arch.to_lower()
  arch.contains("arm") || arch.contains("cortex") || arch.contains("thumb")
}

///|
/// Checks if the microcontroller architecture is RISC-V.
pub fn EmbeddedInfo::is_riscv_arch(self : EmbeddedInfo) -> Bool {
  let arch = self.mcu_arch.to_lower()
  arch.contains("riscv") || arch.contains("rv32") || arch.contains("rv64")
}

///|
/// Checks if the hardware target is ESP32 / Xtensa family.
pub fn EmbeddedInfo::is_esp32_arch(self : EmbeddedInfo) -> Bool {
  let arch = self.mcu_arch.to_lower()
  let board = self.board_model.to_lower()
  arch.contains("esp32") || arch.contains("xtensa") || board.contains("esp32")
}

///|
/// Computes memory utilization ratio given firmware binary footprint in bytes.
pub fn EmbeddedInfo::calc_flash_utilization(
  self : EmbeddedInfo,
  binary_bytes : Int,
) -> Double {
  if self.flash_size_kb <= 0 {
    0.0
  } else {
    let total_bytes = self.flash_size_kb * 1024
    let ratio = binary_bytes.to_double() / total_bytes.to_double()
    if ratio > 1.0 {
      1.0
    } else {
      ratio
    }
  }
}

///|
/// Returns a formatted summary string of MCU hardware configuration.
pub fn EmbeddedInfo::format_summary(self : EmbeddedInfo) -> String {
  "Board: " +
  self.board_model +
  " | Arch: " +
  self.mcu_arch +
  " | FW Ver: " +
  self.firmware_version +
  " | Target: " +
  self.build_target +
  " | Flash: " +
  self.flash_size_kb.to_string() +
  "KB | RAM: " +
  self.ram_size_kb.to_string() +
  "KB"
}
