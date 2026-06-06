#!/usr/bin/env bash
# Open a new iTerm2 tab in <repo-path> running a one-off Claude session seeded
# from <prompt-file>, then remove the prompt file once the session reads it.
#
# Extracted from the note skill's "New Session" mode (SPEC [NOTE-5]). The skill
# used to emit this osascript as an inline heredoc, which the permission layer
# could only allow by blanket-allowing `osascript` — too broad, since osascript
# runs arbitrary AppleScript. Behind this script the command the permission
# layer sees is `bash .../scripts/open-iterm-tab.sh ...`, which an allow entry
# can name exactly, with no `osascript` token on the line.
set -euo pipefail

repo_path=${1:?usage: open-iterm-tab.sh <repo-path> <prompt-file>}
prompt_file=${2:?usage: open-iterm-tab.sh <repo-path> <prompt-file>}

# iTerm2 absent → print the equivalent command for the user to run manually and
# signal the caller with exit 3 (id of application errors if it isn't installed).
if ! osascript -e 'id of application "iTerm2"' >/dev/null 2>&1; then
  printf 'Run in a new terminal:\ncd %s && claude < %s\n' "$repo_path" "$prompt_file"
  exit 3
fi

osascript <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session of current tab
            write text "cd ${repo_path} && claude < ${prompt_file} ; rm ${prompt_file}"
        end tell
    end tell
end tell
EOF
