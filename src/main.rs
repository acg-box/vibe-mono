mod cli;
use cli::Cli;

// crates.io
use anyhow::Result;
use clap::Parser;

fn main() -> Result<()> {
	color_eyre::install().unwrap();
	tracing_subscriber::fmt::init();

	Cli::parse().run()?;

	Ok(())
}
