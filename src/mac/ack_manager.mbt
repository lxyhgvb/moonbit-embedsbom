///|
pub fn build_ack_frame(seq_num : Int) -> @frame.MacFrame {
  let fcf = @frame.FrameControlField::new(
    frame_type=Ack,
    security_enabled=false,
    ack_request=false,
    pan_id_compression=false,
    dest_addr_mode=None,
    src_addr_mode=None,
  )
  let header : @frame.MacFrameHeader = {
    fcf,
    seq_num,
    dest_pan_id: None,
    dest_addr: NoneAddress,
    src_pan_id: None,
    src_addr: NoneAddress,
    aux_sec: None,
  }
  @frame.MacFrame::new(header, Bytes::new(0))
}

///|
pub(all) struct PendingAck {
  seq_num : Int
  timestamp_ms : UInt64
  retry_count : Int
} derive(Eq, Debug)

///|
pub(all) struct AckManager {
  timeout_ms : UInt64
  pending : Array[PendingAck]
} derive(Eq, Debug)

///|
pub fn AckManager::new(timeout_ms? : UInt64 = 100UL) -> AckManager {
  { timeout_ms, pending: Array::new() }
}

///|
pub fn AckManager::track_sent_frame(
  self : AckManager,
  seq_num : Int,
  current_time_ms : UInt64,
) -> Unit {
  self.pending.push({ seq_num, timestamp_ms: current_time_ms, retry_count: 0 })
}

///|
pub fn AckManager::process_ack(self : AckManager, ack_seq_num : Int) -> Bool {
  for i = 0; i < self.pending.length(); i = i + 1 {
    if self.pending[i].seq_num == ack_seq_num {
      let _ = self.pending.remove(i)
      return true
    }
  }
  false
}

///|
pub fn AckManager::get_expired_acks(
  self : AckManager,
  current_time_ms : UInt64,
) -> Array[Int] {
  let expired = Array::new()
  let mut i = 0
  while i < self.pending.length() {
    if current_time_ms >= self.pending[i].timestamp_ms + self.timeout_ms {
      expired.push(self.pending[i].seq_num)
      let _ = self.pending.remove(i)
    } else {
      i = i + 1
    }
  }
  expired
}
