default:
    @just --list

# preview the docsify docs site locally
docs:
    cp SPEC.md docs/SPEC.md
    docsify serve docs --open
