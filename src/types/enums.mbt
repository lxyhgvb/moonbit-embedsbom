///|
/// ComponentType represents the domain category of a software component in embedded systems.
pub(all) enum ComponentType {
  Firmware
  Driver
  RtosKernel
  MoonBitPkg
  CLib
  Bootloader
  HardwareBsp
  ThirdPartyLib
} derive(Eq, Debug)

///|
/// LicenseCategory classifies licenses into legal compliance risk levels.
pub(all) enum LicenseCategory {
  Permissive
  WeakCopyleft
  StrongCopyleft
  Commercial
  Proprietary
  Dual
  Unknown
} derive(Eq, Debug)

///|
/// HashAlgorithm defines supported cryptographic checksum types.
pub(all) enum HashAlgorithm {
  SHA256
  SHA1
  MD5
  CRC32
} derive(Eq, Debug)

///|
/// VulnerabilitySeverity defines CVSS vulnerability threat levels.
pub(all) enum VulnerabilitySeverity {
  Critical
  High
  Medium
  Low
  Info
} derive(Eq, Debug)

///|
/// RelationType describes dependency links between components.
pub(all) enum RelationType {
  DependsOn
  BuildDependencyOf
  IncludedIn
  OptionalDependency
  RuntimeDependencyOf
} derive(Eq, Debug)

///|
/// Helper to convert ComponentType to standard display string.
pub fn ComponentType::to_string(self : ComponentType) -> String {
  match self {
    Firmware => "firmware"
    Driver => "driver"
    RtosKernel => "rtos-kernel"
    MoonBitPkg => "moonbit-package"
    CLib => "c-library"
    Bootloader => "bootloader"
    HardwareBsp => "hardware-bsp"
    ThirdPartyLib => "third-party-lib"
  }
}

///|
/// Helper to parse ComponentType from string.
pub fn ComponentType::from_string(s : String) -> ComponentType {
  let lower = s.to_lower()
  if lower == "firmware" {
    Firmware
  } else if lower == "driver" {
    Driver
  } else if lower == "rtos-kernel" || lower == "rtos" {
    RtosKernel
  } else if lower == "moonbit-package" || lower == "moonbit" {
    MoonBitPkg
  } else if lower == "c-library" || lower == "clib" {
    CLib
  } else if lower == "bootloader" {
    Bootloader
  } else if lower == "hardware-bsp" || lower == "bsp" {
    HardwareBsp
  } else {
    ThirdPartyLib
  }
}

///|
/// Helper to convert LicenseCategory to string.
pub fn LicenseCategory::to_string(self : LicenseCategory) -> String {
  match self {
    Permissive => "permissive"
    WeakCopyleft => "weak-copyleft"
    StrongCopyleft => "strong-copyleft"
    Commercial => "commercial"
    Proprietary => "proprietary"
    Dual => "dual"
    Unknown => "unknown"
  }
}

///|
/// Helper to convert HashAlgorithm to string name.
pub fn HashAlgorithm::to_string(self : HashAlgorithm) -> String {
  match self {
    SHA256 => "SHA-256"
    SHA1 => "SHA-1"
    MD5 => "MD5"
    CRC32 => "CRC32"
  }
}

///|
/// Helper to convert VulnerabilitySeverity to display string.
pub fn VulnerabilitySeverity::to_string(self : VulnerabilitySeverity) -> String {
  match self {
    Critical => "CRITICAL"
    High => "HIGH"
    Medium => "MEDIUM"
    Low => "LOW"
    Info => "INFO"
  }
}

///|
/// Helper to convert RelationType to string.
pub fn RelationType::to_string(self : RelationType) -> String {
  match self {
    DependsOn => "DEPENDS_ON"
    BuildDependencyOf => "BUILD_DEPENDENCY_OF"
    IncludedIn => "INCLUDED_IN"
    OptionalDependency => "OPTIONAL_DEPENDENCY"
    RuntimeDependencyOf => "RUNTIME_DEPENDENCY_OF"
  }
}
