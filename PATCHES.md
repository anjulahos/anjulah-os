# Patches Applied to Base Debian 13

This document describes all modifications Anjulah OS applies on top of
the base Debian 13 (Trixie) GNOME live ISO. Each section explains the
purpose, approach, and key files involved.

For the complete list of file replacements via dpkg-divert,
see [DIVERT-LIST.md](DIVERT-LIST.md).

---

## 1. GNOME Control Center Wrapper (G_RESOURCE_OVERLAYS)

**Purpose:** Remove the broken "Pilih Berkas..." (Choose File) button
from the user avatar dialog in GNOME Settings. This is a known bug in
Debian 13's accountsservice that also affects Ubuntu and other derivatives.

**Approach:** Use GTK3's G_RESOURCE_OVERLAYS environment variable to
override the embedded cc-avatar-chooser.ui resource with a custom version
that omits the broken button.

**Files:**
- /usr/bin/gnome-control-center — Wrapper script (replaces original binary)
- /usr/bin/gnome-control-center.real — Original binary (renamed)
- /usr/local/share/gnome-control-center-overlay/cc-avatar-chooser.ui —
  Custom UI file containing only the GtkFlowBox (avatar grid),
  without the file chooser button

**Wrapper script content:**

    #!/bin/bash
    export G_RESOURCE_OVERLAYS="/org/gnome/control-center/system/users=/usr/local/share/gnome-control-center-overlay"
    exec /usr/bin/gnome-control-center.real "$@"

**Note:** This wrapper is NOT protected by dpkg-divert. Running
`apt upgrade` will replace it with the original binary. If this happens,
the wrapper must be re-applied manually (move binary to .real, create
wrapper script).

---

## 2. File Replacements via dpkg-divert (18 entries)

**Purpose:** Replace Debian branding with Anjulah OS branding across
the system — boot logos, login screen, About dialog, and OS identification.

**Approach:** Use `dpkg-divert --rename --add` to move original Debian
files to .distrib suffix, then place Anjulah replacements at the
original paths.

**Categories:**
- 12 vendor-logos (various sizes, PNG and SVG, for GRUB and login screen)
- 1 debian-logo (/usr/share/pixmaps/debian-logo.png — transparent image)
- 1 os-release (/etc/os-release — Anjulah OS identity)
- 1 gschema override (emptied, see Patch #4)
- 2 desktop files (modifications to system .desktop files)

**Full list with exact paths, commands, and file descriptions:**
See [DIVERT-LIST.md](DIVERT-LIST.md).

**Note:** The 18th entry (/usr/share/os-release, a symlink to
/etc/os-release) does not produce a .distrib file since it is a symlink.

---

## 3. Custom Calamares Modules

**Purpose:** Two custom modules enhance the Calamares installer — one
cleans up the live user after installation, and one fixes the GRUB
menu text.

**Location:** /usr/lib/calamares/modules/
(declared in /etc/calamares/settings.conf at lines 76 and 79)

### 3.1 cleanup-live-user

**Purpose:** Automatically remove the live session user (anjulah) and
all associated configuration after installation, so the installed system
only contains the user created by Calamares.

**Type:** job (interface: process)
**Helper script:** /usr/share/calamares/helpers/calamares-cleanup-live-user
**Timeout:** 120 seconds

**What it cleans:**
- Live user account (userdel -r --root $CHROOT)
- Sudoers entry for live user
- AccountsService entry for live user
- GDM auto-login configuration for live user
- Live-config files

**Position in Calamares:** After the built-in "users" module.

### 3.2 fix-grub-text

**Purpose:** Replace "Debian GNU/Linux" with "Anjulah OS" in the GRUB
menu after installation. The built-in grubcfg module writes
GRUB_DISTRIBUTOR from os-release, which would show "Debian GNU/Linux".
This module runs after grubcfg and performs a sed replacement.

**Type:** job (interface: process)
**Helper script:** /usr/share/calamares/helpers/calamares-fix-grub-text
**Timeout:** 600 seconds

**Position in Calamares:** After the built-in "grubcfg" module.

---

## 4. GSchema Override Modification

**Purpose:** Disable Calamares installer visibility in the live session
GNOME interface.

**Approach:** The original Debian file
96_calamares-settings-debian.gschema.override contained settings that
made Calamares accessible through GNOME in the live session. Anjulah OS
empties this file (0 bytes) to prevent Calamares from appearing outside
of its intended launcher.

**File:** /usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override
(0 bytes — emptied)

**Note:** This file is part of the dpkg-divert system. The original
Debian content is preserved as .distrib.
See [DIVERT-LIST.md](DIVERT-LIST.md) for details.

---

## 5. .desktop File Modifications

**Purpose:** Hide certain applications from the GNOME application grid
to reduce clutter and prevent user confusion.

**Modifications:**
- /usr/share/applications/org.gnome.Extensions.desktop — NoDisplay=true
- /usr/share/applications/com.mattjakeman.ExtensionManager.desktop — NoDisplay=true

**Rationale:** Extensions app and Extension Manager are power-user tools.
Hiding them from the grid reduces clutter for the target audience.

**Note:** NoDisplay=true hides from the application grid but does NOT
hide from GNOME Software. To fully hide from GNOME Software, the
corresponding .metainfo.xml file must also be removed.

---

## 6. Logo Replacement

**Purpose:** Replace all Debian logos with Anjulah OS branding throughout
the system — GRUB boot screen, GDM login screen, and GNOME About dialog.

**Replaced files (via dpkg-divert):**
- 12 vendor-logos in /usr/share/desktop-base/debian-logos/
  (logo, logo-text, logo-text-version — each in 64px, 128px, 256px PNG + SVG)
- 1 debian-logo in /usr/share/pixmaps/debian-logo.png
  (replaced with transparent image)

**Replaced files (via gresource rebuild):**
- Logo in GNOME Shell gresource (About dialog — requires gresource rebuild)

**Note:** The vendor-logos and debian-logo are managed via dpkg-divert.
See [DIVERT-LIST.md](DIVERT-LIST.md) for the complete divert list.
The gresource logo is rebuilt separately and is not part of the divert system.

---

## 7. os-release Replacement

**Purpose:** Identify the system as Anjulah OS instead of Debian in all
system-level identification.

**File:** /etc/os-release
(managed via dpkg-divert, original saved as /etc/os-release.distrib)

**Note:** The maintainer's name is intentionally NOT placed in
os-release — that file is for system identification, not attribution.
See /usr/share/doc/anjulah-os/AUTHORS for maintainer information.

---

## 8. Avatar System

**Purpose:** Allow users to change their avatar from the GNOME Settings
grid, despite the broken "Pilih Berkas..." button (see Patch #1).

**Approach:** Register a custom avatar directory via gsettings, populated
with example images. Users can select from the grid without needing the
file chooser.

**Files:**
- /usr/local/bin/setup-avatar-directories.sh — Script that sets
  org.gnome.desktop.avatar-directories gsettings key with the user's
  home directory path (uses $USER for dynamic expansion)
- /etc/skel/.config/autostart/setup-avatar-directories.desktop —
  Autostart entry that runs the script on first login, then deletes
  itself
- /etc/skel/Pictures/faces/ — Directory containing example avatar
  images (copied to new user's home by Calamares via /etc/skel/)
- /etc/skel/Pictures/README.txt — Instructions for adding custom
  avatars (placed in parent directory, NOT in faces/, because
  non-image files in avatar directories appear as empty boxes in
  the grid)

**How it works:**
1. Calamares copies /etc/skel/ to the new user's home during installation
2. On first login, the autostart entry runs setup-avatar-directories.sh
3. The script registers ~/Pictures/faces/ as an avatar directory
4. The autostart .desktop file deletes itself after execution
5. User can now select avatars from the grid in GNOME Settings

---

## 9. Anjulah Updater

**Purpose:** Provide a simple one-click update mechanism pinned to the
taskbar.

**Approach:** A .desktop file that opens a GNOME Terminal window running
`sudo apt update && sudo apt upgrade -y`. No separate script file — the
entire logic is in the Exec line.

**File:** /usr/share/applications/anjulah-updater.desktop
**Icon:** /usr/share/icons/hicolor/128x128/apps/anjulah-update.png

**Content:**

    [Desktop Entry]
    Name=Anjulah Update
    Comment=Update Anjulah OS system
    Exec=gnome-terminal --title="Anjulah Update" -- bash -c "sudo apt update && sudo apt upgrade -y; exec bash"
    Icon=anjulah-update
    Terminal=false
    Type=Application
    Categories=System;Settings;
    Keywords=update;upgrade;system;

**Behavior:**
- Opens a titled GNOME Terminal window
- User must enter their password (standard sudo, no NOPASSWD)
- All output is visible in the terminal (transparent process)
- Terminal stays open after completion (user closes manually)
- Does NOT run apt autoremove (user decides separately)
- Pinned to taskbar via favorite-apps dconf key

**Note:** No license header or author name is added — the file is too
small to warrant it. This is an intentional exception to the project's
header policy.

---

## 10. Favorite Apps (Taskbar)

**Purpose:** Configure the default taskbar (Dash to Panel) icons in the
live session.

**File:** /etc/dconf/db/local.d/03-dashtopanel-settings
**Section:** [org/gnome/shell]
(favorite-apps is a KEY under this path, not a separate path)

**Entries:**

    favorite-apps=['calamares-install-debian.desktop', 'firefox-esr.desktop', 'timeshift-gtk.desktop', 'org.gnome.DejaDup.desktop', 'org.gnome.Software.desktop', 'anjulah-os-user-guide.desktop', 'anjulah-updater.desktop']

**Post-install behavior:** After Calamares installation,
calamares-install-debian.desktop no longer exists on the installed
system. GNOME Shell silently ignores missing .desktop files — no broken
icon appears. The remaining 6 icons are displayed.

**Note:** The dconf keyfile must be compiled to a binary database
(/etc/dconf/db/local) using `dconf update` before rebuilding the ISO.
The section header MUST be [org/gnome/shell] — using
[org/gnome/shell/favorite-apps] will cause dconf to store it as a path
rather than a key, and the setting will have no effect.
