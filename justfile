default:
    @just --list

# preview the docsify docs site locally
docs:
    cp SPEC.md docs/SPEC.md
    bash scripts/copy-skill-docs.sh
    docsify serve docs --open

# refresh the vendored Anthropic price table from LiteLLM
refresh-prices:
    python3 scripts/refresh-prices
