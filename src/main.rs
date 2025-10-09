//! <DESCRIPTION>

// #![deny(clippy::all, missing_docs, unused_crate_dependencies)]

mod cli;
use cli::Cli;

mod prelude {
	pub use anyhow::Result;
}
use prelude::*;

// std
use std::{panic, process};
// crates.io
use app_dirs2::{AppDataType, AppInfo};
use clap::Parser;
use tracing_appender::rolling::{RollingFileAppender, Rotation};
use tracing_subscriber::{
	filter::LevelFilter, fmt, layer::SubscriberExt, reload::Layer, util::SubscriberInitExt,
	EnvFilter,
};

const APP_INFO: AppInfo = AppInfo { name: "<NAME>", author: "hack.ink" };

fn main() -> Result<()> {
	color_eyre::install().unwrap();

	let (non_blocking, _guard) = tracing_appender::non_blocking(
		RollingFileAppender::builder()
			.rotation(Rotation::DAILY)
			.filename_suffix("log")
			.build(app_dirs2::get_app_root(AppDataType::UserData, &APP_INFO).unwrap())?,
	);
	let filter =
		EnvFilter::builder().with_default_directive(LevelFilter::INFO.into()).from_env_lossy();
	let (reloadable_filter, filter_handle) = Layer::new(filter);
	let file_layer = fmt::layer().with_ansi(false).with_writer(non_blocking);
	let subscriber = tracing_subscriber::registry().with(reloadable_filter).with(file_layer);
	#[cfg(feature = "dev")]
	let console_layer = fmt::layer();
	#[cfg(feature = "dev")]
	let subscriber = subscriber.with(console_layer);

	subscriber.init();

	let default_hook = panic::take_hook();

	panic::set_hook(Box::new(move |p| {
		default_hook(p);

		process::abort();
	}));
	Cli::parse().run(filter_handle)?;

	Ok(())
}
