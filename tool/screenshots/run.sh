#!/usr/bin/env bash
# Builds App Store screenshots (iPhone 6.9" and iPad 13") from the real app
# widgets with seeded demo data. Headless, no device or network needed.
#
#   tool/screenshots/run.sh [output dir]
#
# Needs python3 with fontTools and Pillow, and Noto Color Emoji
# (override with SHOTS_EMOJI_FONT) plus DejaVu Sans Mono (SHOTS_MONO_FONT).
set -euo pipefail
cd "$(dirname "$0")/../.."
out="${1:-build/app_store_screenshots}"
raw=build/screenshots

python3 tool/screenshots/prepare_fonts.py "$raw/fonts" >/dev/null
for device in ${SHOTS_DEVICES:-iphone69 ipad13}; do
  for theme in light dark; do
    # One process per run: bundled assets are cached between tests in a
    # single process, which leaves later runs stuck on loading screens.
    flutter test tool/screenshots/app_store_screenshots_test.dart \
      --plain-name "$device $theme" --reporter compact
  done
done

python3 - "$raw" "$out" <<'PY'
import sys
from pathlib import Path
from PIL import Image

raw, out = Path(sys.argv[1]), Path(sys.argv[2])
pick = {
    "01-home": "light-home",
    "02-courses": "light-learn",
    "03-lesson": "light-lesson2",
    "04-quiz": "light-quiz-answered",
    "05-progress": "light-progress",
    "06-dark-practice": "dark-practice",
}
sizes = {"iphone69": (1320, 2868), "ipad13": (2064, 2752)}
for device, size in sizes.items():
    (out / device).mkdir(parents=True, exist_ok=True)
    for name, src in pick.items():
        im = Image.open(raw / device / f"{src}.png").convert("RGB")
        assert im.size == size, (device, src, im.size)
        im.save(out / device / f"{name}.png", optimize=True)
        print(out / device / f"{name}.png", im.size)
PY
