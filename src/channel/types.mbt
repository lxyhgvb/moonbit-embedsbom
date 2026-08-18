///|
pub(all) struct TransmissionEvent {
  frame_id : UInt
  frame_bytes : Bytes
  sender_id : UInt
  receiver_id : UInt
  send_timestamp_ms : UInt64
  deliver_timestamp_ms : UInt64
  is_corrupted : Bool
} derive(Eq, Debug)

///|
pub(all) enum ChannelOutcome {
  Delivered(TransmissionEvent)
  DroppedLoss
  DroppedCollision
  CorruptedIntegrity
  PendingInQueue
} derive(Eq, Debug)
