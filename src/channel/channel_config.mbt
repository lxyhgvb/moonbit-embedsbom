///|
pub(all) struct ChannelConfig {
  loss_rate_ppm : Int // Parts per million (0 to 1,000,000)
  duplicate_rate_ppm : Int
  reorder_rate_ppm : Int
  base_latency_ms : UInt64
  jitter_ms : UInt64
  enable_collision : Bool
  collision_window_ms : UInt64
} derive(Eq, Debug)

///|
pub fn ChannelConfig::ideal() -> ChannelConfig {
  {
    loss_rate_ppm: 0,
    duplicate_rate_ppm: 0,
    reorder_rate_ppm: 0,
    base_latency_ms: 1UL,
    jitter_ms: 0UL,
    enable_collision: false,
    collision_window_ms: 1UL,
  }
}

///|
pub fn ChannelConfig::typical_iot() -> ChannelConfig {
  {
    loss_rate_ppm: 50000, // 5% packet loss
    duplicate_rate_ppm: 5000, // 0.5% duplicate
    reorder_rate_ppm: 10000, // 1% reorder
    base_latency_ms: 5UL,
    jitter_ms: 3UL,
    enable_collision: true,
    collision_window_ms: 2UL,
  }
}
