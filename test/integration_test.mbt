///|
test "integration: full 802.15.4 frame encoding, filtering, transmission and decoding flow" {
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

  // Step 1: Bitstream and Integrity Verification
  let fcs_check = @integrity.CRC16::compute_ieee802154_fcs(payload)
  assert_true(fcs_check > 0U)

  let bit_reader = @bitstream.BitReader::new(payload)
  let first_byte = bit_reader.read_u32(8).unwrap()
  assert_eq(first_byte, 0x53U)

  // Step 2: Filter Evaluation at Receiver Node 2
  let rx_filter_config : @filter.AddressFilterConfig = {
    local_pan_id: 0x1234U,
    local_short_addr: 0x0002U,
    local_ext_addr: 0x02UL,
    promiscuous_mode: false,
    allow_broadcast: true,
  }
  let rx_filter = @filter.AddressFilter::new(rx_filter_config)
  let decision = rx_filter.evaluate_header(frame.header)
  assert_eq(decision, Accept)

  // Step 3: Channel Simulator Transmission
  let sim = @channel.ChannelSimulator::new(@channel.ChannelConfig::ideal())
  let tx_res = sim.transmit_mac_frame(frame, 1U, 2U, 1000UL).unwrap()
  assert_eq(tx_res, PendingInQueue)

  let delivered_events = sim.step(1005UL)
  assert_eq(delivered_events.length(), 1)

  // Step 4: Decode Received Frame & Check FCS Integrity
  let rx_bytes = delivered_events[0].frame_bytes
  let decoded_frame = @frame.decode_mac_frame(rx_bytes).unwrap()
  assert_eq(decoded_frame.header.seq_num, 101)
  assert_eq(
    decoded_frame.header.dest_addr,
    @frame.MacAddress::ShortAddress(0x0002U),
  )
  assert_eq(decoded_frame.payload.length(), 6)
}

///|
test "integration: CSMA/CA backoff with retry and ACK handshake" {
  let csma_params = @mac.CsmaParams::default()
  let csma_state = @mac.CsmaState::new(csma_params)

  // Simulate busy channel twice then clear
  let step1 = csma_state.perform_backoff_step(csma_params, false, 12U)
  assert_eq(step1, ChannelBusy(1))

  let step2 = csma_state.perform_backoff_step(csma_params, false, 45U)
  assert_eq(step2, ChannelBusy(2))

  let step3 = csma_state.perform_backoff_step(csma_params, true, 88U)
  assert_true(step3 is ChannelClear(_))

  // ACK handshake
  let ack_manager = @mac.AckManager::new(timeout_ms=100UL)
  ack_manager.track_sent_frame(101, 1000UL)

  let ack_frame = @mac.build_ack_frame(101)
  let ack_processed = ack_manager.process_ack(ack_frame.header.seq_num)
  assert_true(ack_processed)
}

///|
test "integration: network graph topology, energy tracking and CLI simulation runner" {
  let graph = @topology.NetworkGraph::new(
    model=@topology.PathLossModel::FreeSpaceFriis(2400.0),
  )
  let pos1 : @topology.Position3D = { x: 0.0, y: 0.0, z: 0.0 }
  let pos2 : @topology.Position3D = { x: 5.0, y: 0.0, z: 0.0 }
  let tx_node = @topology.WirelessNode::new(1U, pos1, tx_power_dbm=20.0)
  let rx_node = @topology.WirelessNode::new(2U, pos2, rx_sensitivity_dbm=-100.0)

  graph.add_node(tx_node)
  graph.add_node(rx_node)

  let neighbors = graph.get_reachable_neighbors(1U)
  assert_eq(neighbors.length(), 1)
  assert_eq(neighbors[0].0, 2U)

  let tracker = @energy.EnergyTracker::new()
  let profile = @energy.RadioProfile::cc2530_default()

  // 100 transmissions (1.5ms TX each)
  for i = 0; i < 100; i = i + 1 {
    tracker.add_duration(Transmit, 1.5)
    tracker.add_duration(Sleep, 98.5)
  }

  let mah = tracker.total_charge_mah(profile)
  assert_true(mah > 0.0)

  let joules = tracker.total_energy_joules(profile)
  assert_true(joules > 0.0)

  // Verify CLI runner output
  let cli_config = @cli.CliSimulationConfig::default()
  let report = @cli.run_cli_simulation(cli_config)
  assert_true(report.contains("Wireless Link Simulation Report"))
}
