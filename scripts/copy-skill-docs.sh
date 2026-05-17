#!/usr/bin/env bash
# Copy each skills/*/SKILL.md into docs/skills/<name>.md, stripping the YAML
# frontmatter (the leading --- ... --- block). Used by `just docs` and by the
# GitHub Pages deploy workflow so the docs site renders each skill's source
# of truth directly, with no parallel doc artifact to maintain.

set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p docs/skills
for skill in skills/*/SKILL.md; do
  name=$(basename "$(dirname "$skill")")
  awk '/^---$/{fm++; next} fm>=2' "$skill" > "docs/skills/$name.md"
done
