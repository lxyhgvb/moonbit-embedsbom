///|
/// Main CLI runner processing command line arguments array.
pub fn run_cli(args : Array[String], manifest_content? : String = "") -> String {
  let opts = parse_cli_args(args)
  match opts.command {
    Version => run_version_command()
    Help => run_help_command()
    Scan => {
      let content = if manifest_content == "" {
        (
          #|name = "embedded-firmware-app"
          #|version = "1.0.0"
          #|license = "Apache-2.0"
        )
      } else {
        manifest_content
      }
      run_scan_command(opts, content)
    }
    Licenses => {
      let doc = @types.SbomDocument::new(name="Embedded Firmware Project")
      let comp = @types.Component::new(
        name="mcu-driver",
        version="1.0.0",
        license_id="MIT",
      )
      doc.add_component(comp)
      run_licenses_command(doc)
    }
    Graph => {
      let doc = @types.SbomDocument::new(name="Embedded Firmware Project")
      let comp = @types.Component::new(name="rtos-kernel", version="10.0.0")
      doc.add_component(comp)
      run_graph_command(doc)
    }
    Validate => {
      let doc = @types.SbomDocument::new(name="Embedded Firmware Project")
      let comp = @types.Component::new(name="bootloader", version="1.0.0")
      doc.add_component(comp)
      run_validate_command(doc)
    }
    Export => {
      let doc = @types.SbomDocument::new(name="Export Project")
      let comp = @types.Component::new(name="stm32-bsp", version="2.0.0")
      doc.add_component(comp)
      if opts.format.to_lower() == "cyclonedx" {
        @exporter.export_cyclonedx_json(doc)
      } else {
        @exporter.export_spdx_json(doc)
      }
    }
  }
}
