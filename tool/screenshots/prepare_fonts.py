"""Writes copies of the bundled Atkinson Hyperlegible fonts whose .notdef
glyph is blank, for the screenshot harness.

flutter_tester has no per-character system font fallback, so emoji would
render as the font's .notdef box. With a blank .notdef the harness can paint
the real emoji (Noto Color Emoji) on top at the exact glyph position.
"""
import sys
from pathlib import Path

from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

out = Path(sys.argv[1] if len(sys.argv) > 1 else "build/screenshots/fonts")
out.mkdir(parents=True, exist_ok=True)
for src in sorted(Path("assets/fonts").glob("AtkinsonHyperlegible-*.ttf")):
    font = TTFont(src)
    upm = font["head"].unitsPerEm
    font["glyf"][".notdef"] = TTGlyphPen(None).glyph()
    font["hmtx"][".notdef"] = (int(upm * 1.2), 0)
    font.save(out / src.name)
print(out)
