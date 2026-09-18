# macOS Tahoe Desktop for Plasma 6 (Omarchy)

A faithful, **macOS Tahoe–inspired** desktop for KDE Plasma 6 — macOS-style
**top menu bar** with global menu + weather + clock, a **floating glass dock**
with magnification, the **MacTahoe Liquid KDE** theme stack (Liquid Glass,
macOS light/dark auto-switching wallpaper, SF Pro fonts, macOS cursors &
icons, Kvantum + GTK GTK stack).

> **Safety guarantee:** every script writes **only user-level Plasma / KWin /
> GTK configuration**. Nothing ever touches Plymouth or the boot path.

## Files

| File              | Purpose |
|-------------------|---------|
| `install.sh`      | Apply the full macOS look & feel (idempotent, safe to re-run) |
| `tweaks.sh`       | Toggle **light/dark** macOS variant + reload shell on the fly |
| `backup.sh`       | Snapshot all Plasma/KWin/GTK config into a timestamped tar.gz |
| `restore.sh`      | Restore a previous snapshot (first arg = tarball) |
| `plasma-desktop-layout.js` | Rebuilds the top bar + dock via the Plasma scripting API |

## Quick start

```bash
cd macos-setup
./install.sh          # apply macOS light theme stack + layout
./tweaks.sh dark      # switch to the dark macOS variant
./tweaks.sh light     # switch back to light
```

## What it gives you

- **Top macOS menu bar** (flush, translucent, floating applets): global menu,
  spacer, weather panel, system tray (Wi‑Fi, volume, brightness, battery),
  macOS clock (date beside time).
- **Bottom dock** (floating, centered, autohide): launcher, iContasks with
  magnification, trash can.
- **Liquid Glass** KWin effect + blur + rounded corners; macOS Aurorae window
  borders (Tiny, macOS left-side buttons).
- Clean icon-free desktop using the **MacTahoe** auto light/dark wallpaper.
- GTK4/GTK3 + Kvantum + SF Pro fonts coordinated with the Plasma theme.

## Reverting

`restore.sh` will undo everything back to the snapshot taken by `backup.sh`
(or point it at any earlier `plasma-backup-*.tar.gz`).

## Requirements

- Plasma 6 / KWin 6, `kwriteconfig6`, `qdbus6`, `python3`
- The MacTahoe Liquid KDE theme + SF Pro fonts already installed
