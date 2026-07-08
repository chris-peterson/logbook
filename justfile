default:
    @just --list

test:
    python3 -m unittest discover -s tests -v

docs:
    cp SPEC.md docs/SPEC.md
    bash scripts/copy-skill-docs.sh
    docsify serve docs --open

refresh-prices:
    python3 scripts/refresh-prices

plugin-json:
    python3 scripts/gen-plugin-json.py

plugin-json-check:
    python3 scripts/gen-plugin-json.py --check

install-hooks:
    cp scripts/hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    @echo "installed .git/hooks/pre-commit"
