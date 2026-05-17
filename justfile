default:
    @just --list

# preview the docsify docs site locally
docs:
    cp SPEC.md docs/SPEC.md
    bash scripts/copy-skill-docs.sh
    docsify serve docs --open
