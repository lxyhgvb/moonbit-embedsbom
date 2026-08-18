///|
pub(all) enum BitOrder {
  MsbFirst
  LsbFirst
} derive(Eq, Debug)

///|
pub(all) enum BitStreamError {
  OutOfBounds(Int, Int) // requested bits, available bits
  InvalidBitWidth(Int) // bit width invalid (e.g. <=0 or >64)
  BufferOverflow
} derive(Eq, Debug)

///|
pub(all) struct BitPosition {
  byte_offset : Int
  bit_offset : Int
} derive(Eq, Debug)
