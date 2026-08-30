#!/bin/bash
# deploy.sh — Deploy Anjulah OS files from repository to squashfs-root
# Part of Anjulah OS 1.0 Genesis
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# === VARIABLES ===
REPO="/home/haxor/anjulah-os-repo"
SQUASHFS="/home/haxor/remaster/squashfs-root"
ISO_EXTRACT="/home/haxor/remaster/iso-extract"

# === VALIDATION ===
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

if [ ! -d "$REPO" ]; then
    echo "Error: Repository not found at $REPO" >&2
    exit 1
fi

if [ ! -d "$SQUASHFS" ]; then
    echo "Error: squashfs-root not found at $SQUASHFS" >&2
    exit 1
fi

if [ ! -d "$ISO_EXTRACT" ]; then
    echo "Error: iso-extract not found at $ISO_EXTRACT" >&2
    exit 1
fi

if [ -e /proc/1/root/. ]; then
    if [ "$(stat -c %d:%i /)" = "$(stat -c %d:%i /proc/1/root/.)" ]; then
        :
    else
        echo "Error: Do not run this script inside a chroot." >&2
        exit 1
    fi
fi

echo "Deploying Anjulah OS files..."
echo "  Repository:    $REPO"
echo "  squashfs-root: $SQUASHFS"
echo "  iso-extract:   $ISO_EXTRACT"

# ============================================================
# PHASE 1: dpkg-divert (via chroot)
# ============================================================
echo ""
echo "=== Phase 1: dpkg-divert (18 entries) ==="

VENDOR_LOGO_DIR="/usr/share/desktop-base/debian-logos"
VENDOR_LOGOS="logo-64.png logo-128.png logo-256.png logo.svg
logo-text-64.png logo-text-128.png logo-text-256.png logo-text.svg
logo-text-version-64.png logo-text-version-128.png
logo-text-version-256.png logo-text-version.svg"

for f in $VENDOR_LOGOS; do
    chroot "$SQUASHFS" dpkg-divert --local --rename --add \
        --divert "${VENDOR_LOGO_DIR}/${f}.distrib" \
        "${VENDOR_LOGO_DIR}/${f}"
done

chroot "$SQUASHFS" dpkg-divert --local --rename --add \
    --divert "/usr/share/pixmaps/debian-logo.png.distrib" \
    "/usr/share/pixmaps/debian-logo.png"

chroot "$SQUASHFS" dpkg-divert --local --rename --add \
    --divert "/etc/os-release.distrib" \
    "/etc/os-release"

chroot "$SQUASHFS" dpkg-divert --local --rename --add \
    --divert "/usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override.distrib" \
    "/usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override"

chroot "$SQUASHFS" dpkg-divert --local --rename --add \
    --divert "/usr/share/applications/org.gnome.Extensions.desktop.distrib" \
    "/usr/share/applications/org.gnome.Extensions.desktop"

chroot "$SQUASHFS" dpkg-divert --local --rename --add \
    --divert "/usr/share/applications/com.mattjakeman.ExtensionManager.desktop.distrib" \
    "/usr/share/applications/com.mattjakeman.ExtensionManager.desktop"

echo "Phase 1 complete."

# ============================================================
# PHASE 2: File copies
# ============================================================
echo ""
echo "=== Phase 2: File copies ==="

# -- system/ --
cp "$REPO/system/os-release"              "$SQUASHFS/etc/os-release"
cp "$REPO/system/lsb-release"             "$SQUASHFS/etc/lsb-release"
cp "$REPO/system/hostname"                "$SQUASHFS/etc/hostname"
cp "$REPO/system/sources.list"            "$SQUASHFS/etc/apt/sources.list"
cp "$REPO/system/grub/grub"               "$SQUASHFS/etc/default/grub"
cp "$REPO/system/gdm-custom.conf"         "$SQUASHFS/etc/gdm3/custom.conf"
cp "$REPO/system/gdm-daemon.conf"         "$SQUASHFS/etc/gdm3/daemon.conf"
cp "$REPO/system/plymouthd.conf"          "$SQUASHFS/etc/plymouth/plymouthd.conf"
cp "$REPO/system/0010-anjulah.conf"       "$SQUASHFS/etc/live/config.d/"
cp "$REPO/system/00-anjulah-nopasswd"     "$SQUASHFS/etc/sudoers.d/"
cp "$REPO/system/96_calamares-settings-debian.gschema.override" \
                                         "$SQUASHFS/usr/share/glib-2.0/schemas/"
cp "$REPO/system/anjulah-wallpapers.xml"  "$SQUASHFS/usr/share/gnome-background-properties/"
ln -sf /etc/os-release                    "$SQUASHFS/usr/share/os-release"

# -- polkit/ --
cp "$REPO/polkit/"*.rules                 "$SQUASHFS/etc/polkit-1/rules.d/"

# -- dconf/ (keyfiles — compiled in Phase 3) --
cp "$REPO/dconf/01-anjulah-gdm"           "$SQUASHFS/etc/dconf/db/local.d/01-suppress-extensions"
cp "$REPO/dconf/02-arcmenu-settings"      "$SQUASHFS/etc/dconf/db/local.d/"
cp "$REPO/dconf/03-dashtopanel-settings"  "$SQUASHFS/etc/dconf/db/local.d/"
cp "$REPO/dconf/04-wallpaper-settings"    "$SQUASHFS/etc/dconf/db/local.d/"
cp "$REPO/dconf/05-appearance-settings"   "$SQUASHFS/etc/dconf/db/local.d/"
cp "$REPO/dconf/06-hotkey-settings"       "$SQUASHFS/etc/dconf/db/local.d/"
cp "$REPO/dconf/07-enabled-extensions"    "$SQUASHFS/etc/dconf/db/local.d/"
cp "$REPO/dconf/anjulah-locks"            "$SQUASHFS/etc/dconf/db/local.d/locks/"
cp "$REPO/dconf/profile-user"             "$SQUASHFS/etc/dconf/profile/user"

# -- plymouth/ --
mkdir -p "$SQUASHFS/usr/share/plymouth/themes/anjulah-theme"
cp "$REPO/plymouth/anjulah-theme.plymouth" "$SQUASHFS/usr/share/plymouth/themes/anjulah-theme/"
cp "$REPO/plymouth/anjulah-theme.script"   "$SQUASHFS/usr/share/plymouth/themes/anjulah-theme/"
cp "$REPO/assets/wallpaper-a2.png"         "$SQUASHFS/usr/share/plymouth/themes/anjulah-theme/wallpaper.png"
ln -sf /usr/share/plymouth/themes/anjulah-theme/anjulah-theme.plymouth \
                                           "$SQUASHFS/etc/alternatives/default.plymouth"

# -- calamares/ --
cp "$REPO/calamares/settings.conf"           "$SQUASHFS/etc/calamares/"
cp "$REPO/calamares/users.conf"              "$SQUASHFS/etc/calamares/"
mkdir -p "$SQUASHFS/etc/calamares/branding/anjulah"
cp "$REPO/calamares/branding.desc"           "$SQUASHFS/etc/calamares/branding/anjulah/"
cp "$REPO/calamares/show.qml"                "$SQUASHFS/etc/calamares/branding/anjulah/"
mkdir -p "$SQUASHFS/usr/lib/calamares/modules/cleanup-live-user"
cp "$REPO/calamares/cleanup-live-user.module.desc" \
                                              "$SQUASHFS/usr/lib/calamares/modules/cleanup-live-user/module.desc"
mkdir -p "$SQUASHFS/usr/lib/calamares/modules/fix-grub-text"
cp "$REPO/calamares/fix-grub-text.module.desc" \
                                              "$SQUASHFS/usr/lib/calamares/modules/fix-grub-text/module.desc"
cp "$REPO/calamares/calamares-cleanup-live-user" "$SQUASHFS/usr/share/calamares/helpers/"
cp "$REPO/calamares/calamares-fix-grub-text"    "$SQUASHFS/usr/share/calamares/helpers/"

# -- skel/ --
cp "$REPO/skel/avatar-default.png"              "$SQUASHFS/etc/skel/.face"
mkdir -p "$SQUASHFS/etc/skel/Pictures/faces"
cp "$REPO/skel/logo-anjulah-avatar.png"         "$SQUASHFS/etc/skel/Pictures/faces/logo-anjulah.png"
cp "$REPO/skel/Pictures-README.txt"             "$SQUASHFS/etc/skel/Pictures/README.txt"
mkdir -p "$SQUASHFS/etc/skel/.local/bin"
cp "$REPO/skel/power-menu.sh"                   "$SQUASHFS/etc/skel/.local/bin/"
mkdir -p "$SQUASHFS/etc/skel/.config/autostart"
cp "$REPO/skel/setup-avatar-directories.desktop" "$SQUASHFS/etc/skel/.config/autostart/"

# -- desktop-files/ --
cp "$REPO/desktop-files/"*.desktop              "$SQUASHFS/usr/share/applications/"

# -- scripts/ --
cp "$REPO/scripts/setup-avatar-directories.sh"  "$SQUASHFS/usr/local/bin/"
cp "$REPO/scripts/power-menu.sh"                 "$SQUASHFS/usr/local/bin/"

# -- gnome/ --
mkdir -p "$SQUASHFS/usr/local/share/gnome-control-center-overlay"
cp "$REPO/gnome/cc-avatar-chooser.ui"            "$SQUASHFS/usr/local/share/gnome-control-center-overlay/"

# -- guide/ --
mkdir -p "$SQUASHFS/usr/local/share/anjulah-os-guide"
cp "$REPO/guide/index.html"                      "$SQUASHFS/usr/local/share/anjulah-os-guide/"
cp "$REPO/guide/style.css"                       "$SQUASHFS/usr/local/share/anjulah-os-guide/"
cp "$REPO/assets/user-guide.png"                 "$SQUASHFS/usr/local/share/anjulah-os-guide/icon.png"

# -- assets/ (icons) --
mkdir -p "$SQUASHFS/usr/share/icons/hicolor/128x128/apps"
cp "$REPO/assets/install-anjulah.png"            "$SQUASHFS/usr/share/icons/hicolor/128x128/apps/"
cp "$REPO/assets/anjulah-update.png"             "$SQUASHFS/usr/share/icons/hicolor/128x128/apps/"

# -- assets/ (calamares branding) --
cp "$REPO/assets/logo-anjulah.png"               "$SQUASHFS/etc/calamares/branding/anjulah/"
cp "$REPO/assets/wallpaper-a4.png"               "$SQUASHFS/etc/calamares/branding/anjulah/"

# -- assets/ (avatars) --
for f in avatar-1.png avatar-2.png avatar-3.png avatar-4.png \
         avatar-6.png avatar-7.png avatar-8.png avatar-9.png avatar-10.png; do
    cp "$REPO/assets/avatars/$f" "$SQUASHFS/usr/share/pixmaps/faces/"
done

# -- vendor-logos/ (replacement files for diverted entries) --
for f in $VENDOR_LOGOS; do
    cp "$REPO/vendor-logos/$f" "$SQUASHFS${VENDOR_LOGO_DIR}/$f"
done
cp "$REPO/vendor-logos/debian-logo.png"          "$SQUASHFS/usr/share/pixmaps/debian-logo.png"

# -- gnome-shell/ (pre-compiled gresource) --
cp "$REPO/gnome-shell/gnome-shell-theme.gresource" \
                                               "$SQUASHFS/usr/share/gnome-shell/"

# -- AUTHORS --
mkdir -p "$SQUASHFS/usr/share/doc/anjulah-os"
cp "$REPO/AUTHORS"                              "$SQUASHFS/usr/share/doc/anjulah-os/"

# -- Set permissions --
chmod 440 "$SQUASHFS/etc/sudoers.d/00-anjulah-nopasswd"
chmod 755 "$SQUASHFS/usr/local/bin/setup-avatar-directories.sh"
chmod 755 "$SQUASHFS/usr/local/bin/power-menu.sh"
chmod 755 "$SQUASHFS/etc/skel/.local/bin/power-menu.sh"

echo "Phase 2 complete."

# ============================================================
# PHASE 3: Build operations
# ============================================================
echo ""
echo "=== Phase 3: Build operations ==="

# -- #1: gnome-control-center wrapper --
echo "  #1 gnome-control-center wrapper"
if [ -f "$SQUASHFS/usr/bin/gnome-control-center" ] && \
   [ ! -L "$SQUASHFS/usr/bin/gnome-control-center" ]; then
    mv "$SQUASHFS/usr/bin/gnome-control-center" \
       "$SQUASHFS/usr/bin/gnome-control-center.real"
fi
printf '#!/bin/bash\nexport G_RESOURCE_OVERLAYS="/org/gnome/control-center/system/users=/usr/local/share/gnome-control-center-overlay"\nexec /usr/bin/gnome-control-center.real "$@"\n' \
    > "$SQUASHFS/usr/bin/gnome-control-center"
chmod 755 "$SQUASHFS/usr/bin/gnome-control-center"

# -- #2: gnome-shell-theme.gresource (already copied in Phase 2) --
echo "  #2 gnome-shell-theme.gresource"

# -- #3: Convert wallpaper for GRUB and ISOLINUX --
echo "  #3 Wallpaper conversion (GRUB + ISOLINUX)"
convert "$REPO/assets/wallpaper-a7.png" \
    -resize 800x600 -type TrueColorAlpha -depth 8 \
    "$SQUASHFS/usr/share/icons/desktop-base/anjulah-grub-wallpaper.png"
convert "$REPO/assets/wallpaper-a7.png" \
    -resize '640x480!' -matte -colors 63 -type Palette -depth 8 \
    "$ISO_EXTRACT/live/splash.png"

# -- #7: gtk-update-icon-cache --
echo "  #7 gtk-update-icon-cache"
gtk-update-icon-cache -f "$SQUASHFS/usr/share/icons/hicolor"

# -- #8: dconf compile --
echo "  #8 dconf compile"
TMP_DCONF=$(mktemp -d)
mkdir -p "$TMP_DCONF/db/local.d/locks"
cp "$SQUASHFS/etc/dconf/db/local.d/"* "$TMP_DCONF/db/local.d/" 2>/dev/null || true
cp "$SQUASHFS/etc/dconf/db/local.d/locks/"* "$TMP_DCONF/db/local.d/locks/" 2>/dev/null || true
dconf compile "$TMP_DCONF/db/local" "$TMP_DCONF/db"
cp "$TMP_DCONF/db/local" "$SQUASHFS/etc/dconf/db/local"
rm -rf "$TMP_DCONF"

echo "Phase 3 complete."
echo ""
echo "Deploy complete. squashfs-root is ready for ISO compilation."
