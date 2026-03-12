#!/usr/bin/env python3
"""Center Nerd Font icon glyphs within the monospace cell width."""

import sys
import os
from fontTools.ttLib import TTFont

# Nerd Font codepoint ranges
NF_RANGES = [
    (0xE000, 0xE00A),   # Pomicons
    (0xE0A0, 0xE0D4),   # Powerline + Extra
    (0xE200, 0xE2A9),   # Font Awesome Extension
    (0xE300, 0xE3E3),   # Weather
    (0xE5FA, 0xE6B5),   # Seti-UI + Custom
    (0xE700, 0xE7C5),   # Devicons
    (0xEA60, 0xEC1E),   # Codicons
    (0xED00, 0xF2FF),   # Font Awesome
    (0xF300, 0xF375),   # Font Logos
    (0xF400, 0xF533),   # Octicons
    (0xF0001, 0xF1AF0), # Material Design
]


def is_nf_codepoint(cp):
    return any(start <= cp <= end for start, end in NF_RANGES)


def strip_empty_glyphs(font, glyf):
    """Remove empty glyph stubs from cmap so the terminal falls back to system fonts."""
    stripped = 0
    cmap_tables = [t for t in font["cmap"].tables if t.isUnicode()]
    for table in cmap_tables:
        to_remove = []
        for cp, glyph_name in table.cmap.items():
            if is_nf_codepoint(cp):
                continue
            glyph = glyf.get(glyph_name)
            if glyph and hasattr(glyph, "numberOfContours") and glyph.numberOfContours == 0:
                to_remove.append(cp)
        for cp in to_remove:
            del table.cmap[cp]
        stripped += len(to_remove)
    return stripped


def center_glyphs(font_path):
    font = TTFont(font_path)
    hmtx = font["hmtx"]
    glyf = font.get("glyf")
    cmap = font.getBestCmap()

    if not glyf:
        print(f"  Skipping {font_path} (no glyf table, likely CFF)")
        return

    # Remove empty glyph stubs (e.g. Braille) to allow system font fallback
    stripped = strip_empty_glyphs(font, glyf)
    if stripped:
        print(f"  Stripped {stripped} empty glyph stubs")

    # Get the monospace cell width from a regular character
    cell_width = hmtx[cmap[ord("A")]][0]
    centered = 0

    for cp, glyph_name in cmap.items():
        if not is_nf_codepoint(cp):
            continue

        glyph = glyf[glyph_name]
        if not hasattr(glyph, "xMin") or glyph.numberOfContours == 0:
            continue

        width, old_lsb = hmtx[glyph_name]
        glyph_w = glyph.xMax - glyph.xMin
        if glyph_w == 0:
            continue

        new_lsb = (cell_width - glyph_w) // 2
        if new_lsb == old_lsb:
            continue

        # Shift glyph coordinates
        delta = new_lsb - old_lsb
        glyph.xMin += delta
        glyph.xMax += delta

        if hasattr(glyph, "coordinates"):
            for i, (x, y) in enumerate(glyph.coordinates):
                glyph.coordinates[i] = (x + delta, y)
        elif hasattr(glyph, "components"):
            for comp in glyph.components:
                comp.x += delta

        hmtx[glyph_name] = (width, new_lsb)
        centered += 1

    font.save(font_path)
    font.close()
    print(f"  Centered {centered} glyphs (cell width: {cell_width})")


def main():
    font_dir = sys.argv[1]
    for filename in sorted(os.listdir(font_dir)):
        if filename.endswith(".ttf"):
            print(f"Processing {filename}...")
            center_glyphs(os.path.join(font_dir, filename))


if __name__ == "__main__":
    main()