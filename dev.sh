#!/usr/bin/env bash
# Odyssey development launcher.
#
# Runs the shell straight from this working tree, using an isolated state
# directory so development never touches the installed release's user data
# (~/.local/state/odyssey, wallpapers, notes, settings, backups).
#
# Because the daily odyssey.service already owns the global IPC socket and
# notification name, the dev instance is expected to be used with the system
# service stopped (see dev-manage.sh), or on a spare/headless session.
#
# Usage:
#   ./dev.sh                 # run from source, isolated dev state
#   ./dev.sh --shared-state  # run from source, reuse real user state (risky)
set -euo pipefail

root_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
[[ -f $root_dir/shell.qml ]] || { printf 'dev.sh: shell.qml not found in %s\n' "$root_dir" >&2; exit 69; }

shared_state=false
while (($#)); do
    case $1 in
        --shared-state) shared_state=true ;;
        -h|--help)
            sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) printf 'dev.sh: unknown argument: %s\n' "$1" >&2; exit 64 ;;
    esac
    shift
done

qs_path=$(command -v qs) || { printf 'dev.sh: qs not found in PATH\n' >&2; exit 69; }

if [[ $shared_state == false ]]; then
    export XDG_STATE_HOME="${ODYSSEY_DEV_STATE_HOME:-$HOME/.local/state/odyssey-dev}"
    mkdir -p "$XDG_STATE_HOME"
    printf 'dev.sh: isolated state at %s\n' "$XDG_STATE_HOME" >&2
fi

printf 'dev.sh: launching %s --path %s\n' "$qs_path" "$root_dir" >&2
exec "$qs_path" --path "$root_dir" "$@"
