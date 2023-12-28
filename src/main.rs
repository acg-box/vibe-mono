// crates.io
use anyhow::Result;

fn main() -> Result<()> {
	color_eyre::install().unwrap();
	tracing_subscriber::fmt::init();

	Ok(())
}
