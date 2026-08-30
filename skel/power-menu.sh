#!/bin/bash
# Power Menu
# System power menu dialog (Lock, Logout, Restart, Shutdown)
# Part of Anjulah OS 1.0
# Created by: Cecep Purwana
# License: GPL-3.0-or-later

PILIHAN=$(zenity --list --title="Menu Sistem" --width=250 --height=280 \
--text="Pilih aksi yang ingin dilakukan:" \
--column="Aksi" \
"Lock Screen" \
"Logout" \
"Restart" \
"Shutdown")

case "$PILIHAN" in
"Lock Screen")
loginctl lock-session
;;
"Logout")
gnome-session-quit --logout --no-prompt
;;
"Restart")
systemctl reboot
;;
"Shutdown")
systemctl poweroff
;;
esac
