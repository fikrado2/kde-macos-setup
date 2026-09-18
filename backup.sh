#!/usr/bin/env bash
# backup.sh — snapshot all Plasma/KDE/GTK config into a timestamped tarball.
set -euo pipefail
stamp="$(date +%Y%m%d-%H%M%S)"
dest="${1:-$HOME/plasma-backup-$stamp}"
mkdir -p "$dest"
tar --exclude='kdeconnectd' -czf "$dest/kde-config-backup.tar.gz" \
    -C "$HOME" \
    .config/kdeglobals .config/kwinrc .config/kwinrulesrc .config/kdecorationrc \
    .config/plasmarc .config/plasmashellrc .config/kdeglobals 2>/dev/null || true
tar -czf "$dest/shell-appletsrc-backup.tar.gz" -C "$HOME" \
    .config/plasma-org.kde.plasma.desktop-appletsrc .config/plasma-org.kde.plasma.desktop-appletsrc 2>/dev/null || true
tar -czf "$dest/gtk-backup.tar.gz" -C "$HOME" .config/gtk-3.0 .config/gtk-4.0 2>/dev/null || true
printf '\033[1;32m[ok]\033[0m backup → %s\n' "$dest"
