#!/usr/bin/env python3

from __future__ import annotations

import html
import pathlib
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: render_release_notes.py <markdown-file> <output-html>", file=sys.stderr)
        return 1

    source = pathlib.Path(sys.argv[1])
    destination = pathlib.Path(sys.argv[2])

    body = source.read_text(encoding="utf-8").strip()
    if not body:
        body = "No release notes were provided for this release."

    escaped_body = html.escape(body)
    destination.write_text(
        "\n".join(
            [
                "<!DOCTYPE html>",
                '<html lang="en">',
                "<head>",
                '  <meta charset="utf-8">',
                '  <meta name="viewport" content="width=device-width, initial-scale=1">',
                "  <title>Glace Release Notes</title>",
                "  <style>",
                "    :root { color-scheme: light dark; }",
                "    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; line-height: 1.5; margin: 2rem auto; max-width: 60rem; padding: 0 1rem; }",
                "    pre { white-space: pre-wrap; word-break: break-word; background: rgba(127, 127, 127, 0.12); border-radius: 12px; padding: 1rem; }",
                "  </style>",
                "</head>",
                "<body>",
                "  <h1>Glace Release Notes</h1>",
                f"  <pre>{escaped_body}</pre>",
                "</body>",
                "</html>",
            ]
        ),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
