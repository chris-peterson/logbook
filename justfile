shipyard := "uvx --from 'git+https://github.com/chris-peterson/shipyard@v2' shipyard"

default:
    @just --list

test:
    python3 -m unittest discover -s tests -v

# run the generators the way CI does and show what it would commit
# (writes into the tree; `git restore .` throws the result away)
preview-generated:
    {{shipyard}} generate
    git --no-pager diff --stat

# render the docsify site and serve it locally
docs:
    {{shipyard}} build-docs
    docsify serve docs --open

refresh-prices:
    python3 scripts/refresh-prices
