///|
pub(all) enum PathLossModel {
  FreeSpaceFriis(Double) // frequency in MHz (e.g. 2400.0)
  LogDistance(Double, Double, Double) // exponent (n), ref distance (d0), ref loss (PL0)
} derive(Eq, Debug)

///|
pub fn calculate_path_loss_db(
  model : PathLossModel,
  distance_m : Double,
) -> Double {
  let dist = if distance_m < 0.1 { 0.1 } else { distance_m }
  match model {
    FreeSpaceFriis(freq_mhz) => {
      let log_d = @math.log10(dist)
      let log_f = @math.log10(freq_mhz)
      20.0 * log_d + 20.0 * log_f + 32.44
    }
    LogDistance(exponent, ref_dist, ref_loss) => {
      let log_ratio = @math.log10(dist / ref_dist)
      ref_loss + 10.0 * exponent * log_ratio
    }
  }
}

///|
pub fn calculate_rssi_dbm(
  model : PathLossModel,
  tx_power_dbm : Double,
  distance_m : Double,
) -> Double {
  let loss = calculate_path_loss_db(model, distance_m)
  tx_power_dbm - loss
}

///|
pub fn rssi_to_lqi(rssi_dbm : Double, rx_sensitivity_dbm : Double) -> Int {
  if rssi_dbm <= rx_sensitivity_dbm {
    0
  } else {
    let margin = rssi_dbm - rx_sensitivity_dbm
    let lqi = (margin * 5.0).to_int()
    if lqi > 255 {
      255
    } else {
      lqi
    }
  }
}
