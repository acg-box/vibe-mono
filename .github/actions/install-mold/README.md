# Install pinned mold

This composite action installs the official mold binary archive for a supported
Linux runner architecture. It requires the caller to provide both the release
version and the expected SHA-256 digest.

The action fails on non-Linux runners, unsupported architectures, missing tools,
checksum mismatch, archive layout mismatch, or a version mismatch. It does not
replace `/usr/bin/ld` or change the runner's global linker. Use the `mold_libexec`
output with a compiler-driver `-B` option, or use the `mold_binary` output with a
toolchain-specific absolute-path option.

Use the action from another repository at a released commit or major tag:

```yaml
- id: mold
  uses: acg-box/vibe-mono/.github/actions/install-mold@v1
  with:
    version: 2.41.0
    sha256: a3696680d99e692970590a178bc3a33d78d60d1c6dc9db7a11b557b02b751f5d

- name: Build with mold
  run: cargo rustc --locked -- -C linker-features=-lld -C link-self-contained=-linker -C "link-arg=-B${{ steps.mold.outputs.mold_libexec }}"
```

For strict supply-chain control, replace `v1` with the full commit SHA for the
reviewed action release. The digest must match the official archive for the host
architecture. The action currently recognizes `x86_64`, `aarch64`, `arm`,
`loongarch64`, `ppc64le`, `riscv64`, and `s390x` Linux archives.
