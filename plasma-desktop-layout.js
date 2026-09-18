// macOS Tahoe layout for Plasma 6 (rebuilt from a clean shell state)
// Top menu bar + bottom dock. Derived from the MacTahoe L&F layout.

var old = panels();
for (var i = 0; i < old.length; i++) {
    old[i].remove();
}

// ── top menu bar ────────────────────────────────
var bar = new Panel("org.kde.panel");
bar.location = "top";
bar.screen = 0;
bar.lengthMode = "fill";
bar.floating = false;
bar.hiding = "none";
bar.height = 32;

// panel colorizer: transparent background, floating applet popups
var colorizer = bar.addWidget("luisbocanegra.panel.colorizer");
if (colorizer) {
    colorizer.currentConfigGroup = ["General"];
    colorizer.writeConfig("globalSettings", JSON.stringify({
        "nativePanel": {
            "background": { "enabled": false, "opacity": 0, "shadow": false },
            "floatingDialogs": true
        }
    }));
    colorizer.currentConfigGroup = ["Configuration"];
    colorizer.writeConfig("hideWidget", "true");
}

// macOS Title Menu (global menu)
bar.addWidget("org.kde.mac.tahoe.liquid.globalmenu");
bar.addWidget("org.kde.plasma.panelspacer");

// compact weather panel (macOS-style)
bar.addWidget("com.jaxparrow07.macoswidgets.weatherpanel");

// system tray — macOS style, wifi/brightness/volume/battery visible
var tray = bar.addWidget("org.kde.plasma.systemtray");
tray.currentConfigGroup = ["General"];
tray.writeConfig("shownItems", "org.kde.plasma.bluetooth,org.kde.plasma.networkmanagement,org.kde.plasma.brightness,org.kde.plasma.volume,org.kde.plasma.battery");
tray.writeConfig("hiddenItems", "org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.keyboardindicator,org.kde.plasma.weather,org.kde.kscreen,org.kde.plasma.keyboardlayout,org.kde.plasma.printmanager,org.kde.plasma.cameraindicator,org.kde.plasma.vault,org.kde.kdeconnect,Arch-Update,chrome_status_icon_1,discord,plasmashell_microphone,steam,spotify,telegram,slack");
tray.writeConfig("iconSpacing", 3);

bar.addWidget("org.kde.plasma.marginsseparator");

var clock = bar.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("autoFontAndSize", "false");
clock.writeConfig("fontFamily", "SF Pro Text");
clock.writeConfig("fontSize", 10);
clock.writeConfig("fontWeight", 500);
clock.writeConfig("showDate", "true");
clock.writeConfig("use24hFormat", 1);
clock.writeConfig("showSeconds", 0);
clock.writeConfig("dateDisplayFormat", "BesideTime");
clock.writeConfig("dateFormat", "custom");
clock.writeConfig("customDateFormat", "ddd d ' | '");

// ── bottom dock ─────────────────────────────────
var dock = new Panel("org.kde.panel");
dock.location = "bottom";
dock.screen = 0;
dock.alignment = "center";
dock.lengthMode = "fit";
dock.floating = true;
// Auto-hide avoids the stuck-visible dodge behavior.
dock.hiding = "autohide";
dock.height = 68;

var launcher = dock.addWidget("org.kde.mac-tahoe-liquid-kde.launcher");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "view-app-grid");
dock.addWidget("org.kde.plasma.marginsseparator");

var tasks = dock.addWidget("org.kde.mac.tahoe.liquid.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "preferred://filemanager,preferred://terminal,preferred://browser,applications:systemsettings.desktop,applications:steam.desktop,applications:obsidian.desktop,applications:org.telegram.desktop.desktop");

dock.addWidget("org.kde.plasma.marginsseparator");
dock.addWidget("org.kde.mac-tahoe-liquid-kde.trashcan");