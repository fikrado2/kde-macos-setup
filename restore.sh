#!/usr/bin/env bash
# restore.sh — restore config from a backup dir (default: latest plasma-backup-*)
# Prints a clear error instead of dying silently when no backup exists.
set -euo pipefail

log(){ printf '\033[1;36m[i]\033[0m %s\n' "$*"; }
ok(){  printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[!]\033[0m %s\n' "$*" >&2; exit 1; }

src="${1:-}"
if [ -z "$src" ]; then
    # `ls` returns non-zero when the glob matches nothing; under `set -e` that
    # used to abort the script before the "no backup dir found" message could
    # ever print. Capture with `|| true` and validate explicitly instead.
    src="$(ls -1dt "$HOME"/plasma-backup-* 2>/dev/null | head -1 || true)"
fi

[ -n "$src" ] || die "no backup dir found in $HOME — run ./backup.sh first"
[ -d "$src" ] || die "not a directory: $src"

log "restoring from $src"

restored=0
for a in kde-config-backup.tar.gz shell-appletsrc-backup.tar.gz gtk-backup.tar.gz; do
    [ -f "$src/$a" ] || { log "skip $a (not in backup)"; continue; }
    tar -xzf "$src/$a" -C "$HOME"
    ok "$a"
    restored=$((restored + 1))
done

[ "$restored" -gt 0 ] || die "backup dir $src contains no archives"

pkill -x plasmashell 2>/dev/null || true
nohup plasmashell --replace >/dev/null 2>&1 &
ok "restored $restored archive(s); shell reloading."
