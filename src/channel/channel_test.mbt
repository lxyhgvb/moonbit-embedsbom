///|
test "channel: ideal transmission delivery" {
  let config = ChannelConfig::ideal()
  let sim = ChannelSimulator::new(config)

  let frame_bytes = Bytes::from_array([
    (0x01).to_byte(),
    (0x02).to_byte(),
    (0x03).to_byte(),
  ])
  let res = sim.transmit_bytes(frame_bytes, 1U, 2U, 100UL)
  assert_eq(res, PendingInQueue)

  let delivered = sim.step(105UL)
  assert_eq(delivered.length(), 1)
  assert_eq(delivered[0].sender_id, 1U)
  assert_eq(delivered[0].receiver_id, 2U)
  assert_eq(sim.stats.total_delivered, 1)
}

///|
test "channel: forced packet loss simulation" {
  let config : ChannelConfig = {
    loss_rate_ppm: 1000000, // 100% loss
    duplicate_rate_ppm: 0,
    reorder_rate_ppm: 0,
    base_latency_ms: 1UL,
    jitter_ms: 0UL,
    enable_collision: false,
    collision_window_ms: 1UL,
  }
  let sim = ChannelSimulator::new(config)
  let frame_bytes = Bytes::from_array([(0x01).to_byte()])

  let res = sim.transmit_bytes(frame_bytes, 1U, 2U, 100UL)
  assert_eq(res, DroppedLoss)
  assert_eq(sim.stats.total_dropped, 1)
}

///|
test "channel: collision window detection" {
  let config : ChannelConfig = {
    loss_rate_ppm: 0,
    duplicate_rate_ppm: 0,
    reorder_rate_ppm: 0,
    base_latency_ms: 5UL,
    jitter_ms: 0UL,
    enable_collision: true,
    collision_window_ms: 2UL,
  }
  let sim = ChannelSimulator::new(config)
  let payload = Bytes::from_array([(0xFF).to_byte()])

  let _ = sim.transmit_bytes(payload, 1U, 3U, 100UL)
  let res2 = sim.transmit_bytes(payload, 2U, 3U, 101UL) // within 2ms window

  assert_eq(res2, DroppedCollision)
  assert_eq(sim.stats.total_collisions, 1)
}
