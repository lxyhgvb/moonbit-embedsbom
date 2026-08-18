///|
pub fn encode_mac_frame(frame : MacFrame) -> Result[Bytes, String] {
  let writer = @bitstream.BitWriter::new(order=LsbFirst)
  let fcf_val = frame.header.fcf.to_u16()

  let _ = match writer.write_u32(fcf_val, 16) {
    Ok(_) => ()
    Err(_) => return Err("Failed to write FCF")
  }

  if !frame.header.fcf.sequence_number_suppress {
    let seq_u = (frame.header.seq_num & 0xFF).reinterpret_as_uint()
    let _ = match writer.write_u32(seq_u, 8) {
      Ok(_) => ()
      Err(_) => return Err("Failed to write SeqNum")
    }
  }

  // Write Destination PAN ID and Address
  match frame.header.dest_pan_id {
    Some(pan) => {
      let _ = match writer.write_u32(pan, 16) {
        Ok(_) => ()
        Err(_) => return Err("Failed to write Dest PAN ID")
      }
    }
    None => ()
  }

  match frame.header.dest_addr {
    ShortAddress(addr) => {
      let _ = match writer.write_u32(addr, 16) {
        Ok(_) => ()
        Err(_) => return Err("Failed to write Dest Short Addr")
      }
    }
    BroadcastAddress => {
      let _ = match writer.write_u32(0xFFFFU, 16) {
        Ok(_) => ()
        Err(_) => return Err("Failed to write Broadcast Addr")
      }
    }
    ExtendedAddress(addr) => {
      let _ = match writer.write_u64(addr, 64) {
        Ok(_) => ()
        Err(_) => return Err("Failed to write Dest Extended Addr")
      }
    }
    NoneAddress => ()
  }

  // Write Source PAN ID and Address
  if !frame.header.fcf.pan_id_compression {
    match frame.header.src_pan_id {
      Some(pan) => {
        let _ = match writer.write_u32(pan, 16) {
          Ok(_) => ()
          Err(_) => return Err("Failed to write Src PAN ID")
        }
      }
      None => ()
    }
  }

  match frame.header.src_addr {
    ShortAddress(addr) => {
      let _ = match writer.write_u32(addr, 16) {
        Ok(_) => ()
        Err(_) => return Err("Failed to write Src Short Addr")
      }
    }
    ExtendedAddress(addr) => {
      let _ = match writer.write_u64(addr, 64) {
        Ok(_) => ()
        Err(_) => return Err("Failed to write Src Extended Addr")
      }
    }
    _ => ()
  }

  // Write Aux Security Header if enabled
  if frame.header.fcf.security_enabled {
    match frame.header.aux_sec {
      Some(aux) => {
        let sec_bytes = aux.encode()
        let _ = match writer.write_bytes(sec_bytes) {
          Ok(_) => ()
          Err(_) => return Err("Failed to write Aux Security Header")
        }
      }
      None => ()
    }
  }

  // Write Payload
  let _ = match writer.write_bytes(frame.payload) {
    Ok(_) => ()
    Err(_) => return Err("Failed to write Payload")
  }

  let body_bytes = writer.to_bytes()
  let computed_fcs = @integrity.CRC16::compute_ieee802154_fcs(body_bytes)

  let fcs_writer = @bitstream.BitWriter::new(order=LsbFirst)
  let _ = match fcs_writer.write_bytes(body_bytes) {
    Ok(_) => ()
    Err(_) => return Err("Failed body flush")
  }
  let _ = match fcs_writer.write_u32(computed_fcs, 16) {
    Ok(_) => ()
    Err(_) => return Err("Failed FCS write")
  }

  Ok(fcs_writer.to_bytes())
}

///|
pub fn decode_mac_frame(data : Bytes) -> Result[MacFrame, String] {
  if data.length() < 5 {
    return Err("Frame data too short")
  }

  let reader = @bitstream.BitReader::new(data, order=LsbFirst)
  let fcf_u16 = match reader.read_u32(16) {
    Ok(v) => v
    Err(_) => return Err("Invalid FCF")
  }
  let fcf = FrameControlField::from_u16(fcf_u16)

  let seq_num = if fcf.sequence_number_suppress {
    0
  } else {
    match reader.read_u32(8) {
      Ok(v) => v.reinterpret_as_int()
      Err(_) => return Err("Invalid SeqNum")
    }
  }

  let mut dest_pan : UInt? = None
  let mut dest_addr : MacAddress = NoneAddress

  match fcf.dest_addr_mode {
    Short16 => {
      let pan = match reader.read_u32(16) {
        Ok(v) => v
        Err(_) => return Err("Invalid Dest PAN ID")
      }
      dest_pan = Some(pan)
      let addr = match reader.read_u32(16) {
        Ok(v) => v
        Err(_) => return Err("Invalid Dest Short Addr")
      }
      dest_addr = if addr == 0xFFFFU {
        BroadcastAddress
      } else {
        ShortAddress(addr)
      }
    }
    Extended64 => {
      let pan = match reader.read_u32(16) {
        Ok(v) => v
        Err(_) => return Err("Invalid Dest PAN ID")
      }
      dest_pan = Some(pan)
      let addr = match reader.read_u64(64) {
        Ok(v) => v
        Err(_) => return Err("Invalid Dest Ext Addr")
      }
      dest_addr = ExtendedAddress(addr)
    }
    None => ()
  }

  let mut src_pan : UInt? = None
  let mut src_addr : MacAddress = NoneAddress

  if fcf.pan_id_compression {
    src_pan = dest_pan
  } else if fcf.src_addr_mode != None {
    let pan = match reader.read_u32(16) {
      Ok(v) => v
      Err(_) => return Err("Invalid Src PAN ID")
    }
    src_pan = Some(pan)
  }

  match fcf.src_addr_mode {
    Short16 => {
      let addr = match reader.read_u32(16) {
        Ok(v) => v
        Err(_) => return Err("Invalid Src Short Addr")
      }
      src_addr = ShortAddress(addr)
    }
    Extended64 => {
      let addr = match reader.read_u64(64) {
        Ok(v) => v
        Err(_) => return Err("Invalid Src Ext Addr")
      }
      src_addr = ExtendedAddress(addr)
    }
    None => ()
  }

  let remaining_bits = reader.remaining_bits()
  if remaining_bits < 16 {
    return Err("Missing FCS")
  }

  let payload_len = (remaining_bits - 16) / 8
  let payload = match reader.read_bytes(payload_len) {
    Ok(b) => b
    Err(_) => return Err("Invalid Payload")
  }

  let fcs = match reader.read_u32(16) {
    Ok(v) => v
    Err(_) => return Err("Invalid FCS")
  }

  let header : MacFrameHeader = {
    fcf,
    seq_num,
    dest_pan_id: dest_pan,
    dest_addr,
    src_pan_id: src_pan,
    src_addr,
    aux_sec: None,
  }

  Ok(MacFrame::new(header, payload, fcs~))
}
