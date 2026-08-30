# DIVERT-LIST.md

This document lists all `dpkg-divert` operations applied in Anjulah OS 1.0 Genesis.

## What is dpkg-divert?

`dpkg-divert` is a Debian packaging tool that redirects a file to an alternative
location. When a package is updated via `apt upgrade`, the package manager will
not overwrite the diverted file — instead, it writes to the divert target
(typically `<filename>.distrib`). This allows custom files to persist across
package updates.

All diverts in Anjulah OS use the `--local` flag, meaning they are local to this
installation and not associated with any specific package.

**Important:** These commands are intended to be run inside a chroot environment
during the build process, not on a running system.

## Anjulah OS Divert List (18 entries)

### 1. Vendor Logos (12 entries)

**Purpose:** Replace Debian vendor logos with Anjulah OS logos.

**Path:** `/usr/share/desktop-base/debian-logos/`

**Files:**

| # | File |
|---|------|
| 1 | logo-64.png |
| 2 | logo-128.png |
| 3 | logo-256.png |
| 4 | logo.svg |
| 5 | logo-text-64.png |
| 6 | logo-text-128.png |
| 7 | logo-text-256.png |
| 8 | logo-text.svg |
| 9 | logo-text-version-64.png |
| 10 | logo-text-version-128.png |
| 11 | logo-text-version-256.png |
| 12 | logo-text-version.svg |

**Command pattern (run for each file):**

    dpkg-divert --local --rename --add \
      --divert /usr/share/desktop-base/debian-logos/<FILENAME>.distrib \
      /usr/share/desktop-base/debian-logos/<FILENAME>

After diverting, the original file is renamed to `<FILENAME>.distrib`.
Place the Anjulah OS replacement logo at the original path.

### 2. Debian Logo (1 entry)

**Purpose:** Replace the Debian logo (used in various system dialogs)
with Anjulah OS logo (transparent PNG).

**File:** `/usr/share/pixmaps/debian-logo.png`

**Command:**

    dpkg-divert --local --rename --add \
      --divert /usr/share/pixmaps/debian-logo.png.distrib \
      /usr/share/pixmaps/debian-logo.png

### 3. OS Release (2 entries, 1 symlink)

**Purpose:** Replace Debian OS identification with Anjulah OS identification.

**Files:**

- `/etc/os-release`
- `/usr/share/os-release` (symlink to `/etc/os-release`)

**Commands:**

    dpkg-divert --local --rename --add \
      --divert /etc/os-release.distrib \
      /etc/os-release

    ln -sf /etc/os-release /usr/share/os-release

**Note:** `/usr/share/os-release` is a symlink to `/etc/os-release`.
It cannot be diverted normally (no `.distrib` file is created).
After diverting `/etc/os-release` and placing the replacement,
recreate the symlink pointing to the new file.

### 4. GSchema Override (1 entry)

**Purpose:** Disable Calamares installer in live session
by overriding its GSchema setting.

**File:** `/usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override`

**Command:**

    dpkg-divert --local --rename --add \
      --divert /usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override.distrib \
      /usr/share/glib-2.0/schemas/96_calamares-settings-debian.gschema.override

After diverting, the custom override file disables the Calamares GSchema key,
preventing it from appearing in the live session. The original file is
preserved as `.distrib`.

### 5. Desktop Files (2 entries)

**Purpose:** Hide Extensions and Extension Manager from the application grid
by adding `NoDisplay=true`.

**Files:**

- `/usr/share/applications/org.gnome.Extensions.desktop`
- `/usr/share/applications/com.mattjakeman.ExtensionManager.desktop`

**Commands:**

    dpkg-divert --local --rename --add \
      --divert /usr/share/applications/org.gnome.Extensions.desktop.distrib \
      /usr/share/applications/org.gnome.Extensions.desktop

    dpkg-divert --local --rename --add \
      --divert /usr/share/applications/com.mattjakeman.ExtensionManager.desktop.distrib \
      /usr/share/applications/com.mattjakeman.ExtensionManager.desktop

After diverting, the replacement `.desktop` files contain `NoDisplay=true`
to hide them from the application grid.

## Notes

### gnome-control-center wrapper (WITHOUT divert)

The `gnome-control-center` wrapper script (which sets `G_RESOURCE_OVERLAYS`
to remove the broken "Pilih Berkas..." button from the avatar dialog) is
implemented by:

- Moving the original binary to `gnome-control-center.real`
- Placing a wrapper script at `gnome-control-center`

This is **NOT** a `dpkg-divert` operation. Adding a manual divert entry for
this caused `apt-get` to fail during Calamares installation (exit code 127).
The trade-off is accepted: `apt upgrade` will overwrite the wrapper, and the
user must manually restore it if needed.

### Diverts from Debian packages (not Anjulah OS)

The following diverts are created by Debian packages themselves, not by
Anjulah OS. They are listed here for reference so users are not confused
when inspecting the divert database:

- `calamares-settings-debian`: `calamares.desktop`
- `firefox-esr`: `firefox`
- `tmispell-voikko`: `ispell`
- `live-tools`: `update-initramfs` (2 entries)
- `luit`: `luit` + manpage
- `base-files`: `usr-merge` symlinks (`/lib32`, `/lib64`, `/libo32`, `/libx32`)
- `libreadline8t64`: 4 symlinks
- `libext2fs2t64`: 4 symlinks
- `libtirpc3t64`: 2 symlinks

### Summary

| Category | Entries | .distrib files |
|----------|---------|----------------|
| Vendor logos | 12 | 12 |
| Debian logo | 1 | 1 |
| OS release | 2 | 1 |
| GSchema override | 1 | 1 |
| Desktop files | 2 | 2 |
| **Total** | **18** | **17** |
