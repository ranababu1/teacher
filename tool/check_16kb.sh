#!/usr/bin/env bash
# Verifies an APK is compatible with Google Play's 16 KB page-size requirement:
#   1. every native .so (arm64-v8a / x86_64) has ELF LOAD segments aligned to >= 16 KB
#   2. the APK is zip-aligned to 16 KB (uncompressed .so files page-aligned)
# Usage: tool/check_16kb.sh path/to/app.apk
set -euo pipefail
apk="${1:?usage: check_16kb.sh <apk>}"
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
[ -n "$sdk" ] || { echo 'ANDROID_HOME not set' >&2; exit 1; }
bt="$(ls -d "$sdk"/build-tools/* | sort -V | tail -1)"
readelf="$(ls "$sdk"/ndk/*/toolchains/llvm/prebuilt/*/bin/llvm-readelf | sort -V | tail -1)"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
unzip -q "$apk" 'lib/*' -d "$tmp" 2>/dev/null || true

fail=0
while IFS= read -r so; do
  case "$so" in */arm64-v8a/*|*/x86_64/*) ;; *) continue ;; esac
  align="$("$readelf" -lW "$so" | awk '$1=="LOAD"{print $NF}' | sort -u)"
  for a in $align; do
    if [ $((a)) -lt 16384 ]; then
      echo "FAIL: ${so#"$tmp"/} LOAD alignment $a < 0x4000"; fail=1
    fi
  done
done < <(find "$tmp/lib" -name '*.so' 2>/dev/null)

"$bt/zipalign" -c -P 16 -v 4 "$apk" >/dev/null || { echo "FAIL: $apk not 16 KB zip-aligned"; fail=1; }

[ "$fail" = 0 ] && echo "OK: $apk is 16 KB compatible"
exit "$fail"
