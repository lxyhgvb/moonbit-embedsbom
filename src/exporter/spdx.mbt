///|
/// Exports SbomDocument as SPDX 2.3 JSON specification string.
pub fn export_spdx_json(
  doc : @types.SbomDocument,
  pretty? : Bool = true,
) -> String {
  let creation_info = @utils.jobject([
    ("created", @utils.jstr(doc.created_at)),
    ("creators", @utils.jarray([@utils.jstr("Tool: " + doc.creator)])),
  ])

  let spdx_packages : Array[@utils.JsonValue] = []
  for comp in doc.components {
    let checksum_list : Array[@utils.JsonValue] = []
    for algo, val in comp.checksums {
      checksum_list.push(
        @utils.jobject([
          ("algorithm", @utils.jstr(algo)),
          ("checksumValue", @utils.jstr(val)),
        ]),
      )
    }

    let pkg_node = @utils.jobject([
      (
        "SPDXID",
        @utils.jstr("SPDXRef-Package-" + @utils.slugify_component_name(comp.id)),
      ),
      ("name", @utils.jstr(comp.name)),
      ("versionInfo", @utils.jstr(comp.version)),
      ("supplier", @utils.jstr("Organization: " + comp.supplier)),
      ("licenseConcluded", @utils.jstr(comp.license_id)),
      ("licenseDeclared", @utils.jstr(comp.license_id)),
      (
        "downloadLocation",
        @utils.jstr(
          if comp.repository == "" {
            "NOASSERTION"
          } else {
            comp.repository
          },
        ),
      ),
      ("filesAnalyzed", @utils.jbool(false)),
      ("checksums", @utils.jarray(checksum_list)),
      (
        "comment",
        @utils.jstr("Embedded type: " + comp.component_type.to_string()),
      ),
    ])
    spdx_packages.push(pkg_node)
  }

  let spdx_relations : Array[@utils.JsonValue] = []
  for rel in doc.relationships {
    spdx_relations.push(
      @utils.jobject([
        (
          "spdxElementId",
          @utils.jstr(
            "SPDXRef-Package-" + @utils.slugify_component_name(rel.parent_id),
          ),
        ),
        (
          "relatedSpdxElement",
          @utils.jstr(
            "SPDXRef-Package-" + @utils.slugify_component_name(rel.child_id),
          ),
        ),
        ("relationshipType", @utils.jstr(rel.relation_type.to_string())),
      ]),
    )
  }

  let embedded_props = @utils.jobject([
    ("mcuArchitecture", @utils.jstr(doc.embedded_info.mcu_arch)),
    ("firmwareVersion", @utils.jstr(doc.embedded_info.firmware_version)),
    ("buildTarget", @utils.jstr(doc.embedded_info.build_target)),
    ("bootloaderVersion", @utils.jstr(doc.embedded_info.bootloader_version)),
    ("boardModel", @utils.jstr(doc.embedded_info.board_model)),
    ("binaryHash", @utils.jstr(doc.embedded_info.binary_hash)),
    ("flashSizeKb", @utils.jnum(doc.embedded_info.flash_size_kb.to_double())),
    ("ramSizeKb", @utils.jnum(doc.embedded_info.ram_size_kb.to_double())),
  ])

  let root_obj = @utils.jobject([
    ("spdxVersion", @utils.jstr("SPDX-2.3")),
    ("dataLicense", @utils.jstr("CC0-1.0")),
    ("SPDXID", @utils.jstr("SPDXRef-DOCUMENT")),
    ("name", @utils.jstr(doc.name)),
    ("documentNamespace", @utils.jstr(doc.doc_namespace)),
    ("creationInfo", creation_info),
    ("packages", @utils.jarray(spdx_packages)),
    ("relationships", @utils.jarray(spdx_relations)),
    ("embeddedMetadata", embedded_props),
  ])

  root_obj.stringify(pretty~)
}
