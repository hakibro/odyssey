#!/usr/bin/env bash
# Start/stop helper for testing an Odyssey development build beside the
# installed odyssey.service.
#
# The daily service owns odyssey's IPC socket and the
# org.freedesktop.Notifications name, so a dev instance must not run at the
# same time as the service unless you accept the conflicts. This helper keeps
# that switching explicit.
#
# Usage:
#   ./dev-manage.sh stop     # stop the installed odyssey.service
#   ./dev-manage.sh start    # start the installed odyssey.service
#   ./dev-manage.sh status   # show service + running quickshell instances
set -euo pipefail

action=${1:-status}

case $action in
    stop)
        systemctl --user stop odyssey.service
        printf 'installed odyssey.service stopped; run ./dev.sh to test from source\n'
        ;;
    start)
        systemctl --user start odyssey.service
        printf 'installed odyssey.service started\n'
        ;;
    status)
        systemctl --user status odyssey.service --no-pager 2>/dev/null | head -6 || true
        printf '\nquickshell instances:\n'
        qs list --all 2>&1 | sed 's/^/  /' || true
        ;;
    -h|--help)
        sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
        ;;
    *)
        printf 'dev-manage.sh: unknown action: %s\n' "$action" >&2
        exit 64
        ;;
esac
