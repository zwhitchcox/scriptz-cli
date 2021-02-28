extern crate clap;
use clap::{App, Arg, SubCommand};

fn get_app() {
  let matches = App::new("Scriptz")
    .version("0.0.1")
    .author("Zane Hitchcox")
    .about("Run scriptz from https://scriptz.sh")
    .subcommand(
      SubCommand::with_name("run")
        .about("controls testing features")
        .version("1.3")
        .author("Someone E. <someone_else@other.com>")
        .arg(
          Arg::with_name("debug")
            .short("d")
            .help("print debug information verbosely"),
        ),
    )
    .get_matches();
}
