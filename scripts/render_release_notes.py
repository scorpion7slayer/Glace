#!/usr/bin/env python3

from __future__ import annotations

import html
import pathlib
import re
import sys
from urllib.parse import urlparse


def render_inline(value: str) -> str:
    escaped = html.escape(value, quote=True)
    escaped = re.sub(r"`([^`]+)`", r"<code>\1</code>", escaped)

    def replace_link(match: re.Match[str]) -> str:
        label, target = match.groups()
        parsed = urlparse(html.unescape(target))
        if parsed.scheme not in {"https", "http"}:
            return label
        return f'<a href="{target}" rel="noreferrer">{label}</a>'

    escaped = re.sub(r"\[([^]]+)]\(([^)]+)\)", replace_link, escaped)
    return escaped


def render_markdown(source: str) -> str:
    blocks: list[str] = []
    paragraph: list[str] = []
    list_items: list[str] = []

    def flush_paragraph() -> None:
        if paragraph:
            blocks.append(f"<p>{render_inline(' '.join(paragraph))}</p>")
            paragraph.clear()

    def flush_list() -> None:
        if list_items:
            items = "".join(f"<li>{render_inline(item)}</li>" for item in list_items)
            blocks.append(f"<ul>{items}</ul>")
            list_items.clear()

    for raw_line in source.splitlines():
        line = raw_line.strip()
        if not line:
            flush_paragraph()
            flush_list()
            continue
        heading = re.match(r"^(#{1,3})\s+(.+)$", line)
        if heading:
            flush_paragraph()
            flush_list()
            level = len(heading.group(1)) + 1
            blocks.append(f"<h{level}>{render_inline(heading.group(2))}</h{level}>")
        elif line.startswith(("- ", "* ")):
            flush_paragraph()
            list_items.append(line[2:].strip())
        else:
            flush_list()
            paragraph.append(line)

    flush_paragraph()
    flush_list()
    return "\n".join(blocks)


def main() -> int:
    if len(sys.argv) not in {3, 4}:
        print(
            "Usage: render_release_notes.py <markdown-file> <output-html> [version]",
            file=sys.stderr,
        )
        return 1

    source = pathlib.Path(sys.argv[1])
    destination = pathlib.Path(sys.argv[2])
    version = sys.argv[3] if len(sys.argv) == 4 else ""
    body = source.read_text(encoding="utf-8").strip()
    if not body:
        body = "This release includes stability and compatibility improvements."

    title = f"Glace {version}" if version else "Glace release notes"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(
        f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d0d0f">
  <title>{html.escape(title)} — Release notes</title>
  <style>
    :root {{ color-scheme: dark; font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif; background: #0d0d0f; color: #f0e4d4; }}
    * {{ box-sizing: border-box; }}
    body {{ margin: 0; min-height: 100vh; background: radial-gradient(circle at 75% 5%, rgba(238,147,183,.13), transparent 30rem), #0d0d0f; }}
    header, main, footer {{ width: min(calc(100% - 32px), 860px); margin-inline: auto; }}
    header {{ padding: 38px 0 24px; display: flex; align-items: center; gap: 15px; }}
    header img {{ width: 58px; height: 58px; border-radius: 16px; }}
    header a {{ color: inherit; text-decoration: none; font-size: 1.8rem; font-weight: 650; letter-spacing: -.04em; }}
    main {{ padding: clamp(34px, 7vw, 70px); border: 1px solid rgba(231,210,187,.24); border-radius: 30px; background: linear-gradient(145deg, rgba(255,255,255,.075), rgba(255,255,255,.035)); box-shadow: 0 30px 80px rgba(0,0,0,.28); }}
    h1 {{ margin: 0 0 12px; font-size: clamp(3rem, 8vw, 5rem); letter-spacing: -.055em; line-height: 1; }}
    .version {{ margin: 0 0 48px; color: #ee93b7; font-size: 1.2rem; }}
    h2 {{ margin: 42px 0 14px; font-size: 1.75rem; }}
    h3 {{ margin: 30px 0 10px; font-size: 1.3rem; }}
    p, li {{ color: #bbb4b5; font-size: 1.06rem; line-height: 1.65; }}
    li {{ margin: 9px 0; }}
    a {{ color: #ee93b7; }}
    code {{ padding: 2px 7px; border-radius: 7px; background: rgba(238,147,183,.1); color: #f6b3ca; }}
    footer {{ padding: 28px 0 48px; display: flex; justify-content: space-between; gap: 20px; color: #858185; }}
    @media (max-width: 560px) {{ main {{ padding: 30px 22px; border-radius: 24px; }} footer {{ flex-direction: column; }} }}
  </style>
</head>
<body>
  <header><img src="../assets/glace-icon.png" alt=""><a href="../">Glace</a></header>
  <main>
    <h1>Release notes</h1>
    <p class="version">{html.escape(title)}</p>
    {render_markdown(body)}
  </main>
  <footer><span>Made for macOS.</span><a href="https://github.com/scorpion7slayer/Glace/releases">All releases</a></footer>
</body>
</html>
""",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
