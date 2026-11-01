# Setup hotpath Valgrind

A GitHub Action that installs [hotpath-rs](https://hotpath.rs)'s patched [Valgrind](https://valgrind.org) build on Linux runners, x86_64 and ARM64, for deterministic [Callgrind instruction counts](https://hotpath.rs/callgrind).

Released Valgrind versions (up to at least 3.28.0) misattribute inclusive instruction counts on ARM64: their arm64 decoder treats every plain `B` branch as a call, so Callgrind reports fake recursion and inflated totals. The builds this action installs fix that. On x86_64 they behave like the official release.

> **Unofficial build.** The Valgrind builds come from [hotpath-rs/valgrind](https://github.com/hotpath-rs/valgrind), a fork not affiliated with or endorsed by the Valgrind project. Its [README.hotpath](https://github.com/hotpath-rs/valgrind/blob/hotpath-3.28/README.hotpath) lists every modification.

## Usage

```yaml
jobs:
  benchmark:
    runs-on: ubuntu-26.04-arm # or ubuntu-26.04, ubuntu-24.04, ubuntu-24.04-arm
    steps:
      - uses: actions/checkout@v6
      - uses: hotpath-rs/setup-valgrind@v1.0.0
        with:
          version: 3.28.0.hotpath2
      - run: valgrind --tool=callgrind ./target/release/my_benchmark
```

The action installs the build to `/opt/valgrind` and puts `/opt/valgrind/bin` first on `PATH`, so later steps run `valgrind` directly. Running it again in a job replaces the install.

How to run a benchmark under Callgrind with hotpath and upload the merged report: [CI integration docs](https://hotpath.rs/ci_integration).

## Inputs

| Input | Required | Description |
|---|---|---|
| `version` | yes | Valgrind build, for example `3.28.0.hotpath2`. There is no default and no `latest`: a different build changes instruction counts, so an upgrade should be a deliberate edit that starts new baselines. |

## Outputs

| Output | Description |
|---|---|
| `version` | The installed version, for example `3.28.0.hotpath2`. |
| `valgrind` | Absolute path of the `valgrind` launcher, `/opt/valgrind/bin/valgrind`. |

## Available builds

| `version` | Base | Runners |
|---|---|---|
| `3.28.0.hotpath2` | Valgrind 3.28.0 + arm64 `B` jump-kind fix | Linux x86_64 and ARM64, built on Ubuntu 24.04, tested on 24.04 and 26.04 |

Builds are linked against glibc of Ubuntu 24.04 and run on that and newer distributions. macOS and Windows are not supported by Valgrind.

## Security

- Each action release records the SHA-256 of every build it can install (`checksums.txt`). The download is checked against that, not against the release it comes from, so a replaced file cannot pass.
- Action releases are immutable, and there is no moving `v1` tag: `@v1.0.0` always runs the same code. Pinning the commit SHA (`hotpath-rs/setup-valgrind@<sha> # v1.0.0`) works as well.
- The builds carry GitHub build provenance attestations: `gh attestation verify <file> --repo hotpath-rs/valgrind`.

## License

This action is MIT licensed (`LICENSE.txt`). The Valgrind builds it installs are free software under the GNU General Public License, version 3 or later, with some files under other terms (see `COPYING` in each build and in the [source](https://github.com/hotpath-rs/valgrind)). Each build's complete source is the release tag it was built from.
