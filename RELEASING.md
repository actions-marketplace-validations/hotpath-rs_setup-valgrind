# Releasing

Versions are `vMAJOR.MINOR.PATCH` tags of immutable GitHub releases. A published tag is never moved or deleted, and there is no moving `v1` tag. A fix is a new patch release.

## Before the first release (once)

1. **Immutable releases.** Repository **Settings**, section **Releases**: select **Enable release immutability**. It applies only to releases published after it is enabled, so do this before `v1.0.0`.
2. **Tag ruleset** (for tags not yet bound to a release): **Settings** > **Rules** > **Rulesets** > **New ruleset** > **New tag ruleset**, target `v*`, enable **Restrict updates** and **Restrict deletions**, no bypass list.
3. **Marketplace agreement.** Already accepted for `hotpath-rs` with Hotpath Relay.
4. **Two-factor authentication** on the account that publishes.
5. Make sure the name `Setup hotpath Valgrind` is free on the Marketplace; the release form reports a clash.

## Adding a Valgrind build

1. Publish the build in [hotpath-rs/valgrind](https://github.com/hotpath-rs/valgrind) (tag `VALGRIND_<x>_<y>_<z>_HOTPATH_RS`, version `<x>.<y>.<z>.hotpath-rs`).
2. Download its `SHA256SUMS`, check it with `gh attestation verify <file> --repo hotpath-rs/valgrind`, and append the `valgrind-<version>-linux-*.tar.zst` lines to `checksums.txt`.
3. Add the version to the `install` matrix in `.github/workflows/ci.yml` and to "Available builds" in `README.md`.

## Validation (before every release)

1. CI is green on `main`: shellcheck, actionlint, the install job for every build on every runner image, and the unknown-version job.

## Publishing

1. Merge the release commit to `main` (bump every `@vX.Y.Z` in `README.md` in it) and note its full SHA: `git rev-parse origin/main`.
2. Open `action.yml` on GitHub and click **Draft a release** in the banner (or **Releases** > **Draft a new release**).
3. Check **Publish this Action to the GitHub Marketplace** and fix anything reported until it says "Everything looks good!".
4. **Primary Category**: Continuous integration; **Another Category**: Testing.
5. **Tag**: `vX.Y.Z`, created on publish, **Target**: the SHA from step 1.
6. **Title**: `vX.Y.Z`; notes: the change summary and the Valgrind builds it supports. Leave it as the latest release.
7. **Publish release** (asks for 2FA).
8. Check: the release page shows it as immutable, and `git ls-remote https://github.com/hotpath-rs/setup-valgrind refs/tags/vX.Y.Z` names the SHA from step 1.
