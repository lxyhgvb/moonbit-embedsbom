///|
/// Exports SbomDocument components inventory to CSV spreadsheet string.
pub fn export_csv_table(doc : @types.SbomDocument) -> String {
  let buf = StringBuilder::new()
  buf.write_string("ID,Name,Version,Type,License,Supplier,Repository\n")

  for comp in doc.components {
    buf.write_string("\"" + comp.id + "\",")
    buf.write_string("\"" + comp.name + "\",")
    buf.write_string("\"" + comp.version + "\",")
    buf.write_string("\"" + comp.component_type.to_string() + "\",")
    buf.write_string("\"" + comp.license_id + "\",")
    buf.write_string("\"" + comp.supplier + "\",")
    buf.write_string("\"" + comp.repository + "\"\n")
  }

  buf.to_string()
}
