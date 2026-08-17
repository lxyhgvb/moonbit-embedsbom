///|
/// Exports SbomDocument as CycloneDX 1.5 JSON specification string.
pub fn export_cyclonedx_json(
  doc : @types.SbomDocument,
  pretty? : Bool = true,
) -> String {
  let metadata = @utils.jobject([
    ("timestamp", @utils.jstr(doc.created_at)),
    (
      "tools",
      @utils.jarray([
        @utils.jobject([
          ("vendor", @utils.jstr("MoonBit")),
          ("name", @utils.jstr("embedsbom")),
          ("version", @utils.jstr("1.0.0")),
        ]),
      ]),
    ),
    (
      "component",
      @utils.jobject([
        ("type", @utils.jstr("firmware")),
        ("name", @utils.jstr(doc.name)),
        ("version", @utils.jstr(doc.version)),
      ]),
    ),
    (
      "properties",
      @utils.jarray([
        @utils.jobject([
          ("name", @utils.jstr("mcu:arch")),
          ("value", @utils.jstr(doc.embedded_info.mcu_arch)),
        ]),
        @utils.jobject([
          ("name", @utils.jstr("mcu:board")),
          ("value", @utils.jstr(doc.embedded_info.board_model)),
        ]),
        @utils.jobject([
          ("name", @utils.jstr("mcu:target")),
          ("value", @utils.jstr(doc.embedded_info.build_target)),
        ]),
        @utils.jobject([
          ("name", @utils.jstr("bootloader:version")),
          ("value", @utils.jstr(doc.embedded_info.bootloader_version)),
        ]),
      ]),
    ),
  ])

  let cd_components : Array[@utils.JsonValue] = []
  for comp in doc.components {
    let hashes : Array[@utils.JsonValue] = []
    for algo, val in comp.checksums {
      hashes.push(
        @utils.jobject([
          ("alg", @utils.jstr(algo)),
          ("content", @utils.jstr(val)),
        ]),
      )
    }

    let comp_obj = @utils.jobject([
      (
        "type",
        @utils.jstr(
          if comp.component_type == @types.ComponentType::Firmware {
            "firmware"
          } else {
            "library"
          },
        ),
      ),
      ("bom-ref", @utils.jstr(comp.id)),
      ("name", @utils.jstr(comp.name)),
      ("version", @utils.jstr(comp.version)),
      ("publisher", @utils.jstr(comp.supplier)),
      (
        "licenses",
        @utils.jarray([
          @utils.jobject([
            ("license", @utils.jobject([("id", @utils.jstr(comp.license_id))])),
          ]),
        ]),
      ),
      ("hashes", @utils.jarray(hashes)),
    ])
    cd_components.push(comp_obj)
  }

  let cd_dependencies : Array[@utils.JsonValue] = []
  let graph = @graph.DependencyGraph::from_document(doc)
  for parent_id, _ in graph.nodes {
    let deps = graph.get_direct_dependencies(parent_id)
    let dep_refs : Array[@utils.JsonValue] = []
    for child in deps {
      dep_refs.push(@utils.jstr(child))
    }
    cd_dependencies.push(
      @utils.jobject([
        ("ref", @utils.jstr(parent_id)),
        ("dependsOn", @utils.jarray(dep_refs)),
      ]),
    )
  }

  let root_obj = @utils.jobject([
    ("bomFormat", @utils.jstr("CycloneDX")),
    ("specVersion", @utils.jstr("1.5")),
    ("serialNumber", @utils.jstr("urn:uuid:moonbit-" + doc.id)),
    ("version", @utils.jnum(1.0)),
    ("metadata", metadata),
    ("components", @utils.jarray(cd_components)),
    ("dependencies", @utils.jarray(cd_dependencies)),
  ])

  root_obj.stringify(pretty~)
}
