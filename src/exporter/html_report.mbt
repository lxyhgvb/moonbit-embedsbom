///|
/// Exports SbomDocument and AuditReport to self-contained HTML report.
pub fn export_html_report(
  doc : @types.SbomDocument,
  report : @analyzer.AuditReport,
) -> String {
  let buf = StringBuilder::new()

  buf.write_string("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n")
  buf.write_string("  <meta charset=\"UTF-8\">\n")
  buf.write_string("  <title>Embedded SBOM Report - " + doc.name + "</title>\n")
  buf.write_string("  <style>\n")
  buf.write_string(
    "    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 30px; background: #f8f9fa; color: #212529; }\n",
  )
  buf.write_string(
    "    .container { max-width: 1000px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }\n",
  )
  buf.write_string(
    "    h1, h2 { color: #0d6efd; border-bottom: 2px solid #e9ecef; padding-bottom: 8px; }\n",
  )
  buf.write_string(
    "    .badge-pass { background: #198754; color: #fff; padding: 4px 8px; border-radius: 4px; font-weight: bold; }\n",
  )
  buf.write_string(
    "    .badge-fail { background: #dc3545; color: #fff; padding: 4px 8px; border-radius: 4px; font-weight: bold; }\n",
  )
  buf.write_string(
    "    table { width: 100%; border-collapse: collapse; margin-top: 16px; margin-bottom: 24px; }\n",
  )
  buf.write_string(
    "    th, td { border: 1px solid #dee2e6; padding: 10px; text-align: left; }\n",
  )
  buf.write_string("    th { background: #f1f3f5; }\n")
  buf.write_string(
    "    .issue { background: #fff3cd; color: #664d03; padding: 12px; border-left: 4px solid #ffc107; margin-bottom: 8px; border-radius: 4px; }\n",
  )
  buf.write_string("  </style>\n</head>\n<body>\n")

  buf.write_string("<div class=\"container\">\n")
  buf.write_string("  <h1>Embedded SBOM Audit Report: " + doc.name + "</h1>\n")
  buf.write_string(
    "  <p><strong>Version:</strong> " +
    doc.version +
    " | <strong>Created:</strong> " +
    doc.created_at +
    "</p>\n",
  )
  buf.write_string(
    "  <p><strong>Audit Result:</strong> <span class=\"" +
    (if report.is_compliant { "badge-pass" } else { "badge-fail" }) +
    "\">" +
    (if report.is_compliant {
      "COMPLIANT PASSED"
    } else {
      "NON-COMPLIANT FAILED"
    }) +
    "</span></p>\n",
  )

  buf.write_string("  <h2>Embedded Target Hardware</h2>\n")
  buf.write_string("  <table>\n")
  buf.write_string(
    "    <tr><th>Parameter</th><th>Specification Value</th></tr>\n",
  )
  buf.write_string(
    "    <tr><td>MCU Architecture</td><td><code>" +
    doc.embedded_info.mcu_arch +
    "</code></td></tr>\n",
  )
  buf.write_string(
    "    <tr><td>Board Model</td><td><code>" +
    doc.embedded_info.board_model +
    "</code></td></tr>\n",
  )
  buf.write_string(
    "    <tr><td>Firmware Version</td><td><code>" +
    doc.embedded_info.firmware_version +
    "</code></td></tr>\n",
  )
  buf.write_string(
    "    <tr><td>Build Target</td><td><code>" +
    doc.embedded_info.build_target +
    "</code></td></tr>\n",
  )
  buf.write_string(
    "    <tr><td>Flash KB</td><td>" +
    doc.embedded_info.flash_size_kb.to_string() +
    " KB</td></tr>\n",
  )
  buf.write_string(
    "    <tr><td>RAM KB</td><td>" +
    doc.embedded_info.ram_size_kb.to_string() +
    " KB</td></tr>\n",
  )
  buf.write_string("  </table>\n")

  buf.write_string(
    "  <h2>Software Component Inventory (" +
    doc.component_count().to_string() +
    ")</h2>\n",
  )
  buf.write_string("  <table>\n")
  buf.write_string(
    "    <tr><th>Component Name</th><th>Version</th><th>Type</th><th>License</th><th>Supplier</th></tr>\n",
  )
  for comp in doc.components {
    buf.write_string(
      "    <tr><td><strong>" +
      comp.name +
      "</strong></td><td>" +
      comp.version +
      "</td><td>" +
      comp.component_type.to_string() +
      "</td><td><code>" +
      comp.license_id +
      "</code></td><td>" +
      comp.supplier +
      "</td></tr>\n",
    )
  }
  buf.write_string("  </table>\n")

  if report.license_issues.length() > 0 {
    buf.write_string(
      "  <h2>License Issues (" +
      report.license_issues.length().to_string() +
      ")</h2>\n",
    )
    for issue in report.license_issues {
      buf.write_string(
        "  <div class=\"issue\"><strong>[" +
        issue.issue_type +
        "]</strong> " +
        issue.description +
        "</div>\n",
      )
    }
  }

  buf.write_string("</div>\n</body>\n</html>\n")
  buf.to_string()
}
