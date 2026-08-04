#!/usr/bin/env bash

set -euo pipefail

exec /usr/bin/time \
	--append \
	--output "${LINK_TIME_LOG:?LINK_TIME_LOG is required}" \
	--format "${BENCHMARK_LINKER:?BENCHMARK_LINKER is required}\t%e\t%U\t%S\t%M\t%x\t%C" \
	cc "$@"
