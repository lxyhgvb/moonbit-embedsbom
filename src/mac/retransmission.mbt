///|
pub(all) struct RetryStats {
  mut total_transmissions : Int
  mut successful_deliveries : Int
  mut dropped_frames : Int
  mut total_retries : Int
} derive(Eq, Debug)

///|
pub fn RetryStats::new() -> RetryStats {
  {
    total_transmissions: 0,
    successful_deliveries: 0,
    dropped_frames: 0,
    total_retries: 0,
  }
}

///|
pub fn RetryStats::record_success(self : RetryStats, retries : Int) -> Unit {
  self.total_transmissions = self.total_transmissions + 1
  self.successful_deliveries = self.successful_deliveries + 1
  self.total_retries = self.total_retries + retries
}

///|
pub fn RetryStats::record_failure(self : RetryStats, retries : Int) -> Unit {
  self.total_transmissions = self.total_transmissions + 1
  self.dropped_frames = self.dropped_frames + 1
  self.total_retries = self.total_retries + retries
}
