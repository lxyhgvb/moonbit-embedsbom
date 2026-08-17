///|
pub fn run_integration_pipeline() -> Bool {
  let embedded = @types.get_hardware_preset("stm32f407")
  let doc = @types.SbomDocument::new(
    id="DOC-STM32F4-FW-001",
    name="STM32F4 Industrial Controller Firmware",
    version="2.4.0",
    embedded_info=embedded,
  )

  let bsp = @types.Component::new(
    name="stm32f4-bsp",
    version="1.5.0",
    supplier="STMicroelectronics",
    license_id="BSD-3-Clause",
    component_type=@types.ComponentType::HardwareBsp,
    embedded_info=embedded,
  )
  let rtos = @types.Component::new(
    name="freertos-kernel",
    version="10.4.6",
    supplier="Amazon Web Services",
    license_id="MIT",
    component_type=@types.ComponentType::RtosKernel,
    embedded_info=embedded,
  )

  doc.add_component(bsp)
  doc.add_component(rtos)
  doc.add_relation("stm32f4-bsp@1.5.0", "freertos-kernel@10.4.6")

  let report = @analyzer.run_full_audit(doc)
  let spdx = @exporter.export_spdx_json(doc)
  let cyclonedx = @exporter.export_cyclonedx_json(doc)

  let spdx_errs = @exporter.validate_spdx_json_spec(spdx)
  let cd_errs = @exporter.validate_cyclonedx_json_spec(cyclonedx)

  report.is_compliant && spdx_errs.length() == 0 && cd_errs.length() == 0
}
