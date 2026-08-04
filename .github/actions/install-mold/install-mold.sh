#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf '::error::%s\n' "$*" >&2
  exit 1
}

: "${MOLD_VERSION:?MOLD_VERSION is required}"
: "${MOLD_SHA256:?MOLD_SHA256 is required}"
: "${RUNNER_TEMP:?RUNNER_TEMP is required}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"
: "${GITHUB_PATH:?GITHUB_PATH is required}"

[[ "${RUNNER_OS:-}" == Linux ]] || fail "mold supports Linux runners only"
[[ "$(uname -s)" == Linux ]] || fail "mold requires a Linux host"

case "$(uname -m)" in
  x86_64)
    archive_architecture=x86_64
    ;;
  aarch64)
    archive_architecture=aarch64
    ;;
  armv7l|armv7*)
    archive_architecture=arm
    ;;
  loongarch64)
    archive_architecture=loongarch64
    ;;
  ppc64le)
    archive_architecture=ppc64le
    ;;
  riscv64)
    archive_architecture=riscv64
    ;;
  s390x)
    archive_architecture=s390x
    ;;
  *)
    fail "unsupported Linux runner architecture: $(uname -m)"
    ;;
esac

[[ "${MOLD_VERSION}" =~ ^[0-9]+(\.[0-9]+)*$ ]] || fail "invalid mold version: ${MOLD_VERSION}"
[[ "${MOLD_SHA256}" =~ ^[[:xdigit:]]{64}$ ]] || fail "invalid mold SHA-256 digest"

for command in curl grep sha256sum tar; do
  command -v "${command}" >/dev/null 2>&1 || fail "required command is missing: ${command}"
done

archive="${RUNNER_TEMP}/mold-${MOLD_VERSION}-${archive_architecture}-linux.tar.gz"
root="${RUNNER_TEMP}/mold-${MOLD_VERSION}-${archive_architecture}-linux"
url="https://github.com/rui314/mold/releases/download/v${MOLD_VERSION}/mold-${MOLD_VERSION}-${archive_architecture}-linux.tar.gz"

rm -f "${archive}"
rm -rf "${root}"

curl --fail --location --silent --show-error \
  --proto '=https' --tlsv1.2 --retry 3 --retry-connrefused \
  --output "${archive}" "${url}"

if ! printf '%s  %s\n' "${MOLD_SHA256}" "${archive}" | sha256sum --check --strict; then
  fail "mold archive checksum mismatch"
fi

tar -xzf "${archive}" -C "${RUNNER_TEMP}"

mold_binary="${root}/bin/mold"
mold_libexec="${root}/libexec/mold"
test -x "${mold_binary}" || fail "mold executable is missing: ${mold_binary}"
test -x "${mold_libexec}/ld" || fail "mold linker shim is missing: ${mold_libexec}/ld"

install_libatomic1() {
  command -v apt-get >/dev/null 2>&1 || return 1

  local -a apt_command=(apt-get)
  if [[ "$(id -u)" -ne 0 ]]; then
    command -v sudo >/dev/null 2>&1 || return 1
    apt_command=(sudo -n apt-get)
  fi

  if command -v dpkg-query >/dev/null 2>&1 \
    && dpkg-query -W -f='${Status}' libatomic1 2>/dev/null \
      | grep -Fq 'install ok installed'; then
    return 0
  fi

  DEBIAN_FRONTEND=noninteractive "${apt_command[@]}" update
  DEBIAN_FRONTEND=noninteractive "${apt_command[@]}" install \
    --no-install-recommends --yes libatomic1
}

if ! reported_version="$("${mold_binary}" --version 2>&1)"; then
  runtime_dependencies=""
  if command -v ldd >/dev/null 2>&1; then
    runtime_dependencies="$(ldd "${mold_binary}" 2>&1 || true)"
  fi

  if grep -Fq 'libatomic.so.1' <<<"${reported_version}${runtime_dependencies}"; then
    if ! install_libatomic1; then
      fail "mold needs libatomic.so.1; install Debian/Ubuntu libatomic1 or provide passwordless sudo"
    fi
    if ! reported_version="$("${mold_binary}" --version 2>&1)"; then
      fail "mold could not start after installing libatomic1: ${reported_version}"
    fi
  else
    fail "mold could not start: ${reported_version}"
  fi
fi

case "${reported_version}" in
  "mold ${MOLD_VERSION}"*) ;;
  *) fail "unexpected mold version: ${reported_version}" ;;
esac

printf 'mold_root=%s\n' "${root}" >>"${GITHUB_OUTPUT}"
printf 'mold_libexec=%s\n' "${mold_libexec}" >>"${GITHUB_OUTPUT}"
printf 'mold_binary=%s\n' "${mold_binary}" >>"${GITHUB_OUTPUT}"
printf 'mold_version=%s\n' "${MOLD_VERSION}" >>"${GITHUB_OUTPUT}"
printf 'archive_architecture=%s\n' "${archive_architecture}" >>"${GITHUB_OUTPUT}"
printf '%s/bin\n' "${root}" >>"${GITHUB_PATH}"

printf 'Verified %s from %s\n' "${reported_version}" "${url}"
