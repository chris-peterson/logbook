default:
    @just --list

# preview the docsify docs site locally
docs:
    cp SPEC.md docs/SPEC.md
    mkdir -p docs/skills
    for skill in skills/*/SKILL.md; do \
      name=$(basename $(dirname $$skill)); \
      awk '/^---$$/{fm++; next} fm>=2' $$skill > docs/skills/$$name.md; \
    done
    docsify serve docs --open
