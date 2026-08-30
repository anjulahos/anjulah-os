# Compile Instructions

## Prerequisites

- `squashfs-tools` (provides `mksquashfs`)
- `xorriso`
- `isolinux` (provides `/usr/lib/ISOLINUX/isohdpfx.bin`)

Expected directory structure:

    <squashfs-root>/          # deployed root filesystem
    <iso-extract>/            # ISO skeleton
    ├── boot/
    ├── EFI/
    ├── efi.img
    ├── isolinux/
    └── live/
        ├── filesystem.packages
        ├── initrd.img
        └── vmlinuz

## Compile

### Full Build

Run `mksquashfs` first, then `xorriso`. Both require `sudo`.

    sudo mksquashfs <squashfs-root> <iso-extract>/live/filesystem.squashfs \
      -comp xz -Xbcj x86 -b 1M -Xdict-size 1M -noappend

    sudo xorriso -as mkisofs \
      -r \
      -V "ANJULAH_OS" \
      -o <output.iso> \
      -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
      -b isolinux/isolinux.bin \
      -c isolinux/boot.cat \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
      -eltorito-alt-boot \
      -e boot/grub/efi.img \
      -no-emul-boot \
      -isohybrid-gpt-basdat \
      <iso-extract>/

### XORRISO-ONLY

If only files under `<iso-extract>/` have changed (no changes to `<squashfs-root>/`), skip `mksquashfs` and run `xorriso` alone. This reduces build time by approximately 2.5 hours.

    sudo xorriso -as mkisofs \
      -r \
      -V "ANJULAH_OS" \
      -o <output.iso> \
      -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
      -b isolinux/isolinux.bin \
      -c isolinux/boot.cat \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
      -eltorito-alt-boot \
      -e boot/grub/efi.img \
      -no-emul-boot \
      -isohybrid-gpt-basdat \
      <iso-extract>/

## Output

The build produces a hybrid ISO supporting both BIOS Legacy and UEFI boot.

After build, generate checksum and GPG signature:

    sha256sum <output.iso> > <output.iso>.sha256sum

    gpg --detach-sign --armor <output.iso>
