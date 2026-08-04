#!/usr/bin/env bash

set -euo pipefail

case "${BENCHMARK_LINKER:?BENCHMARK_LINKER is required}" in
	current)
		linker_args=()
		;;
	lld)
		linker_args=(-fuse-ld=lld)
		;;
	mold)
		if [[ -z "${MOLD_LIBEXEC:-}" || ! -x "${MOLD_LIBEXEC}/ld" ]]; then
			echo "The pinned mold linker is unavailable at MOLD_LIBEXEC." >&2
			exit 127
		fi
		linker_args=("-B${MOLD_LIBEXEC}")
		;;
	*)
		echo "Unsupported benchmark linker: ${BENCHMARK_LINKER}" >&2
		exit 2
		;;
esac

exec /usr/bin/time \
	--append \
	--output "${LINK_TIME_LOG:?LINK_TIME_LOG is required}" \
	--format "${BENCHMARK_LINKER}\t%e\t%U\t%S\t%M\t%x\t%C" \
	cc "${linker_args[@]}" "$@"
