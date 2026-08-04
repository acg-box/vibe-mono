#!/usr/bin/env bash

set -euo pipefail

candidate="${1:?linker candidate is required}"
target=x86_64-unknown-linux-gnu
target_dir="${RUNNER_TEMP:?RUNNER_TEMP is required}/target-${candidate}"
binary="${target_dir}/${target}/final-release/name_placeholder"
link_log="${RUNNER_TEMP}/link-${candidate}.tsv"
summary="${GITHUB_STEP_SUMMARY:?GITHUB_STEP_SUMMARY is required}"

export BENCHMARK_LINKER="${candidate}"
export CARGO_TARGET_DIR="${target_dir}"
export LINK_TIME_LOG="${link_log}"

duration_ms() {
	local start_ns="$1"
	local end_ns="$2"
	echo $(((end_ns - start_ns) / 1000000))
}

timing_json() {
	local timing_file="$1"
	sed -n '/^const UNIT_DATA = \[/,/^\];$/p' "${timing_file}" \
		| sed '1s/^const UNIT_DATA = / /;$s/^];$/]/'
}

run_sample() {
	local sample="$1"
	local resource_log="${RUNNER_TEMP}/${candidate}-${sample}-cargo.tsv"
	local start_ns
	local end_ns
	local timing_file
	local cargo_seconds
	local unit
	local workspace_start
	local workspace_seconds
	local link_seconds
	local codegen_lto_seconds
	local -a rustc_args

	: > "${link_log}"
	rustc_args=(-C "linker=${GITHUB_WORKSPACE}/.github/scripts/linker-benchmark-driver.sh")
	if [[ "${candidate}" == "mold" ]]; then
		if [[ -z "${MOLD_LIBEXEC:-}" || ! -x "${MOLD_LIBEXEC}/ld" ]]; then
			echo "The pinned mold linker is unavailable at MOLD_LIBEXEC." >&2
			exit 127
		fi
		rustc_args+=(
			-C link-self-contained=-linker
			-C "link-arg=-B${MOLD_LIBEXEC}"
		)
	fi
	start_ns="$(date +%s%N)"
	/usr/bin/time \
		--output "${resource_log}" \
		--format 'elapsed=%e\tuser=%U\tsystem=%S\tmax_rss_kib=%M\texit=%x' \
		cargo rustc \
			-p name_placeholder \
			--profile final-release \
			--locked \
			--target "${target}" \
			--timings \
			-- "${rustc_args[@]}"
	end_ns="$(date +%s%N)"

	timing_file="$(find "${target_dir}/cargo-timings" -type f -name 'cargo-timing-*.html' -printf '%T@ %p\n' \
		| sort -nr | head -n 1 | cut -d ' ' -f 2-)"
	cargo_seconds="$(sed -n 's/^DURATION = \([0-9.]*\);$/\1/p' "${timing_file}")"
	unit="$(timing_json "${timing_file}" \
		| jq -c '.[] | select(.name == "name_placeholder" and (.target | contains("\\\"bin\\\"")))')"
	workspace_start="$(jq -r '.start' <<< "${unit}")"
	workspace_seconds="$(jq -r '.duration' <<< "${unit}")"

	if [[ "$(wc -l < "${link_log}" | tr -d ' ')" -ne 1 ]]; then
		echo "Expected one target linker invocation for ${candidate}/${sample}." >&2
		cat "${link_log}" >&2
		exit 1
	fi
	link_seconds="$(awk -F '\t' 'NR == 1 { print $2 }' "${link_log}")"
	codegen_lto_seconds="$(awk -v unit="${workspace_seconds}" -v link="${link_seconds}" \
		'BEGIN { value = unit - link; if (value < 0) value = 0; printf "%.3f", value }')"

	printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
		"${candidate}" "${sample}" "$(duration_ms "${start_ns}" "${end_ns}")" \
		"${cargo_seconds}" "${workspace_start}" "${codegen_lto_seconds}" "${link_seconds}" \
		| tee -a "${RUNNER_TEMP}/linker-benchmark.tsv"
	cat "${resource_log}"
	cat "${link_log}"
}

printf 'linker\tsample\twall_ms\tcargo_s\tdependency_ready_s\tworkspace_codegen_plus_fat_lto_s\tfinal_link_s\n' \
	| tee "${RUNNER_TEMP}/linker-benchmark.tsv"

fetch_start="$(date +%s%N)"
cargo fetch --locked --target "${target}"
fetch_end="$(date +%s%N)"
fetch_ms="$(duration_ms "${fetch_start}" "${fetch_end}")"

run_sample cold
cold_sha="$(sha256sum "${binary}" | cut -d ' ' -f 1)"

for sample in warm-1 warm-2 warm-3; do
	cargo clean \
		-p name_placeholder \
		--profile final-release \
		--target "${target}" \
		--target-dir "${target_dir}"
	run_sample "${sample}"
	current_sha="$(sha256sum "${binary}" | cut -d ' ' -f 1)"
	if [[ "${current_sha}" != "${cold_sha}" ]]; then
		echo "The ${candidate} binary is not reproducible between cold and ${sample}." >&2
		exit 1
	fi
done

version_output="$("${binary}" --version)"
case "${version_output}" in
	*"${BENCHMARK_SOURCE_SHA:?BENCHMARK_SOURCE_SHA is required}-${target}"*) ;;
	*)
		echo "Unexpected version identity: ${version_output}" >&2
		exit 1
		;;
esac

file "${binary}" | tee "${RUNNER_TEMP}/${candidate}-file.txt"
grep -q 'ELF 64-bit.*x86-64' "${RUNNER_TEMP}/${candidate}-file.txt"
readelf --file-header "${binary}"
readelf --notes "${binary}"
readelf --string-dump=.comment "${binary}" | tee "${RUNNER_TEMP}/${candidate}-comment.txt"
readelf --sections "${binary}" | tee "${RUNNER_TEMP}/${candidate}-sections.txt"
grep -q '\.symtab' "${RUNNER_TEMP}/${candidate}-sections.txt"
grep -q '\.eh_frame' "${RUNNER_TEMP}/${candidate}-sections.txt"

case "${candidate}" in
	current) grep -qi 'LLD' "${RUNNER_TEMP}/${candidate}-comment.txt" ;;
	mold) grep -qi "mold ${MOLD_VERSION:?MOLD_VERSION is required}" "${RUNNER_TEMP}/${candidate}-comment.txt" ;;
esac

set +e
"${binary}" --linker-benchmark-invalid \
	> "${RUNNER_TEMP}/${candidate}-invalid.stdout" \
	2> "${RUNNER_TEMP}/${candidate}-invalid.stderr"
invalid_status=$?
set -e
if [[ "${invalid_status}" -eq 0 || ! -s "${RUNNER_TEMP}/${candidate}-invalid.stderr" ]]; then
	echo "The invalid-argument diagnostic contract failed for ${candidate}." >&2
	exit 1
fi
invalid_sha="$(sha256sum "${RUNNER_TEMP}/${candidate}-invalid.stderr" | cut -d ' ' -f 1)"

set +e
HOME=/proc/1 XDG_DATA_HOME=/proc/1/vibe-linker-benchmark RUST_BACKTRACE=full \
	"${binary}" --version \
	> "${RUNNER_TEMP}/${candidate}-backtrace.stdout" \
	2> "${RUNNER_TEMP}/${candidate}-backtrace.stderr"
backtrace_status=$?
set -e
if [[ "${backtrace_status}" -eq 0 || ! -s "${RUNNER_TEMP}/${candidate}-backtrace.stderr" ]]; then
	echo "The startup-error diagnostic contract failed for ${candidate}." >&2
	exit 1
fi
backtrace_present=false
if grep -Eqi 'backtrace|stack trace' "${RUNNER_TEMP}/${candidate}-backtrace.stderr"; then
	backtrace_present=true
fi

startup_start="$(date +%s%N)"
for _ in $(seq 1 50); do
	"${binary}" --version > /dev/null
done
startup_end="$(date +%s%N)"
startup_50_ms="$(duration_ms "${startup_start}" "${startup_end}")"

package_dir="${RUNNER_TEMP}/package-${candidate}"
mkdir -p "${package_dir}"
cp "${binary}" "${package_dir}/name_placeholder"
archive="${RUNNER_TEMP}/name_placeholder-${candidate}-x86_64-unknown-linux-gnu.tar.gz"
package_start="$(date +%s%N)"
tar -czf "${archive}" -C "${package_dir}" name_placeholder
package_end="$(date +%s%N)"
tar -tzf "${archive}"

binary_size="$(stat --format '%s' "${binary}")"
archive_size="$(stat --format '%s' "${archive}")"
archive_sha="$(sha256sum "${archive}" | cut -d ' ' -f 1)"
package_ms="$(duration_ms "${package_start}" "${package_end}")"

{
	echo "## ${candidate} linker benchmark"
	echo
	echo "- source: \`${BENCHMARK_SOURCE_SHA}\`"
	echo "- Cargo.lock SHA-256: \`${BENCHMARK_LOCK_SHA256}\`"
	echo "- runner: \`${RUNNER_NAME}\` / \`${RUNNER_ARCH}\` / \`${ImageOS:-unknown}\`"
	echo "- setup: ${LINKER_SETUP_MS:?LINKER_SETUP_MS is required} ms; fetch: ${fetch_ms} ms"
	echo "- binary: ${binary_size} bytes; SHA-256 \`${cold_sha}\`"
	echo "- archive: ${archive_size} bytes; package ${package_ms} ms; SHA-256 \`${archive_sha}\`"
	echo "- 50 startup/version runs: ${startup_50_ms} ms"
	echo "- invalid-argument status: ${invalid_status}; stderr SHA-256 \`${invalid_sha}\`"
	echo "- startup-error status: ${backtrace_status}; backtrace marker: ${backtrace_present}"
	echo
	echo '```text'
	cat "${RUNNER_TEMP}/linker-benchmark.tsv"
	echo '```'
} >> "${summary}"

echo "artifact_path=${archive}" >> "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"
