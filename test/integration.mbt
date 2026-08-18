///|
pub fn run_full_integration_pipeline() -> Bool {
  let fcf = @frame.FrameControlField::new(
    frame_type=Data,
    ack_request=true,
    pan_id_compression=true,
    dest_addr_mode=Short16,
    src_addr_mode=Short16,
  )
  let aux_opt : @frame.AuxSecurityHeader? = None
  let header : @frame.MacFrameHeader = {
    fcf,
    seq_num: 101,
    dest_pan_id: Some(0x1234U),
    dest_addr: @frame.MacAddress::ShortAddress(0x0002U),
    src_pan_id: Some(0x1234U),
    src_addr: @frame.MacAddress::ShortAddress(0x0001U),
    aux_sec: aux_opt,
  }
  let payload = Bytes::from_array([
    (0x53).to_byte(),
    (0x65).to_byte(),
    (0x6E).to_byte(),
    (0x73).to_byte(),
    (0x70).to_byte(),
    (0x72).to_byte(),
  ])
  let frame = @frame.MacFrame::new(header, payload)

  let fcs_check = @integrity.CRC16::compute_ieee802154_fcs(payload)
  if fcs_check == 0U {
    return false
  }

  let bit_reader = @bitstream.BitReader::new(payload)
  let first_byte = match bit_reader.read_u32(8) {
    Ok(v) => v
    Err(_) => return false
  }
  if first_byte != 0x53U {
    return false
  }

  let rx_filter_config : @filter.AddressFilterConfig = {
    local_pan_id: 0x1234U,
    local_short_addr: 0x0002U,
    local_ext_addr: 0x02UL,
    promiscuous_mode: false,
    allow_broadcast: true,
  }
  let rx_filter = @filter.AddressFilter::new(rx_filter_config)
  let decision = rx_filter.evaluate_header(frame.header)
  if decision != Accept {
    return false
  }

  let sim = @channel.ChannelSimulator::new(@channel.ChannelConfig::ideal())
  let tx_res = match sim.transmit_mac_frame(frame, 1U, 2U, 1000UL) {
    Ok(r) => r
    Err(_) => return false
  }
  if tx_res != PendingInQueue {
    return false
  }

  let delivered = sim.step(1005UL)
  if delivered.length() != 1 {
    return false
  }

  let csma_params = @mac.CsmaParams::default()
  let csma_state = @mac.CsmaState::new(csma_params)
  let _ = csma_state.perform_backoff_step(csma_params, true, 88U)

  let graph = @topology.NetworkGraph::new(
    model=@topology.PathLossModel::FreeSpaceFriis(2400.0),
  )
  let pos1 : @topology.Position3D = { x: 0.0, y: 0.0, z: 0.0 }
  let pos2 : @topology.Position3D = { x: 5.0, y: 0.0, z: 0.0 }
  let tx_node = @topology.WirelessNode::new(1U, pos1, tx_power_dbm=20.0)
  let rx_node = @topology.WirelessNode::new(2U, pos2, rx_sensitivity_dbm=-100.0)
  graph.add_node(tx_node)
  graph.add_node(rx_node)

  let tracker = @energy.EnergyTracker::new()
  let profile = @energy.RadioProfile::cc2530_default()
  tracker.add_duration(Transmit, 1.5)
  let _ = tracker.total_energy_joules(profile)

  let cli_config = @cli.CliSimulationConfig::default()
  let report = @cli.run_cli_simulation(cli_config)
  if !report.contains("Simulation") {
    return false
  }

  true
}
