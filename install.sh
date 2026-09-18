#!/usr/bin/env bash
# install.sh — macOS Tahoe desktop for Plasma 6 (Omarchy)
# Applies ONLY user-level Plasma/KWin/GTK config. NEVER touches Plymouth/boot.
# Idempotent — safe to re-run any time.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
SRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
SHELL_RC="$HOME/.config/plasmashellrc"
LAYOUT="$SCRIPT_DIR/plasma-desktop-layout.js"

log(){ printf '\033[1;36m[i]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[!]\033[0m %s\n' "$*" >&2; exit 1; }
[ -f "$LAYOUT" ]        || die "layout JS missing: $LAYOUT"
command -v kwriteconfig6 >/dev/null || die "kwriteconfig6 missing"
command -v qdbus6        >/dev/null || die "qdbus6 missing"
command -v kwriteconfig6 >/dev/null || true

########################################
# 1. Theme stack
########################################
log "macOS theme stack (colors, icons, kvantum, fonts, cursor, Plasma theme)"
kwriteconfig6 --file kdeglobals --group General --key ColorScheme MacTahoeLiquidKdeLight
kwriteconfig6 --file kdeglobals --group General --key Name        MacTahoeLiquidKde-Light
kwriteconfig6 --file kdeglobals --group Icons    --key Theme      MacTahoeLiquidKde-Icons
kwriteconfig6 --file kdeglobals --group KDE      --key widgetStyle kvantum
kwriteconfig6 --file kdeglobals --group KDE      --key LookAndFeel org.kde.mac-tahoe-liquid-kde.light
kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme mac-tahoe-liquid-kde
kwriteconfig6 --file plasmarc   --group Theme --key name MacTahoeLiquidKde-Light

# SF Pro fonts
for k in font menuFont smallFont smallestReadableFont toolBarFont fixed; do
    kwriteconfig6 --file kdeglobals --group General --key "$k" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
done
# Cursor
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme MacTahoeLiquidKde
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize  24

# Kvantum renderer
kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme mac-tahoe-liquid-kde

########################################
# 2. KWin decoration + effects (liquid glass)
########################################
log "Window decorations (Aurorae SVG) + LiquidGlass / blur / rounded corners"
kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key theme    __aurorae__svg__MacTahoeLiquidKde-Light
kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key BorderSize Tiny
kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key ButtonsOnLeft XIA
kwriteconfig6 --file kwinrc --group "org.kde.kdecoration2" --key ButtonsOnRight ""
kwriteconfig6 --file kwinrc --group Effects --key LiquidGlassEnabled true
kwriteconfig6 --file kwinrc --group Effects --key BlurEnabled true
kwriteconfig6 --file kwinrc --group Effects --key RoundedCornersEnabled true

########################################
# 3. macOS layout (top bar + dock) via shell JS
########################################
log "Building macOS layout (top menu bar + bottom dock)..."
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$LAYOUT")" \
    >/dev/null || die "layout apply failed"
sleep 2

# Detect panels: bar = top (location 3), dock = bottom (location 4)
BAR=""; DOCK=""
while read -r id loc; do
    case "$loc" in 3) BAR=$id;; 4) DOCK=$id;; esac
done < <(python3 - "$SRC" <<'PYEOF'
import re, sys
s = open(sys.argv[1], encoding="utf-8").read()
for m in re.finditer(r"^\[Containments\]\[(\d+)\]$", s, re.M):
    cid = m.group(1)
    seg = re.search(rf"^\[Containments\]\[{cid}\]$(.*?)(?=^\[Containments\]\[|\Z)", s, re.M|re.S)
    if not seg: continue
    body = seg.group(1)
    if "plugin=org.kde.panel" not in body: continue
    loc = re.search(r"^location=(\d+)$", body, re.M)
    if loc: print(cid, loc.group(1))
PYEOF
)
[ -n "$BAR" ] && [ -n "$DOCK" ] || die "could not detect panels (bar=$BAR dock=$DOCK)"
log "  bar panel=$BAR   dock panel=$DOCK"

########################################
# 4. Panel appearance (plasmashellrc / plasmashellrc)
########################################
# macOS top menu bar: flush, floating applets, translucent
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $BAR" --key floating          0
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $BAR" --key floatingApplets   1
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $BAR" --key panelOpacity      2
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $BAR" --key panelVisibility   0
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $BAR" --key thickness     32
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $BAR" --group Defaults --key thickness 32

# macOS dock: floating, translucent, autohide
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $DOCK" --key floating          1
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $DOCK" --key panelOpacity      2
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $DOCK" --key panelVisibility   1
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $DOCK" --key thickness     68
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel $DOCK" --group Defaults --key thickness 68

########################################
# 5. Desktop clean + MacTahoe wallpaper
########################################
# remove any leftover desktop-icon screen mapping so the desktop stays icon-free
python3 - "$SRC" <<'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = re.sub(r"\n\[ScreenMapping\][\s\S]*?(?=\n\[|\Z)", "\n", s)
s = re.sub(r"\n+", "\n", s)
open(p, "w", encoding="utf-8").write(s)
PYEOF

########################################
# 6. Apply
########################################
log "Reloading shell + kwin..."
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
if systemctl --user is-active plasma-plasmashell.service >/dev/null 2>&1; then
    systemctl --user restart plasma-plasmashell.service
else
    pkill -x plasmashell 2>/dev/null || true
    nohup plasmashell --replace >/dev/null 2>&1 &
fi
sleep 4
log "Done. Re-run ./install.sh anytime to reapply."
