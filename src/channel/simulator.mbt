///|
pub(all) struct ChannelSimulator {
  config : ChannelConfig
  queue : Array[TransmissionEvent]
  mut next_frame_id : UInt
  mut rng_state : UInt
  stats : ChannelStats
} derive(Eq, Debug)

///|
pub fn ChannelSimulator::new(
  config : ChannelConfig,
  seed? : UInt = 12345U,
) -> ChannelSimulator {
  {
    config,
    queue: Array::new(),
    next_frame_id: 1U,
    rng_state: seed,
    stats: ChannelStats::new(),
  }
}

///|
fn ChannelSimulator::next_random_ppm(self : ChannelSimulator) -> Int {
  self.rng_state = (self.rng_state * 1103515245U + 12345U) & 0x7FFFFFFFU
  self.rng_state.reinterpret_as_int() % 1000000
}

///|
pub fn ChannelSimulator::transmit_bytes(
  self : ChannelSimulator,
  frame_bytes : Bytes,
  sender_id : UInt,
  receiver_id : UInt,
  now_ms : UInt64,
) -> ChannelOutcome {
  self.stats.total_sent = self.stats.total_sent + 1

  // Check random packet loss
  let loss_rand = self.next_random_ppm()
  if loss_rand < self.config.loss_rate_ppm {
    self.stats.total_dropped = self.stats.total_dropped + 1
    return DroppedLoss
  }

  // Calculate delay with jitter
  let jitter_rand = if self.config.jitter_ms > 0UL {
    let rand_val = self.next_random_ppm().reinterpret_as_uint()
    (rand_val % self.config.jitter_ms.to_uint()).to_uint64()
  } else {
    0UL
  }
  let deliver_ms = now_ms + self.config.base_latency_ms + jitter_rand

  // Check collision with existing transmissions in collision window
  if self.config.enable_collision {
    for i = 0; i < self.queue.length(); i = i + 1 {
      let ev = self.queue[i]
      if ev.receiver_id == receiver_id {
        let diff = if now_ms >= ev.send_timestamp_ms {
          now_ms - ev.send_timestamp_ms
        } else {
          ev.send_timestamp_ms - now_ms
        }
        if diff <= self.config.collision_window_ms {
          self.stats.total_collisions = self.stats.total_collisions + 1
          return DroppedCollision
        }
      }
    }
  }

  let fid = self.next_frame_id
  self.next_frame_id = self.next_frame_id + 1

  let event : TransmissionEvent = {
    frame_id: fid,
    frame_bytes,
    sender_id,
    receiver_id,
    send_timestamp_ms: now_ms,
    deliver_timestamp_ms: deliver_ms,
    is_corrupted: false,
  }

  self.queue.push(event)

  // Check duplicate packet generation
  let dup_rand = self.next_random_ppm()
  if dup_rand < self.config.duplicate_rate_ppm {
    let dup_event : TransmissionEvent = {
      frame_id: self.next_frame_id,
      frame_bytes,
      sender_id,
      receiver_id,
      send_timestamp_ms: now_ms,
      deliver_timestamp_ms: deliver_ms + 2UL,
      is_corrupted: false,
    }
    self.next_frame_id = self.next_frame_id + 1
    self.queue.push(dup_event)
    self.stats.total_duplicated = self.stats.total_duplicated + 1
  }

  PendingInQueue
}

///|
pub fn ChannelSimulator::transmit_mac_frame(
  self : ChannelSimulator,
  frame : @frame.MacFrame,
  sender_id : UInt,
  receiver_id : UInt,
  now_ms : UInt64,
) -> Result[ChannelOutcome, String] {
  match @frame.encode_mac_frame(frame) {
    Ok(encoded) =>
      Ok(self.transmit_bytes(encoded, sender_id, receiver_id, now_ms))
    Err(e) => Err(e)
  }
}

///|
pub fn ChannelSimulator::step(
  self : ChannelSimulator,
  current_time_ms : UInt64,
) -> Array[TransmissionEvent] {
  let ready = Array::new()
  let mut i = 0
  while i < self.queue.length() {
    if current_time_ms >= self.queue[i].deliver_timestamp_ms {
      let ev = self.queue[i]
      ready.push(ev)
      self.stats.total_delivered = self.stats.total_delivered + 1
      let _ = self.queue.remove(i)
    } else {
      i = i + 1
    }
  }
  ready
}
