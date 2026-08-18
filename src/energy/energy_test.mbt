///|
test "energy: CC2530 default profile setup" {
  let profile = RadioProfile::cc2530_default()
  assert_eq(profile.sleep_current_ma, 0.001)
  assert_eq(profile.tx_current_ma, 29.0)
  assert_eq(profile.supply_voltage_v, 3.0)
}

///|
test "energy: charge consumption and battery lifetime estimation" {
  let tracker = EnergyTracker::new()
  let profile = RadioProfile::cc2530_default()

  // 99% sleep, 1% receive
  tracker.add_duration(Sleep, 9900.0)
  tracker.add_duration(Receive, 100.0)

  let charge = tracker.total_charge_mah(profile)
  assert_true(charge > 0.0)

  let joules = tracker.total_energy_joules(profile)
  assert_true(joules > 0.0)

  // 1000 mAh battery lifetime
  let days = tracker.estimate_battery_lifetime_days(profile, 1000.0)
  assert_true(days > 100.0)
}
