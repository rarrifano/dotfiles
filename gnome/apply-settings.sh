#!/bin/sh

set -eu

gsettings set org.gnome.Ptyxis tab-middle-click 'paste'
gsettings set org.gnome.Ptyxis.Shortcuts move-next-tab '<ctrl>Tab'
gsettings set org.gnome.Ptyxis.Shortcuts move-previous-tab '<ctrl><shift>Tab'
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left \
  "['<Control><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right \
  "['<Control><Super>Right']"
