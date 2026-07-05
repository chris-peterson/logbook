# Disposition: `File an issue` — full mechanics

Loaded from `skills/note/SKILL.md` when the `File an issue` disposition fires.

Emit a structured note the user can review, attach, or file as an issue. No file in the target repo is modified and no session is spawned. The skill produces three artifacts in one pass: a tempfile on disk, the body on the system clipboard, and (when the cwd is a git repo on a known forge) a pre-filled "new issue" URL.

**Title** — a short, specific phrase naming the change you want, in the imperative or as a statement of the desired end state. The issue already records its own date and the body carries the detail, so the title is just the headline. Keep it terse — aim for under ~60 characters and drop trailing qualifiers. Don't prefix it with `Note:` or a date.

**Body shape** — assemble these fields from the observation. No date line and no `**Note**` lead — the forge stamps the date, and the title is the summary:

```markdown
**Target:** <path or "TBD">

**Observation:** <full text>

**Why this matters:** <one or two sentences, if the user supplied them>

**Suggested action:** <if obvious — otherwise omit>
```

**Write to a tempfile.** Use `mktemp -u` with a unique template and a `.md` extension so the path doesn't collide with peer sessions and Cmd+click opens the registered editor. `-u` prints the name without creating the file, so the `Write` tool treats it as a fresh path — on macOS this sidesteps the "overwrite via a symlink" prompt that plain `mktemp` triggers (it pre-creates the file behind the `/tmp` → `/private/tmp` symlink). The flag is portable across BSD and GNU `mktemp`:

```bash
TMPFILE=$(mktemp -u /tmp/logbook-note.XXXXXX.md)
# Write the body to "$TMPFILE" via the Write tool, then reference $TMPFILE.
```

**Copy to clipboard** — best-effort, never erroring:

```bash
if   command -v pbcopy   >/dev/null; then pbcopy < "$TMPFILE"                    # macOS
elif command -v wl-copy  >/dev/null; then wl-copy < "$TMPFILE"                   # Wayland
elif command -v xclip    >/dev/null; then xclip -selection clipboard < "$TMPFILE" # X11
elif command -v clip.exe >/dev/null; then clip.exe < "$TMPFILE"                  # Windows / WSL
fi
```

Record whether at least one copy succeeded — surface "copied to clipboard" or "clipboard unavailable" in the summary.

**Build a "new issue" URL** when cwd is a git repo on a recognized forge. URL emission lives here; actually filing via `gh`/`glab` is deferred.

Detect the forge from `git remote get-url origin`:

| Host | URL template |
|---|---|
| `github.com` | `https://github.com/<owner>/<repo>/issues/new?title=<title>&body=<body>` |
| `gitlab.com` or any `gitlab.*` host | `https://<host>/<owner>/<repo>/-/issues/new?issue[title]=<title>&issue[description]=<body>` |

Strip a trailing `.git` from the repo segment. Both `title` and `body` must be URL-encoded (`%`, spaces → `%20`, newlines → `%0A`, etc.). If the cwd isn't a git repo, the origin isn't recognized, or the URL would exceed ~8 KB after encoding, omit the URL — print the file path and clipboard status only.

**Print a summary** — lead with the action. Render the prefilled issue URL as a markdown hyperlink with a short label, never the raw query string. Name the target repo so the user knows where the issue lands, link the note file, and note the clipboard in passing.

When a forge URL was built:

```text
Captured for <owner>/<repo> — nothing modified, no session spawned.
→ **[File the issue](<prefilled-url>)** · note: [logbook-note.<id>.md](file:///tmp/logbook-note.<id>.md) (copied to clipboard)
```

When no URL (cwd isn't a recognized forge repo, or the encoded URL was too long):

```text
Captured — nothing modified, no session spawned.
Note saved to [logbook-note.<id>.md](file:///tmp/logbook-note.<id>.md) (copied to clipboard); file it manually when ready.
```

If the clipboard copy failed, say `(clipboard unavailable)` in place of `(copied to clipboard)`.

To work it now in another repo, file the issue and pull it into a fresh session there (`/recipe`), so that project's rules and hooks apply. Then resume prior work.
