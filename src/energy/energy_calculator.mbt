///|
pub(all) struct EnergyTracker {
  mut sleep_duration_ms : Double
  mut idle_duration_ms : Double
  mut tx_duration_ms : Double
  mut rx_duration_ms : Double
  mut cca_duration_ms : Double
} derive(Eq, Debug)

///|
pub fn EnergyTracker::new() -> EnergyTracker {
  {
    sleep_duration_ms: 0.0,
    idle_duration_ms: 0.0,
    tx_duration_ms: 0.0,
    rx_duration_ms: 0.0,
    cca_duration_ms: 0.0,
  }
}

///|
pub fn EnergyTracker::add_duration(
  self : EnergyTracker,
  state : RadioState,
  duration_ms : Double,
) -> Unit {
  match state {
    Sleep => self.sleep_duration_ms = self.sleep_duration_ms + duration_ms
    IdleListen => self.idle_duration_ms = self.idle_duration_ms + duration_ms
    Transmit => self.tx_duration_ms = self.tx_duration_ms + duration_ms
    Receive => self.rx_duration_ms = self.rx_duration_ms + duration_ms
    Cca => self.cca_duration_ms = self.cca_duration_ms + duration_ms
  }
}

///|
pub fn EnergyTracker::total_charge_mah(
  self : EnergyTracker,
  profile : RadioProfile,
) -> Double {
  let ms_to_hours = 1.0 / 3600000.0
  let sleep_mah = self.sleep_duration_ms *
    profile.sleep_current_ma *
    ms_to_hours
  let idle_mah = self.idle_duration_ms * profile.idle_current_ma * ms_to_hours
  let tx_mah = self.tx_duration_ms * profile.tx_current_ma * ms_to_hours
  let rx_mah = self.rx_duration_ms * profile.rx_current_ma * ms_to_hours
  let cca_mah = self.cca_duration_ms * profile.cca_current_ma * ms_to_hours

  sleep_mah + idle_mah + tx_mah + rx_mah + cca_mah
}

///|
pub fn EnergyTracker::total_energy_joules(
  self : EnergyTracker,
  profile : RadioProfile,
) -> Double {
  let mah = self.total_charge_mah(profile)
  // Joules = mAh * 3.6 * Volts
  mah * 3.6 * profile.supply_voltage_v
}

///|
pub fn EnergyTracker::estimate_battery_lifetime_days(
  self : EnergyTracker,
  profile : RadioProfile,
  battery_capacity_mah : Double,
) -> Double {
  let total_ms = self.sleep_duration_ms +
    self.idle_duration_ms +
    self.tx_duration_ms +
    self.rx_duration_ms +
    self.cca_duration_ms
  if total_ms <= 0.0 {
    return 0.0
  }
  let charge_used = self.total_charge_mah(profile)
  let avg_current_ma = charge_used / (total_ms / 3600000.0)
  if avg_current_ma <= 0.0 {
    return 0.0
  }
  let hours = battery_capacity_mah / avg_current_ma
  hours / 24.0
}
