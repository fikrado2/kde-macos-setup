#!/usr/bin/env bash
# restore.sh — restore config from a backup dir (default: latest plasma-backup-*)
set -euo pipefail
src="${1:-}"
[ -z "$src" ] && src="$(ls -1dt "$HOME"/plasma-backup-* 2>/dev/null | head -1)"
[ -n "$src" ] && [ -d "$src" ] || { echo "no backup dir found"; exit 1; }
printf '\033[1;36m[i]\033[0m restoring from %s\n' "$src"
[ -f "$src/kde-config-backup.tar.gz" ]      && tar -xzf "$src/kde-config-backup.tar.gz"      -C "$HOME"
[ -f "$src/shell-appletsrc-backup.tar.gz" ] && tar -xzf "$src/shell-appletsrc-backup.tar.gz" -C "$HOME"
[ -f "$src/gtk-backup.tar.gz" ]             && tar -xzf "$src/gtk-backup.tar.gz"             -C "$HOME"
pkill -x plasmashell 2>/dev/null || true
nohup plasmashell --replace >/dev/null 2>&1 &
printf '\033[1;32m[ok]\033[0m restored; shell reloading.\n'
