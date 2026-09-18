#!/usr/bin/env bash
# tweaks.sh — switch macOS Tahoe between LIGHT and DARK (theme stack only).
# Usage: tweaks.sh [light|dark]    (no arg = flip to the opposite of current)
set -euo pipefail
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
log(){ printf '\033[1;36m[i]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[!]\033[0m %s\n' "$*" >&2; exit 1; }

cur=$(kreadconfig6 --file kdeglobals --group General --key ColorScheme)
if [ "${1:-}" = light ]; then want=light; elif [ "${1:-}" = dark ]; then want=dark; else
    if [[ "$cur" == *Dark* ]]; then want=light; else want=dark; fi
fi
log "Switching to: $want (was: ${cur})"

if [ "$want" = light ]; then
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme MacTahoeLiquidKdeLight
    kwriteconfig6 --file kdeglobals --group Icons --key Theme MacTahoeLiquidKde-Icons-Light
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
    kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.mac-tahoe-liquid-kde.light
    kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme mac-tahoe-liquid-kde
    kwriteconfig6 --file plasmarc --group Theme --key name MacTahoeLiquidKde-Light
    kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key theme __aurorae__svg__MacTahoeLiquidKde-Light
    kwriteconfig6 --file gtk-3.0/settings.ini --group Settings --key gtk-theme-name MacTahoeLiquidKde-Light
    kwriteconfig6 --file gtk-4.0/settings.ini --group Settings --key gtk-theme-name MacTahoeLiquidKde-Light
else
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme MacTahoeLiquidKdeDark
    kwriteconfig6 --file kdeglobals --group Icons --key Theme MacTahoeLiquidKde-Icons-Dark
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
    kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.mac-tahoe-liquid-kde.dark
    kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme mac-tahoe-liquid-kdeDark
    kwriteconfig6 --file plasmarc --group Theme --key name MacTahoeLiquidKde-Dark
    kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key theme __aurorae__svg__MacTahoeLiquidKde-Dark
    kwriteconfig6 --file gtk-3.0/settings.ini --group Settings --key gtk-theme-name MacTahoeLiquidKde-Dark
    kwriteconfig6 --file gtk-4.0/settings.ini --group Settings --key gtk-theme-name MacTahoeLiquidKde-Dark
fi

# GTK font keeps SF Pro Text regardless of mode
for f in gtk-3.0/settings.ini gtk-4.0/settings.ini; do
    kwriteconfig6 --file "$f" --group Settings --key gtk-font-name "SF Pro Text,  10"
done

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
log "Reloading shell to pick up colors/theme..."
systemctl --user restart plasma-plasmashell.service 2>/dev/null || { pkill -x plasmashell 2>/dev/null || true; nohup plasmashell --replace >/dev/null 2>&1 & }
log "Now $want. Wallpaper + window glass auto-switch with it."
