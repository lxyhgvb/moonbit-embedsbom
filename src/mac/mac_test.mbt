///|
test "mac: CSMA backoff step calculation" {
  let params = CsmaParams::default()
  let state = CsmaState::new(params)

  let res1 = state.perform_backoff_step(params, true, 42U)
  assert_true(res1 is ChannelClear(_))

  let res2 = state.perform_backoff_step(params, false, 100U)
  assert_eq(res2, ChannelBusy(1))
  assert_eq(state.be, 4)
}

///|
test "mac: ACK construction and tracking" {
  let ack_frame = build_ack_frame(77)
  assert_eq(ack_frame.header.fcf.frame_type, Ack)
  assert_eq(ack_frame.header.seq_num, 77)

  let manager = AckManager::new(timeout_ms=50UL)
  manager.track_sent_frame(77, 1000UL)
  manager.track_sent_frame(88, 1000UL)

  assert_true(manager.process_ack(77))
  assert_false(manager.process_ack(77))

  let expired = manager.get_expired_acks(1060UL)
  assert_eq(expired.length(), 1)
  assert_eq(expired[0], 88)
}

///|
test "mac: retry stats collector" {
  let stats = RetryStats::new()
  stats.record_success(2)
  stats.record_failure(3)
  assert_eq(stats.total_transmissions, 2)
  assert_eq(stats.successful_deliveries, 1)
  assert_eq(stats.dropped_frames, 1)
  assert_eq(stats.total_retries, 5)
}
