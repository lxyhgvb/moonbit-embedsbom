///|
/// CommandKind defines supported subcommand operations in embedsbom CLI.
pub(all) enum CommandKind {
  Scan
  Licenses
  Graph
  Validate
  Export
  Help
  Version
} derive(Eq, Debug)

///|
/// CliOptions encapsulates parsed command line parameters.
pub(all) struct CliOptions {
  mut command : CommandKind
  mut input_file : String
  mut output_file : String
  mut format : String
  mut mcu_arch : String
  mut board_model : String
  mut strict : Bool
} derive(Eq, Debug)

///|
/// Creates default CliOptions structure.
pub fn CliOptions::new() -> CliOptions {
  {
    command: Scan,
    input_file: "moon.mod",
    output_file: "",
    format: "spdx",
    mcu_arch: "arm-cortex-m4",
    board_model: "generic-mcu-board",
    strict: false,
  }
}

///|
/// Parses string arguments array into CliOptions structure.
pub fn parse_cli_args(args : Array[String]) -> CliOptions {
  let opts = CliOptions::new()
  if args.length() == 0 {
    opts.command = Help
    return opts
  }

  let subcmd = args[0].to_lower()
  if subcmd == "scan" {
    opts.command = Scan
  } else if subcmd == "licenses" || subcmd == "license" {
    opts.command = Licenses
  } else if subcmd == "graph" {
    opts.command = Graph
  } else if subcmd == "validate" || subcmd == "check" {
    opts.command = Validate
  } else if subcmd == "export" {
    opts.command = Export
  } else if subcmd == "version" || subcmd == "-v" || subcmd == "--version" {
    opts.command = Version
    return opts
  } else {
    opts.command = Help
    return opts
  }

  let mut i = 1
  while i < args.length() {
    let arg = args[i]
    if (arg == "-i" || arg == "--input") && i + 1 < args.length() {
      opts.input_file = args[i + 1]
      i = i + 2
    } else if (arg == "-o" || arg == "--output") && i + 1 < args.length() {
      opts.output_file = args[i + 1]
      i = i + 2
    } else if (arg == "-f" || arg == "--format") && i + 1 < args.length() {
      opts.format = args[i + 1]
      i = i + 2
    } else if (arg == "-a" || arg == "--arch") && i + 1 < args.length() {
      opts.mcu_arch = args[i + 1]
      i = i + 2
    } else if (arg == "-b" || arg == "--board") && i + 1 < args.length() {
      opts.board_model = args[i + 1]
      i = i + 2
    } else if arg == "--strict" {
      opts.strict = true
      i = i + 1
    } else {
      i = i + 1
    }
  }

  opts
}
