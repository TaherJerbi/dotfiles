#!/usr/bin/env python3
"""Unwrap soft-wrapped markdown read from stdin, writing the result to stdout.

Line lengths in markdown are often kept short to satisfy linters/prettier, which
scatters newlines through the middle of sentences. This joins the lines of each
block back into one long line so the text can be pasted somewhere that wraps on
its own (chat boxes, issue trackers, ...).

Only newlines that are purely cosmetic are removed. Blank lines, headings, list
items, code blocks (fenced and indented), tables, horizontal rules, HTML and
markdown hard breaks (trailing double space or backslash) all keep their own
lines. Indentation and list markers of the first line of a block are preserved.
"""

import re
import sys

FENCE = re.compile(r'^\s*(```|~~~)')
HEADING = re.compile(r'^\s{0,3}#{1,6}(\s|$)')
RULE = re.compile(r'^\s{0,3}([-*_])(\s*\1){2,}\s*$')
SETEXT = re.compile(r'^\s{0,3}(=+|-+)\s*$')
LIST = re.compile(r'^(\s*)([-*+]|\d+[.)])\s+')
QUOTE = re.compile(r'^(\s{0,3}>+\s?)')
TABLE = re.compile(r'^\s*\|')
HTML = re.compile(r'^\s{0,3}<')
INDENTED_CODE = re.compile(r'^(\t| {4,})\S')
HARD_BREAK = re.compile(r'(  |\\)$')


def reflow(text):
    out = []
    buf = []  # lines of the block being joined
    prefix = ''  # indent / list marker / quote marker to re-emit for the block

    def flush():
        nonlocal buf, prefix
        if buf:
            out.append(prefix + ' '.join(buf))
            buf = []
            prefix = ''

    def append(line, own_prefix):
        """Add a line to the current block, closing it after a hard break."""
        nonlocal prefix
        if not buf:
            prefix = own_prefix
        hard = HARD_BREAK.search(line.rstrip('\n'))
        content = line.strip()
        if hard and hard.group(1) == '  ':
            content += '  '
        buf.append(content)
        if hard:
            flush()

    fence_marker = None
    for line in text.split('\n'):
        # Inside a fenced code block nothing is touched until the closing fence.
        if fence_marker:
            out.append(line)
            if line.strip().startswith(fence_marker):
                fence_marker = None
            continue

        opening = FENCE.match(line)
        if opening:
            flush()
            fence_marker = opening.group(1)
            out.append(line)
            continue

        if not line.strip():
            flush()
            out.append('')
            continue

        # Blocks that stand alone: emitted verbatim, never joined.
        if (
            HEADING.match(line)
            or RULE.match(line)
            or SETEXT.match(line)
            or TABLE.match(line)
            or HTML.match(line)
            or (not buf and INDENTED_CODE.match(line))
        ):
            flush()
            out.append(line)
            continue

        quote = QUOTE.match(line)
        if quote:
            body = line[quote.end() :]
            # A structural line inside a quote is left alone, same as outside.
            if not body.strip() or HEADING.match(body) or RULE.match(body) or TABLE.match(body) or FENCE.match(body):
                flush()
                out.append(line)
                continue
            item = LIST.match(body)
            if item:
                flush()
                append(body[item.end() :], quote.group(1) + body[: item.end()])
            elif buf and prefix.lstrip().startswith('>'):
                append(body, prefix)
            else:
                flush()
                append(body, quote.group(1))
            continue

        item = LIST.match(line)
        if item:
            flush()
            append(line[item.end() :], line[: item.end()])
            continue

        # Plain prose: first line sets the indent, continuations join onto it.
        append(line, line[: len(line) - len(line.lstrip())])

    flush()
    return '\n'.join(out)


if __name__ == '__main__':
    sys.stdout.write(reflow(sys.stdin.read()))
