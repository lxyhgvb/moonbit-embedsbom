///|
pub(all) struct ChannelStats {
  mut total_sent : Int
  mut total_delivered : Int
  mut total_dropped : Int
  mut total_duplicated : Int
  mut total_reordered : Int
  mut total_collisions : Int
} derive(Eq, Debug)

///|
pub fn ChannelStats::new() -> ChannelStats {
  {
    total_sent: 0,
    total_delivered: 0,
    total_dropped: 0,
    total_duplicated: 0,
    total_reordered: 0,
    total_collisions: 0,
  }
}

///|
pub fn ChannelStats::packet_loss_ratio(self : ChannelStats) -> Double {
  if self.total_sent == 0 {
    0.0
  } else {
    self.total_dropped.to_double() / self.total_sent.to_double()
  }
}

///|
pub fn ChannelStats::delivery_success_ratio(self : ChannelStats) -> Double {
  if self.total_sent == 0 {
    0.0
  } else {
    self.total_delivered.to_double() / self.total_sent.to_double()
  }
}
