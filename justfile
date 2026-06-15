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

# regenerate .claude-plugin/plugin.json from plugin.yml (the canonical descriptor)
plugin-json:
    python3 scripts/gen-plugin-json.py

# verify plugin.json is in sync with plugin.yml (used by CI and the pre-commit hook)
plugin-json-check:
    python3 scripts/gen-plugin-json.py --check

# install the git pre-commit hook that keeps plugin.json in sync with plugin.yml
install-hooks:
    cp scripts/hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    @echo "installed .git/hooks/pre-commit"
