///|
/// Prints version banner.
pub fn run_version_command() -> String {
  "MoonBit embedsbom CLI v1.0.0 (MoonBit 0.10.x, target: embedded-spdx/cyclonedx)"
}

///|
/// Prints CLI help text usage information.
pub fn run_help_command() -> String {
  let buf = StringBuilder::new()
  buf.write_string(
    "MoonBit Embedded Software Bill of Materials (embedsbom) Tool\n\n",
  )
  buf.write_string("USAGE:\n")
  buf.write_string("  embedsbom <COMMAND> [OPTIONS]\n\n")
  buf.write_string("COMMANDS:\n")
  buf.write_string(
    "  scan      Scan directory or manifest and output SBOM document\n",
  )
  buf.write_string(
    "  licenses  Analyze license compliance risk and conflicts\n",
  )
  buf.write_string("  graph     Render dependency tree graph or check cycles\n")
  buf.write_string(
    "  validate  Validate SBOM format, semver rules, and integrity\n",
  )
  buf.write_string(
    "  export    Export SBOM to SPDX 2.3 JSON or CycloneDX 1.5 JSON\n",
  )
  buf.write_string("  version   Display embedsbom CLI version\n")
  buf.write_string("  help      Show command usage help\n\n")
  buf.write_string("OPTIONS:\n")
  buf.write_string(
    "  -i, --input <FILE>    Input manifest file (default: moon.mod)\n",
  )
  buf.write_string("  -o, --output <FILE>   Output target path\n")
  buf.write_string(
    "  -f, --format <FMT>    Format: spdx, cyclonedx, markdown, ascii, csv\n",
  )
  buf.write_string(
    "  -a, --arch <ARCH>     MCU/CPU architecture (e.g. cortex-m4, rv32imc)\n",
  )
  buf.write_string(
    "  -b, --board <MODEL>   Hardware board model (e.g. STM32F407G-DISC1)\n",
  )
  buf.write_string(
    "  --strict              Enforce zero-warning strict compliance\n",
  )
  buf.to_string()
}

///|
/// Executes scan command over sample embedded manifest content.
pub fn run_scan_command(opts : CliOptions, manifest_content : String) -> String {
  let mod_meta = @parser.parse_moon_mod_content(manifest_content)
  let root_comp = mod_meta.to_component()
  let embedded = @types.EmbeddedInfo::new(
    mcu_arch=opts.mcu_arch,
    board_model=opts.board_model,
  )

  let doc = @types.SbomDocument::new(
    name=mod_meta.name,
    version=mod_meta.version,
    embedded_info=embedded,
  )
  doc.add_component(root_comp)

  if opts.format.to_lower() == "cyclonedx" {
    @exporter.export_cyclonedx_json(doc)
  } else if opts.format.to_lower() == "markdown" {
    let report = @analyzer.run_full_audit(doc)
    @exporter.export_markdown_report(doc, report)
  } else if opts.format.to_lower() == "csv" {
    @exporter.export_csv_table(doc)
  } else {
    @exporter.export_spdx_json(doc)
  }
}

///|
/// Executes licenses audit command.
pub fn run_licenses_command(doc : @types.SbomDocument) -> String {
  let issues = @analyzer.analyze_licenses(doc)
  let buf = StringBuilder::new()
  buf.write_string(
    "License Audit Results (" +
    issues.length().to_string() +
    " issues found):\n",
  )
  if issues.length() == 0 {
    buf.write_string(
      "  ✓ All component licenses compliant and SPDX certified.\n",
    )
  } else {
    for issue in issues {
      buf.write_string(
        "  ✗ [" + issue.issue_type + "] " + issue.description + "\n",
      )
    }
  }
  buf.to_string()
}

///|
/// Executes graph render command.
pub fn run_graph_command(doc : @types.SbomDocument) -> String {
  let graph = @graph.DependencyGraph::from_document(doc)
  let detector = @graph.CycleDetector::new(graph)
  let cycles = detector.detect_cycles()

  let buf = StringBuilder::new()
  buf.write_string("Dependency Graph Tree:\n\n")
  buf.write_string(@exporter.export_ascii_graph(graph))
  buf.write_string("\n")

  if cycles.length() > 0 {
    buf.write_string(
      "⚠ Circular Dependencies (" +
      cycles.length().to_string() +
      " detected):\n",
    )
    for cycle in cycles {
      buf.write_string("  ")
      for i, c in cycle {
        if i > 0 {
          buf.write_string(" -> ")
        }
        buf.write_string(c)
      }
      buf.write_string("\n")
    }
  } else {
    buf.write_string("✓ No circular dependencies detected in graph.\n")
  }

  buf.to_string()
}

///|
/// Executes validate command.
pub fn run_validate_command(doc : @types.SbomDocument) -> String {
  let report = @analyzer.run_full_audit(doc)
  let buf = StringBuilder::new()
  buf.write_string("SBOM Integrity Validation Report:\n")
  buf.write_string(
    "  Status: " +
    (if report.is_compliant { "PASSED ✓" } else { "FAILED ✗" }) +
    "\n",
  )
  buf.write_string(
    "  License Issues: " + report.license_issues.length().to_string() + "\n",
  )
  buf.write_string(
    "  Version Issues: " + report.version_issues.length().to_string() + "\n",
  )
  buf.write_string(
    "  Cyclic Dependencies: " + report.cycles.length().to_string() + "\n",
  )
  buf.to_string()
}
