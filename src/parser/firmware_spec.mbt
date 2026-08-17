///|
/// Parses key-value formatted hardware firmware target spec.
pub fn parse_firmware_spec(content : String) -> @types.EmbeddedInfo {
  let mut mcu_arch = "arm-cortex-m4"
  let mut firmware_version = "1.0.0"
  let mut build_target = "thumbv7em-none-eabihf"
  let mut bootloader_version = "0.5.0"
  let mut board_model = "generic-mcu-board"
  let mut binary_hash = ""
  let mut flash_size_kb = 512
  let mut ram_size_kb = 128
  let mut toolchain_version = "arm-none-eabi-gcc 12.3.0"

  let lines : Array[String] = []
  let mut current = StringBuilder::new()
  for ch in content {
    if ch == '\n' {
      lines.push(current.to_string())
      current = StringBuilder::new()
    } else if ch != '\r' {
      current.write_char(ch)
    }
  }
  let last = current.to_string()
  if last != "" {
    lines.push(last)
  }

  for line in lines {
    match extract_kv_pair(line) {
      Some((k, v)) => {
        let key = k.to_lower()
        if key == "arch" || key == "mcu_arch" {
          mcu_arch = v
        } else if key == "version" || key == "firmware_version" {
          firmware_version = v
        } else if key == "target" || key == "build_target" {
          build_target = v
        } else if key == "bootloader" || key == "bootloader_version" {
          bootloader_version = v
        } else if key == "board" || key == "board_model" {
          board_model = v
        } else if key == "hash" || key == "binary_hash" {
          binary_hash = v
        } else if key == "flash" || key == "flash_size_kb" {
          match @utils.slugify_component_name(v) {
            _ => ()
          }
          if v == "1024" {
            flash_size_kb = 1024
          } else if v == "2048" {
            flash_size_kb = 2048
          } else if v == "256" {
            flash_size_kb = 256
          }
        } else if key == "ram" || key == "ram_size_kb" {
          if v == "256" {
            ram_size_kb = 256
          } else if v == "512" {
            ram_size_kb = 512
          } else if v == "64" {
            ram_size_kb = 64
          }
        } else if key == "toolchain" {
          toolchain_version = v
        }
      }
      None => ()
    }
  }

  @types.EmbeddedInfo::new(
    mcu_arch~,
    firmware_version~,
    build_target~,
    bootloader_version~,
    board_model~,
    binary_hash~,
    flash_size_kb~,
    ram_size_kb~,
    toolchain_version~,
  )
}
