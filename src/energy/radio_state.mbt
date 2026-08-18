///|
pub(all) enum RadioState {
  Sleep
  IdleListen
  Transmit
  Receive
  Cca
} derive(Eq, Debug)

///|
pub(all) struct RadioProfile {
  sleep_current_ma : Double
  idle_current_ma : Double
  tx_current_ma : Double
  rx_current_ma : Double
  cca_current_ma : Double
  supply_voltage_v : Double
} derive(Eq, Debug)

///|
pub fn RadioProfile::cc2530_default() -> RadioProfile {
  {
    sleep_current_ma: 0.001, // 1 uA
    idle_current_ma: 5.0, // 5 mA
    tx_current_ma: 29.0, // 29 mA at 4.5 dBm
    rx_current_ma: 24.0, // 24 mA
    cca_current_ma: 24.0,
    supply_voltage_v: 3.0,
  }
}
