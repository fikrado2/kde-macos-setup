#!/usr/bin/env bash
# backup.sh — snapshot all Plasma/KDE/GTK config into a timestamped dir.
# Sources that don't exist are reported as skipped, not passed to tar (which
# would abort the whole archive). An archive that ends up empty is removed and
# treated as a failure, so you never see "[ok]" for a backup with nothing in it.
set -euo pipefail

log(){ printf '\033[1;36m[i]\033[0m %s\n' "$*"; }
ok(){  printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[!]\033[0m %s\n' "$*" >&2; exit 1; }

stamp="$(date +%Y%m%d-%H%M%S)"
dest="${1:-$HOME/plasma-backup-$stamp}"
mkdir -p "$dest"

# backup <archive-name> <path...>   -> 0 on success, 1 if nothing was captured
backup() {
    local name="$1"; shift
    local tarball="$dest/$name"
    local existing=() missing=() p

    for p in "$@"; do
        if [ -e "$HOME/$p" ]; then existing+=("$p"); else missing+=("$p"); fi
    done

    local m
    for m in "${missing[@]:-}"; do
        [ -n "$m" ] && log "  skip ${m##*/} (not present)"
    done

    if [ "${#existing[@]}" -eq 0 ]; then
        log "  $name: nothing to archive"
        return 1
    fi

    tar --exclude='kdeconnectd' -czf "$tarball" -C "$HOME" "${existing[@]}"

    # Verify the archive is readable and non-empty.
    local got
    got="$(tar -tzf "$tarball" 2>/dev/null | grep -c . || true)"
    if [ "$got" -lt 1 ]; then
        rm -f "$tarball"
        log "  $name: archive empty, removed"
        return 1
    fi
    ok "$name ($got entries)"
    return 0
}

fail=0
backup "kde-config-backup.tar.gz" \
    .config/kdeglobals .config/kwinrc .config/kwinrulesrc .config/kdecorationrc \
    .config/plasmarc .config/plasmashellrc || fail=1
backup "shell-appletsrc-backup.tar.gz" \
    .config/plasma-org.kde.plasma.desktop-appletsrc || fail=1
backup "gtk-backup.tar.gz" \
    .config/gtk-3.0 .config/gtk-4.0 || fail=1

[ "$fail" -eq 0 ] || die "at least one archive could not be created — do not rely on $dest"
ok "backup complete -> $dest"
