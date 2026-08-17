///|
/// Provides a curated database of embedded firmware & library vulnerability records.
pub fn get_embedded_vulnerability_database() -> Array[@types.Vulnerability] {
  [
    @types.Vulnerability::new(
      cve_id="CVE-2023-4211",
      summary="Out-of-bounds memory write in ARM Cortex-M HAL driver buffer handler",
      severity=@types.VulnerabilitySeverity::High,
      cvss_score=8.1,
      affected_component="stm32-hal",
      affected_versions="<1.3.0",
      fixed_version="1.3.0",
      reference_url="https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-4211",
    ),
    @types.Vulnerability::new(
      cve_id="CVE-2021-31571",
      summary="FreeRTOS TCP/IP stack integer overflow causing memory corruption",
      severity=@types.VulnerabilitySeverity::Critical,
      cvss_score=9.8,
      affected_component="freertos-kernel",
      affected_versions="<10.4.3",
      fixed_version="10.4.3",
      reference_url="https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-31571",
    ),
    @types.Vulnerability::new(
      cve_id="CVE-2022-29362",
      summary="MCUBoot RSA signature verification bypass during boot image authentication",
      severity=@types.VulnerabilitySeverity::High,
      cvss_score=7.8,
      affected_component="mcuboot",
      affected_versions="<1.9.0",
      fixed_version="1.9.0",
      reference_url="https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-29362",
    ),
  ]
}
