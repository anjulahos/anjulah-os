#!/bin/bash
# Setup Avatar Directories
# Register custom avatar directories for GNOME Settings avatar grid
# Part of Anjulah OS 1.0
# Created by: Cecep Purwana
# License: GPL-3.0-or-later
gsettings set org.gnome.desktop.interface avatar-directories "['/home/$USER/Pictures/faces', '/usr/share/pixmaps/faces']"
rm -f ~/.config/autostart/setup-avatar-directories.desktop
touch /tmp/avatar-setup-done

