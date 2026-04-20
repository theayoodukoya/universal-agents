#!/usr/bin/env python3
"""
Regenerate agents-manifest.json from YAML frontmatter in ./agents/*.md

Run from repo root:
    python3 scripts/gen-agents-manifest.py

Output: agents-manifest.json at repo root.

The manifest is the single index AI models use to select agents WITHOUT
reading every individual agent file. This saves significant context/tokens:
  - Read manifest once  →  pick the right agent  →  load only that .md file
  - Never scan the entire agents/ folder to find an agent
"""

import os
import re
import json
import sys

AGENTS_DIR = os.path.join(os.path.dirname(__file__), '..', 'agents')
OUTPUT_FILE = os.path.join(os.path.dirname(__file__), '..', 'agents-manifest.json')


def extract_field(frontmatter: str, key: str) -> str:
    match = re.search(r'^' + re.escape(key) + r':\s*(.+)$', frontmatter, re.MULTILINE)
    if not match:
        return ''
    return match.group(1).strip().strip('"').strip("'")


def main():
    agents_dir = os.path.realpath(AGENTS_DIR)

    if not os.path.isdir(agents_dir):
        print(f'ERROR: agents directory not found at {agents_dir}', file=sys.stderr)
        sys.exit(1)

    agents = []

    for fname in sorted(os.listdir(agents_dir)):
        if not fname.endswith('.md'):
            continue

        fpath = os.path.join(agents_dir, fname)
        with open(fpath, encoding='utf-8') as f:
            content = f.read()

        fm_match = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
        if not fm_match:
            print(f'  WARN: no frontmatter in {fname}', file=sys.stderr)
            continue

        fm = fm_match.group(1)
        agents.append({
            'file': f'agents/{fname}',
            'name': extract_field(fm, 'name'),
            'emoji': extract_field(fm, 'emoji'),
            'description': extract_field(fm, 'description'),
            'vibe': extract_field(fm, 'vibe'),
        })

    manifest = {
        '_note': (
            'Lean index — do not edit manually. '
            'Run scripts/gen-agents-manifest.py to regenerate. '
            'AI: read this file once to select an agent, then load only that agent\'s .md file. '
            'Do NOT scan the agents/ folder directly.'
        ),
        'agents_dir': 'agents/',
        'total': len(agents),
        'agents': agents,
    }

    output_path = os.path.realpath(OUTPUT_FILE)
    with open(output_path, 'w', encoding='utf-8') as out:
        json.dump(manifest, out, indent=2, ensure_ascii=False)
        out.write('\n')

    print(f'agents-manifest.json written — {len(agents)} agents indexed.')


if __name__ == '__main__':
    main()
