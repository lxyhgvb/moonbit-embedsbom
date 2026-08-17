///|
/// Exports AuditReport to detailed Markdown formatted report string.
pub fn export_markdown_report(
  doc : @types.SbomDocument,
  report : @analyzer.AuditReport,
) -> String {
  let buf = StringBuilder::new()

  buf.write_string("# Software Bill of Materials (SBOM) & Audit Report\n\n")
  buf.write_string("**Document Name**: " + doc.name + "\n")
  buf.write_string("**Version**: " + doc.version + "\n")
  buf.write_string("**Created**: " + doc.created_at + "\n")
  buf.write_string(
    "**Compliance Status**: " +
    (if report.is_compliant { "PASSED" } else { "FAILED" }) +
    "\n\n",
  )

  buf.write_string("## Embedded Hardware Target Parameters\n\n")
  buf.write_string("| Parameter | Value |\n")
  buf.write_string("|---|---|\n")
  buf.write_string(
    "| MCU Architecture | `" + doc.embedded_info.mcu_arch + "` |\n",
  )
  buf.write_string(
    "| Board Model | `" + doc.embedded_info.board_model + "` |\n",
  )
  buf.write_string(
    "| Firmware Version | `" + doc.embedded_info.firmware_version + "` |\n",
  )
  buf.write_string(
    "| Build Target | `" + doc.embedded_info.build_target + "` |\n",
  )
  buf.write_string(
    "| Bootloader Version | `" + doc.embedded_info.bootloader_version + "` |\n",
  )
  buf.write_string(
    "| Flash Memory | " +
    doc.embedded_info.flash_size_kb.to_string() +
    " KB |\n",
  )
  buf.write_string(
    "| RAM Memory | " + doc.embedded_info.ram_size_kb.to_string() + " KB |\n\n",
  )

  buf.write_string(
    "## Component Inventory (" +
    doc.component_count().to_string() +
    " components)\n\n",
  )
  buf.write_string("| Name | Version | Type | License | Supplier |\n")
  buf.write_string("|---|---|---|---|---|\n")
  for comp in doc.components {
    buf.write_string(
      "| " +
      comp.name +
      " | " +
      comp.version +
      " | " +
      comp.component_type.to_string() +
      " | " +
      comp.license_id +
      " | " +
      comp.supplier +
      " |\n",
    )
  }
  buf.write_string("\n")

  if report.license_issues.length() > 0 {
    buf.write_string(
      "## License Compliance Issues (" +
      report.license_issues.length().to_string() +
      ")\n\n",
    )
    for issue in report.license_issues {
      buf.write_string(
        "- **[" + issue.issue_type + "]** " + issue.description + "\n",
      )
    }
    buf.write_string("\n")
  }

  if report.cycles.length() > 0 {
    buf.write_string(
      "## Circular Dependencies Detected (" +
      report.cycles.length().to_string() +
      ")\n\n",
    )
    for cycle in report.cycles {
      buf.write_string("- Cycle: ")
      for i, node in cycle {
        if i > 0 {
          buf.write_string(" -> ")
        }
        buf.write_string("`" + node + "`")
      }
      buf.write_string("\n")
    }
    buf.write_string("\n")
  }

  buf.to_string()
}
