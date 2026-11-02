#!/usr/bin/env bash
# Installs a hotpath Valgrind build to /opt/valgrind. Inputs: VERSION (env),
# GITHUB_ACTION_PATH, RUNNER_TEMP, GITHUB_PATH and GITHUB_OUTPUT (set by the
# runner).
set -euo pipefail

prefix=/opt/valgrind
repo=hotpath-rs/valgrind

fail() {
  echo "::error::$*"
  exit 1
}

# 3.28.0.hotpath-rs -> release tag VALGRIND_3_28_0_HOTPATH_RS
# 3.28.0.hotpath-rs-2 -> release tag VALGRIND_3_28_0_HOTPATH_RS_2
if [[ ! "${VERSION:-}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\.hotpath-rs(-([0-9]+))?$ ]]; then
  fail "version must look like 3.28.0.hotpath-rs-2, got '${VERSION:-}'"
fi
tag="VALGRIND_${BASH_REMATCH[1]}_${BASH_REMATCH[2]}_${BASH_REMATCH[3]}_HOTPATH_RS${BASH_REMATCH[5]:+_${BASH_REMATCH[5]}}"

[[ "$(uname -s)" == Linux ]] || fail "Valgrind builds exist for Linux runners only, not $(uname -s)"
case "$(uname -m)" in
  x86_64) arch=x86_64 ;;
  aarch64 | arm64) arch=arm64 ;;
  *) fail "no Valgrind build for $(uname -m); supported: x86_64, aarch64" ;;
esac

file="valgrind-$VERSION-linux-$arch.tar.zst"
# The checksum comes from this action release, not from the download's
# release, so a replaced asset cannot pass.
sum=$(awk -v f="$file" '$2 == f { print $1 }' "$GITHUB_ACTION_PATH/checksums.txt")
[[ -n "$sum" ]] || fail "$file is not known to this action release; known builds: $(awk '{ print $2 }' "$GITHUB_ACTION_PATH/checksums.txt" | tr '\n' ' ')"

command -v zstd > /dev/null || fail "zstd is required to unpack $file"
sudo=""
if [[ "$(id -u)" != 0 ]]; then sudo=sudo; fi

archive="$RUNNER_TEMP/$file"
curl -fsSL --retry 3 -o "$archive" "https://github.com/$repo/releases/download/$tag/$file"
echo "$sum  $archive" | sha256sum -c - > /dev/null || fail "SHA-256 mismatch for $file"

# Valgrind finds its tools through the prefix compiled into it, so the build
# must sit exactly at /opt/valgrind; a previous install there is replaced.
$sudo rm -rf "$prefix"
$sudo tar --zstd -xf "$archive" -C "$(dirname "$prefix")"
rm -f "$archive"

actual=$("$prefix/bin/valgrind" --version)
[[ "$actual" == "valgrind-$VERSION" ]] || fail "installed $actual, expected valgrind-$VERSION"

echo "$prefix/bin" >> "$GITHUB_PATH"
{
  echo "version=$VERSION"
  echo "valgrind=$prefix/bin/valgrind"
} >> "$GITHUB_OUTPUT"
echo "Installed $actual ($arch) from $repo@$tag to $prefix"
