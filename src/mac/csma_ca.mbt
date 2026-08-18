///|
pub(all) struct CsmaParams {
  min_be : Int // minimum backoff exponent (default 3)
  max_be : Int // maximum backoff exponent (default 5)
  max_csma_backoffs : Int // default 4
  max_frame_retries : Int // default 3
} derive(Eq, Debug)

///|
pub fn CsmaParams::default() -> CsmaParams {
  { min_be: 3, max_be: 5, max_csma_backoffs: 4, max_frame_retries: 3 }
}

///|
pub(all) enum CsmaResult {
  ChannelClear(Int) // backoff periods waited
  ChannelBusy(Int) // attempted backoffs
  BackoffExceeded
  MaxRetriesExceeded
} derive(Eq, Debug)

///|
pub(all) struct CsmaState {
  mut be : Int
  mut nb : Int
  mut retries : Int
} derive(Eq, Debug)

///|
pub fn CsmaState::new(params : CsmaParams) -> CsmaState {
  { be: params.min_be, nb: 0, retries: 0 }
}

///|
pub fn CsmaState::reset(self : CsmaState, params : CsmaParams) -> Unit {
  self.be = params.min_be
  self.nb = 0
  self.retries = 0
}

///|
pub fn CsmaState::perform_backoff_step(
  self : CsmaState,
  params : CsmaParams,
  channel_is_clear : Bool,
  rng_seed : UInt,
) -> CsmaResult {
  if self.nb >= params.max_csma_backoffs {
    return BackoffExceeded
  }

  // Calculate random backoff in [0, 2^BE - 1]
  let max_slots = 1 << self.be
  let backoff_slots = (rng_seed.reinterpret_as_int() & 0x7FFFFFFF) % max_slots

  if channel_is_clear {
    ChannelClear(backoff_slots)
  } else {
    self.nb = self.nb + 1
    self.be = if self.be + 1 < params.max_be {
      self.be + 1
    } else {
      params.max_be
    }
    if self.nb >= params.max_csma_backoffs {
      BackoffExceeded
    } else {
      ChannelBusy(self.nb)
    }
  }
}
