///|
pub fn format_mac_frame_summary(frame : @frame.MacFrame) -> String {
  let buf = StringBuilder::new()
  buf.write_string("=== IEEE 802.15.4 MAC Frame Summary ===\n")

  let ftype_str = match frame.header.fcf.frame_type {
    Beacon => "Beacon"
    Data => "Data"
    Ack => "ACK"
    MacCmd => "MAC Command"
    Reserved(n) => "Reserved(" + n.to_string() + ")"
  }
  buf.write_string("Frame Type: " + ftype_str + "\n")
  buf.write_string("Seq Number: " + frame.header.seq_num.to_string() + "\n")
  buf.write_string(
    "Ack Request: " + frame.header.fcf.ack_request.to_string() + "\n",
  )
  buf.write_string(
    "PAN ID Comp: " + frame.header.fcf.pan_id_compression.to_string() + "\n",
  )

  match frame.header.dest_pan_id {
    Some(pan) =>
      buf.write_string(
        "Dest PAN ID: 0x" +
        bytes_to_hex(Bytes::from_array([(pan >> 8).to_byte(), pan.to_byte()])) +
        "\n",
      )
    None => ()
  }

  match frame.header.dest_addr {
    BroadcastAddress => buf.write_string("Dest Address: Broadcast (0xFFFF)\n")
    ShortAddress(addr) =>
      buf.write_string("Dest Address: Short(0x" + addr.to_string() + ")\n")
    ExtendedAddress(addr) =>
      buf.write_string("Dest Address: Extended(0x" + addr.to_string() + ")\n")
    NoneAddress => buf.write_string("Dest Address: None\n")
  }

  match frame.header.src_addr {
    ShortAddress(addr) =>
      buf.write_string("Src Address: Short(0x" + addr.to_string() + ")\n")
    ExtendedAddress(addr) =>
      buf.write_string("Src Address: Extended(0x" + addr.to_string() + ")\n")
    _ => buf.write_string("Src Address: None\n")
  }

  buf.write_string(
    "Payload Len: " + frame.payload.length().to_string() + " bytes\n",
  )
  buf.write_string("Payload Hex: " + bytes_to_hex(frame.payload) + "\n")
  buf.write_string("FCS Checksum: 0x" + frame.fcs.to_string() + "\n")
  buf.to_string()
}
