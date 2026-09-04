#!/usr/bin/env python3

import argparse
import html
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Render an exact text transcript as SVG.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--title", default="Terminal evidence")
    args = parser.parse_args()

    lines = args.input.read_text(encoding="utf-8", errors="replace").splitlines()
    shown = lines[:120]
    if len(lines) > len(shown):
        shown.append(f"... {len(lines) - len(shown)} additional lines are in the text transcript")
    longest = max([len(args.title), *(len(line.expandtabs(4)) for line in shown)], default=40)
    width = min(max(760, 18 + longest * 8), 1500)
    height = 74 + max(1, len(shown)) * 20

    rows = []
    for index, line in enumerate(shown):
        y = 62 + index * 20
        rows.append(f'<text x="18" y="{y}">{html.escape(line.expandtabs(4))}</text>')

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
<rect width="100%" height="100%" rx="10" fill="#0d1117"/>
<rect width="100%" height="38" rx="10" fill="#21262d"/>
<circle cx="18" cy="19" r="6" fill="#ff5f56"/><circle cx="38" cy="19" r="6" fill="#ffbd2e"/><circle cx="58" cy="19" r="6" fill="#27c93f"/>
<text x="78" y="25" fill="#c9d1d9" font-family="monospace" font-size="14">{html.escape(args.title)}</text>
<g fill="#c9d1d9" font-family="monospace" font-size="14" xml:space="preserve">
{''.join(rows)}
</g></svg>
"""
    args.output.write_text(svg, encoding="utf-8")


if __name__ == "__main__":
    main()
