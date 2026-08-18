///|
fn main {
  println("==================================================")
  println(" MoonBit RadioFrame Wireless Toolkit v0.1.0 ")
  println("==================================================")
  let config = @cli.CliSimulationConfig::default()
  let report = @cli.run_cli_simulation(config)
  println(report)
}
