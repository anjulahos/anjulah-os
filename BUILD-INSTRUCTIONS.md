# BUILD-INSTRUCTIONS.md

## Prerequisites

- Debian 13 (Trixie) host system
- Root access (`sudo`)
- Required tools:
  - `dpkg-divert` (part of `dpkg`)
  - `convert` (ImageMagick)
  - `gtk-update-icon-cache`
  - `dconf` (part of `dconf-cli`)
- Paths:
  - Repository: `/home/haxor/anjulah-os-repo/`
  - squashfs-root: `/home/haxor/remaster/squashfs-root/`
  - iso-extract: `/home/haxor/remaster/iso-extract/`

## Repository Structure

    anjulah-os-repo/
    ├── assets/            Images: avatars, icons, wallpapers, logos
    ├── calamares/         Calamares installer config and helper scripts
    ├── dconf/             dconf keyfiles and lock definitions
    ├── desktop-files/     .desktop files for applications
    ├── gnome/             GNOME Control Center UI overlay
    ├── gnome-shell/       Pre-compiled gnome-shell-theme.gresource
    ├── guide/             Anjulah OS User Guide (HTML/CSS)
    ├── plymouth/          Plymouth boot theme
    ├── polkit/            PolicyKit rules
    ├── scripts/           Functional shell scripts
    ├── skel/              /etc/skel/ files for new user setup
    ├── system/            System configuration files
    ├── vendor-logos/      Replacement vendor logos (dpkg-divert targets)
    ├── deploy.sh          Deployment script
    ├── AUTHORS
    ├── LICENSE
    ├── BUILD-INSTRUCTIONS.md
    ├── COMPILE-INSTRUCTIONS.md
    ├── DIVERT-LIST.md
    ├── MAPPING.md
    ├── PATCHES.md
    └── README.md

## Deploy

    sudo bash /home/haxor/anjulah-os-repo/deploy.sh

The script performs three phases:

1. **dpkg-divert** — Registers 18 file diversions via chroot to protect custom files from being overwritten by `apt upgrade`. See `DIVERT-LIST.md` for the full list.

2. **File copies** — Deploys all repository files to their target locations in squashfs-root. See `MAPPING.md` for the complete file mapping.

3. **Build operations**:
   - Sets up the `gnome-control-center` wrapper script (G_RESOURCE_OVERLAYS for avatar UI)
   - Deploys pre-compiled `gnome-shell-theme.gresource` (GDM wallpaper)
   - Converts `wallpaper-a7.png` to GRUB background (800x600 TrueColorAlpha) and ISOLINUX splash (640x480 Palette, 63 colors)
   - Rebuilds GTK icon cache
   - Compiles dconf keyfiles into binary database (host-side workaround)

## Output

A modified `squashfs-root/` directory ready for ISO compilation.
