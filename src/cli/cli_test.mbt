///|
test "cli_arg_parsing" {
  let args = [
    "scan", "-i", "moon.mod", "-f", "cyclonedx", "-a", "cortex-m4", "-b", "STM32F407",
  ]
  let opts = parse_cli_args(args)
  assert_eq(opts.command, CommandKind::Scan)
  assert_eq(opts.input_file, "moon.mod")
  assert_eq(opts.format, "cyclonedx")
  assert_eq(opts.mcu_arch, "cortex-m4")
  assert_eq(opts.board_model, "STM32F407")
}

///|
test "cli_runner_execution" {
  let help_out = run_cli(["help"])
  assert_true(help_out.contains("USAGE:"))

  let version_out = run_cli(["version"])
  assert_true(version_out.contains("v1.0.0"))

  let scan_out = run_cli(["scan", "-f", "spdx"])
  assert_true(scan_out.contains("SPDX-2.3"))

  let lic_out = run_cli(["licenses"])
  assert_true(lic_out.contains("License Audit Results"))

  let validate_out = run_cli(["validate"])
  assert_true(validate_out.contains("PASSED"))
}
