#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${MOLD_LIBEXEC:-}" || ! -x "${MOLD_LIBEXEC}/ld" ]]; then
	echo "The pinned mold linker is unavailable at MOLD_LIBEXEC." >&2
	exit 127
fi

exec cc "-B${MOLD_LIBEXEC}" "$@"
