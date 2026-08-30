# MAPPING.md
# Anjulah OS — Source Repository to System File Mapping
#
# This document maps every file in the Anjulah OS source repository
# to its target location in the live system (squashfs-root).
# The format follows the repository folder structure.
# Build operations that are not simple file copies are at the end.

---

## 1. system/

- `os-release` → `/etc/os-release`
- `lsb-release` → `/etc/lsb-release`
- `hostname` → `/etc/hostname`
- `sources.list` → `/etc/apt/sources.list`
- `grub/grub` → `/etc/default/grub`
- `gdm-custom.conf` → `/etc/gdm3/custom.conf`
- `gdm-daemon.conf` → `/etc/gdm3/daemon.conf`
- `plymouthd.conf` → `/etc/plymouth/plymouthd.conf`
- `0010-anjulah.conf` → `/etc/live/config.d/0010-anjulah.conf`
- `00-anjulah-nopasswd` → `/etc/sudoers.d/00-anjulah-nopasswd`
- `96_calamares-settings-debian.gschema.override` → `/usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override` (0 byte, emptied to remove Calamares settings in live session)
- `anjulah-wallpapers.xml` → `/usr/share/gnome-background-properties/anjulah-wallpapers.xml`

## 2. polkit/

- `00-allow-calamares.rules` → `/etc/polkit-1/rules.d/00-allow-calamares.rules`
- `01-allow-mount.rules` → `/etc/polkit-1/rules.d/01-allow-mount.rules`
- `02-allow-gparted.rules` → `/etc/polkit-1/rules.d/02-allow-gparted.rules`
- `03-allow-timezone.rules` → `/etc/polkit-1/rules.d/03-allow-timezone.rules`
- `49-allow-sudo-group.rules` → `/etc/polkit-1/rules.d/49-allow-sudo-group.rules`

## 3. dconf/

- `01-anjulah-gdm` → `/etc/dconf/db/local.d/01-suppress-extensions` (RENAME)
- `02-arcmenu-settings` → `/etc/dconf/db/local.d/02-arcmenu-settings`
- `03-dashtopanel-settings` → `/etc/dconf/db/local.d/03-dashtopanel-settings` (contains favorite-apps)
- `04-wallpaper-settings` → `/etc/dconf/db/local.d/04-wallpaper-settings`
- `05-appearance-settings` → `/etc/dconf/db/local.d/05-appearance-settings`
- `06-hotkey-settings` → `/etc/dconf/db/local.d/06-hotkey-settings`
- `07-enabled-extensions` → `/etc/dconf/db/local.d/07-enabled-extensions`
- `anjulah-locks` → `/etc/dconf/db/local.d/locks/`

## 4. plymouth/

- `anjulah-theme.plymouth` → `/usr/share/plymouth/themes/anjulah-theme/anjulah-theme.plymouth`
- `anjulah-theme.script` → `/usr/share/plymouth/themes/anjulah-theme/anjulah-theme.script`

## 5. calamares/

- `settings.conf` → `/etc/calamares/settings.conf`
- `users.conf` → `/etc/calamares/users.conf`
- `branding.desc` → `/etc/calamares/branding/anjulah/branding.desc`
- `show.qml` → `/etc/calamares/branding/anjulah/show.qml`
- `cleanup-live-user.module.desc` → `/usr/lib/calamares/modules/cleanup-live-user/module.desc`
- `fix-grub-text.module.desc` → `/usr/lib/calamares/modules/fix-grub-text/module.desc`
- `calamares-cleanup-live-user` → `/usr/share/calamares/helpers/calamares-cleanup-live-user`
- `calamares-fix-grub-text` → `/usr/share/calamares/helpers/calamares-fix-grub-text`

## 6. skel/

- `avatar-default.png` → `/etc/skel/.face` (RENAME)
- `logo-anjulah-avatar.png` → `/etc/skel/Pictures/faces/logo-anjulah.png` (RENAME)
- `Pictures-README.txt` → `/etc/skel/Pictures/README.txt` (RENAME)
- `power-menu.sh` → `/etc/skel/.local/bin/power-menu.sh`
- `setup-avatar-directories.desktop` → `/etc/skel/.config/autostart/setup-avatar-directories.desktop`

## 7. desktop-files/

- `anjulah-os-user-guide.desktop` → `/usr/share/applications/anjulah-os-user-guide.desktop`
- `calamares-install-debian.desktop` → `/usr/share/applications/calamares-install-debian.desktop`
- `com.mattjakeman.ExtensionManager.desktop` → `/usr/share/applications/com.mattjakeman.ExtensionManager.desktop`
- `org.gnome.Extensions.desktop` → `/usr/share/applications/org.gnome.Extensions.desktop`
- `org.gnome.Help.desktop` → `/usr/share/applications/org.gnome.Help.desktop`
- `org.gnome.Settings.desktop` → `/usr/share/applications/org.gnome.Settings.desktop`

## 8. scripts/

- `setup-avatar-directories.sh` → `/usr/local/bin/setup-avatar-directories.sh`
- `power-menu.sh` → `/usr/local/bin/power-menu.sh` (also copied to `/etc/skel/.local/bin/power-menu.sh` via skel/)

## 9. gnome/

- `cc-avatar-chooser.ui` → `/usr/local/share/gnome-control-center-overlay/cc-avatar-chooser.ui`

## 10. guide/

- `index.html` → `/usr/local/share/anjulah-os-guide/index.html`
- `style.css` → `/usr/local/share/anjulah-os-guide/style.css`

## 11. assets/

Files in this folder are processed or renamed during build, not copied directly.

- `avatars/avatar-1.png` → `/usr/share/pixmaps/faces/avatar-1.png`
- `avatars/avatar-2.png` → `/usr/share/pixmaps/faces/avatar-2.png`
- `avatars/avatar-3.png` → `/usr/share/pixmaps/faces/avatar-3.png`
- `avatars/avatar-4.png` → `/usr/share/pixmaps/faces/avatar-4.png`
- `avatars/avatar-6.png` → `/usr/share/pixmaps/faces/avatar-6.png`
- `avatars/avatar-7.png` → `/usr/share/pixmaps/faces/avatar-7.png`
- `avatars/avatar-8.png` → `/usr/share/pixmaps/faces/avatar-8.png`
- `avatars/avatar-9.png` → `/usr/share/pixmaps/faces/avatar-9.png`
- `avatars/avatar-10.png` → `/usr/share/pixmaps/faces/avatar-10.png` (avatar-5 removed in session 94)
- `install-anjulah.png` → `/usr/share/icons/hicolor/128x128/apps/install-anjulah.png`
- `logo-anjulah.png` → `/etc/calamares/branding/anjulah/logo-anjulah.png`
- `user-guide.png` → `/usr/local/share/anjulah-os-guide/icon.png` (RENAME)
- `wallpaper-a2.png` → `/usr/share/plymouth/themes/anjulah-theme/wallpaper.png` (RENAME, Plymouth wallpaper)
- `wallpaper-a3.png` → embedded in `gnome-shell-theme.gresource` (see Build Operations)
- `wallpaper-a4.png` → `/etc/calamares/branding/anjulah/wallpaper-a4.png` (Calamares welcome screen)
- `wallpaper-a7.png` → converted for GRUB background and ISOLINUX splash (see Build Operations)

## 12. vendor-logos/

Replacement files for dpkg-diverted Debian vendor logos and branding.

- `logo-64.png` → `/usr/share/desktop-base/debian-logos/logo-64.png`
- `logo-128.png` → `/usr/share/desktop-base/debian-logos/logo-128.png`
- `logo-256.png` → `/usr/share/desktop-base/debian-logos/logo-256.png`
- `logo.svg` → `/usr/share/desktop-base/debian-logos/logo.svg`
- `logo-text-64.png` → `/usr/share/desktop-base/debian-logos/logo-text-64.png`
- `logo-text-128.png` → `/usr/share/desktop-base/debian-logos/logo-text-128.png`
- `logo-text-256.png` → `/usr/share/desktop-base/debian-logos/logo-text-256.png`
- `logo-text.svg` → `/usr/share/desktop-base/debian-logos/logo-text.svg`
- `logo-text-version-64.png` → `/usr/share/desktop-base/debian-logos/logo-text-version-64.png`
- `logo-text-version-128.png` → `/usr/share/desktop-base/debian-logos/logo-text-version-128.png`
- `logo-text-version-256.png` → `/usr/share/desktop-base/debian-logos/logo-text-version-256.png`
- `logo-text-version.svg` → `/usr/share/desktop-base/debian-logos/logo-text-version.svg`
- `debian-logo.png` → `/usr/share/pixmaps/debian-logo.png`

## 13. gnome-shell/

- `gnome-shell-theme.gresource` → `/usr/share/gnome-shell/gnome-shell-theme.gresource` (pre-compiled, contains custom GDM wallpaper)

## 14. Build Operations

Build operations that are not simple file copies from the repository to squashfs-root:

1. **Setup gnome-control-center wrapper + .real**
   The original binary is moved to `/usr/bin/gnome-control-center.real`, then a wrapper script is created at `/usr/bin/gnome-control-center` that sets `G_RESOURCE_OVERLAYS` and executes the .real binary. This overlays a custom UI file to remove the non-functional "Choose a File..." button from the avatar chooser dialog.

2. **Deploy gnome-shell-theme.gresource**
      The pre-compiled gresource file from `gnome-shell/` is copied to `/usr/share/gnome-shell/gnome-shell-theme.gresource`. GDM reads the wallpaper from the gresource (resource:///), not from a physical file.

3. **Convert wallpaper-a7.png for GRUB and ISOLINUX**
   `assets/wallpaper-a7.png` is converted to two different formats: TrueColorAlpha for the GRUB background (`/usr/share/icons/desktop-base/anjulah-grub-wallpaper.png`) and Palette for the ISOLINUX splash (`splash.png` in iso-extract/). Conversion parameter details are in BUILD-INSTRUCTIONS.md.

4. **Copy anjulah-updater.desktop**
   The .desktop file for the update icon in the taskbar is copied to `/usr/share/applications/anjulah-updater.desktop`. Its Exec line runs `gnome-terminal` with `sudo apt update && sudo apt upgrade -y`.

5. **Copy anjulah-update.png**
   The custom updater icon is copied to `/usr/share/icons/hicolor/128x128/apps/anjulah-update.png`.

6. **Create and copy AUTHORS**
   The file `/usr/share/doc/anjulah-os/AUTHORS` contains copyright information and the maintainer name.

7. **gtk-update-icon-cache -f**
   Rebuilds the icon cache after all icon files are in place, so that new icons are recognized by the system.

8. **dconf update**
   Compiles the keyfiles in `/etc/dconf/db/local.d/` into a binary at `/etc/dconf/db/local`. Must be run after all keyfiles are in place.

9. **dpkg-divert setup**
   18 dpkg-divert entries to redirect default Debian files. Full details are in DIVERT-LIST.md.

10. **Create /etc/dconf/profile/user**
    File containing the dconf profile configuration: `user-db:user` and `system-db:local`.
