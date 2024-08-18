// crates.io
use anyhow::Result;
use clap::{
	builder::{
		styling::{AnsiColor, Effects},
		Styles,
	},
	Parser,
};
use tracing_subscriber::{reload::Handle, EnvFilter, Registry};

/// Cli.
#[derive(Debug, Parser)]
#[command(
	version = concat!(
		env!("CARGO_PKG_VERSION"),
		"-",
		env!("VERGEN_GIT_SHA"),
		"-",
		env!("VERGEN_CARGO_TARGET_TRIPLE"),
	),
	about,
	rename_all = "kebab",
	styles = styles(),
)]
pub struct Cli {
	/// Placeholder.
	#[arg(long, short, value_name = "NUM", default_value_t = String::from("Welcome to use rust-initializer!"))]
	placeholder: String,
}
impl Cli {
	pub fn run(&self, _log_filter_handle: Handle<EnvFilter, Registry>) -> Result<()> {
		dbg!(self);

		Ok(())
	}
}

fn styles() -> Styles {
	Styles::styled()
		.header(AnsiColor::Red.on_default() | Effects::BOLD)
		.usage(AnsiColor::Red.on_default() | Effects::BOLD)
		.literal(AnsiColor::Blue.on_default() | Effects::BOLD)
		.placeholder(AnsiColor::Green.on_default())
}
