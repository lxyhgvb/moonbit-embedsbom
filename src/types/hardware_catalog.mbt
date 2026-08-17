///|
/// McuFamily describes microcontroller silicon vendor product lines.
pub(all) enum McuFamily {
  Stm32F4
  Stm32H7
  Esp32S3
  Esp32C3
  Nrf52840
  Rp2040
  Rp2350
  Ch32V307
  ImxRt1060
  Samd21
} derive(Eq, Debug)

///|
/// HardwareBoardSpec details comprehensive silicon and PCB parameters.
pub(all) struct HardwareBoardSpec {
  family : McuFamily
  chip_name : String
  vendor : String
  arch : String
  clock_mhz : Int
  flash_kb : Int
  ram_kb : Int
  has_fpu : Bool
  has_mpu : Bool
  has_trustzone : Bool
  default_target : String
} derive(Eq, Debug)

///|
/// Returns comprehensive specification catalog for supported MCU hardware boards.
pub fn get_hardware_board_catalog() -> Array[HardwareBoardSpec] {
  [
    {
      family: Stm32F4,
      chip_name: "STM32F407ZG",
      vendor: "STMicroelectronics",
      arch: "arm-cortex-m4",
      clock_mhz: 168,
      flash_kb: 1024,
      ram_kb: 192,
      has_fpu: true,
      has_mpu: true,
      has_trustzone: false,
      default_target: "thumbv7em-none-eabihf",
    },
    {
      family: Stm32H7,
      chip_name: "STM32H743ZI",
      vendor: "STMicroelectronics",
      arch: "arm-cortex-m7",
      clock_mhz: 480,
      flash_kb: 2048,
      ram_kb: 1024,
      has_fpu: true,
      has_mpu: true,
      has_trustzone: false,
      default_target: "thumbv7em-none-eabihf",
    },
    {
      family: Esp32S3,
      chip_name: "ESP32-S3-WROOM-1",
      vendor: "Espressif Systems",
      arch: "xtensa-lx7",
      clock_mhz: 240,
      flash_kb: 8192,
      ram_kb: 512,
      has_fpu: true,
      has_mpu: false,
      has_trustzone: false,
      default_target: "xtensa-esp32s3-espidf",
    },
    {
      family: Esp32C3,
      chip_name: "ESP32-C3-MINI-1",
      vendor: "Espressif Systems",
      arch: "riscv32-imc",
      clock_mhz: 160,
      flash_kb: 4096,
      ram_kb: 400,
      has_fpu: false,
      has_mpu: false,
      has_trustzone: false,
      default_target: "riscv32imc-unknown-none-elf",
    },
    {
      family: Nrf52840,
      chip_name: "nRF52840-QIAA",
      vendor: "Nordic Semiconductor",
      arch: "arm-cortex-m4",
      clock_mhz: 64,
      flash_kb: 1024,
      ram_kb: 256,
      has_fpu: true,
      has_mpu: true,
      has_trustzone: false,
      default_target: "thumbv7em-none-eabihf",
    },
    {
      family: Rp2040,
      chip_name: "RP2040",
      vendor: "Raspberry Pi",
      arch: "arm-cortex-m0plus",
      clock_mhz: 133,
      flash_kb: 2048,
      ram_kb: 264,
      has_fpu: false,
      has_mpu: true,
      has_trustzone: false,
      default_target: "thumbv6m-none-eabi",
    },
    {
      family: Rp2350,
      chip_name: "RP2350",
      vendor: "Raspberry Pi",
      arch: "arm-cortex-m33",
      clock_mhz: 150,
      flash_kb: 4096,
      ram_kb: 520,
      has_fpu: true,
      has_mpu: true,
      has_trustzone: true,
      default_target: "thumbv8m.main-none-eabihf",
    },
    {
      family: Ch32V307,
      chip_name: "CH32V307VCT6",
      vendor: "WCH (WinChipHead)",
      arch: "riscv32-imafc",
      clock_mhz: 144,
      flash_kb: 288,
      ram_kb: 64,
      has_fpu: true,
      has_mpu: false,
      has_trustzone: false,
      default_target: "riscv32-unknown-elf",
    },
    {
      family: ImxRt1060,
      chip_name: "i.MX RT1062",
      vendor: "NXP Semiconductors",
      arch: "arm-cortex-m7",
      clock_mhz: 600,
      flash_kb: 16384,
      ram_kb: 1024,
      has_fpu: true,
      has_mpu: true,
      has_trustzone: false,
      default_target: "thumbv7em-none-eabihf",
    },
    {
      family: Samd21,
      chip_name: "ATSAMD21G18A",
      vendor: "Microchip Technology",
      arch: "arm-cortex-m0plus",
      clock_mhz: 48,
      flash_kb: 256,
      ram_kb: 32,
      has_fpu: false,
      has_mpu: false,
      has_trustzone: false,
      default_target: "thumbv6m-none-eabi",
    },
  ]
}

///|
/// Resolves a HardwareBoardSpec by chip or board model query string.
pub fn find_hardware_spec(query : String) -> HardwareBoardSpec? {
  let lower = query.to_lower()
  let catalog = get_hardware_board_catalog()
  for spec in catalog {
    let chip_lower = spec.chip_name.to_lower()
    if chip_lower.contains(lower) ||
      lower.contains(chip_lower) ||
      query.to_upper().contains(spec.chip_name) {
      return Some(spec)
    }
  }
  None
}
