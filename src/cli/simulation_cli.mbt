///|
pub(all) struct CliSimulationConfig {
  node_count : Int
  loss_rate_ppm : Int
  duration_steps : Int
} derive(Eq, Debug)

///|
pub fn CliSimulationConfig::default() -> CliSimulationConfig {
  { node_count: 5, loss_rate_ppm: 20000, duration_steps: 100 }
}

///|
pub fn run_cli_simulation(config : CliSimulationConfig) -> String {
  let ch_config : @channel.ChannelConfig = {
    loss_rate_ppm: config.loss_rate_ppm,
    duplicate_rate_ppm: 2000,
    reorder_rate_ppm: 5000,
    base_latency_ms: 2UL,
    jitter_ms: 1UL,
    enable_collision: true,
    collision_window_ms: 1UL,
  }
  let simulator = @channel.ChannelSimulator::new(ch_config)
  let tracker = @energy.EnergyTracker::new()
  let radio_profile = @energy.RadioProfile::cc2530_default()

  let payload = Bytes::from_array([
    (0x54).to_byte(),
    (0x65).to_byte(),
    (0x73).to_byte(),
    (0x74).to_byte(),
  ])

  for step = 0; step < config.duration_steps; step = step + 1 {
    let now_ms = (step * 10).reinterpret_as_uint().to_uint64()
    let sender_id = (step % config.node_count + 1).reinterpret_as_uint()
    let receiver_id = ((step + 1) % config.node_count + 1).reinterpret_as_uint()

    let _ = simulator.transmit_bytes(payload, sender_id, receiver_id, now_ms)
    tracker.add_duration(Transmit, 1.2)
    tracker.add_duration(Receive, 2.0)
    tracker.add_duration(Sleep, 6.8)

    let _ = simulator.step(now_ms + 5UL)
  }

  let buf = StringBuilder::new()
  buf.write_string("=== MoonBit Wireless Link Simulation Report ===\n")
  buf.write_string(
    "Total Simulated Nodes: " + config.node_count.to_string() + "\n",
  )
  buf.write_string(
    "Configured Loss Rate: " +
    (config.loss_rate_ppm / 10000).to_string() +
    "%\n",
  )
  buf.write_string(
    "Total Transmissions Sent: " + simulator.stats.total_sent.to_string() + "\n",
  )
  buf.write_string(
    "Successfully Delivered: " +
    simulator.stats.total_delivered.to_string() +
    "\n",
  )
  buf.write_string(
    "Packets Dropped (Loss): " +
    simulator.stats.total_dropped.to_string() +
    "\n",
  )
  buf.write_string(
    "Collisions Occurred: " +
    simulator.stats.total_collisions.to_string() +
    "\n",
  )
  buf.write_string(
    "Duplicated Packets: " + simulator.stats.total_duplicated.to_string() + "\n",
  )
  let per_pct = (simulator.stats.packet_loss_ratio() * 100.0).to_string()
  buf.write_string("Packet Error Rate (PER): " + per_pct + "%\n")

  let energy_joules = tracker.total_energy_joules(radio_profile).to_string()
  buf.write_string("Energy Consumed: " + energy_joules + " Joules\n")
  let est_days = tracker
    .estimate_battery_lifetime_days(radio_profile, 500.0)
    .to_string()
  buf.write_string("Est. Battery Life (500mAh): " + est_days + " Days\n")
  buf.to_string()
}
