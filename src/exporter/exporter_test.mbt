///|
test "spdx_exporter_output" {
  let doc = @types.SbomDocument::new(name="SPDX Test")
  let comp1 = @types.Component::new(
    name="stm32-hal",
    version="1.0.0",
    license_id="BSD-3-Clause",
  )
  doc.add_component(comp1)

  let json_str = export_spdx_json(doc, pretty=false)
  assert_true(json_str.contains("\"spdxVersion\":\"SPDX-2.3\""))
  assert_true(json_str.contains("stm32-hal"))
  assert_true(json_str.contains("BSD-3-Clause"))
}

///|
test "cyclonedx_exporter_output" {
  let doc = @types.SbomDocument::new(name="CycloneDX Test")
  let comp1 = @types.Component::new(
    name="freertos-kernel",
    version="10.4.0",
    license_id="MIT",
  )
  doc.add_component(comp1)

  let json_str = export_cyclonedx_json(doc, pretty=false)
  assert_true(json_str.contains("\"bomFormat\":\"CycloneDX\""))
  assert_true(json_str.contains("\"specVersion\":\"1.5\""))
  assert_true(json_str.contains("freertos-kernel"))
}

///|
test "markdown_and_ascii_exporters" {
  let doc = @types.SbomDocument::new(name="Report Test")
  let comp1 = @types.Component::new(name="bootloader", version="0.5.0")
  let comp2 = @types.Component::new(name="driver", version="1.2.0")
  doc.add_component(comp1)
  doc.add_component(comp2)
  doc.add_relation("bootloader@0.5.0", "driver@1.2.0")

  let report = @analyzer.run_full_audit(doc)
  let md = export_markdown_report(doc, report)
  assert_true(md.contains("# Software Bill of Materials (SBOM) & Audit Report"))
  assert_true(md.contains("bootloader"))

  let graph = @graph.DependencyGraph::from_document(doc)
  let ascii = export_ascii_graph(graph)
  assert_true(ascii.contains("bootloader"))

  let csv = export_csv_table(doc)
  assert_true(csv.contains("bootloader"))
}
