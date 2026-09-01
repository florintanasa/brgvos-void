#!/bin/bash

# disable extensions used in MacTahoe
gnome-extensions disable 'dash-to-dock@micxgx.gmail.com'
gnome-extensions disable 'logomenu@aryan_k'
gnome-extensions disable 'space-bar@luchrioh'
gnome-extensions disable 'tiling-assistant@leleat-on-github'

# enable extensions to be used in Fluent
gnome-extensions enable 'mediacontrols@cliffniff.github.com'
gnome-extensions enable 'arcmenu@arcmenu.com'
gnome-extensions enable 'dash-to-panel@jderose9.github.com'
gnome-extensions enable 'tilingshell@ferrarodomenico.com'

# set interface to Light theme
dconf write /org/gnome/desktop/interface/accent-color "'blue'"
dconf write /org/gnome/desktop/interface/color-scheme "'default'"
dconf write /org/gnome/desktop/interface/cursor-theme "'Fluent-cursors'"
dconf write /org/gnome/desktop/interface/gtk-theme "'Fluent-round-Light'"
dconf write /org/gnome/desktop/interface/icon-theme "'Fluent-light'"

# set user theme for Fluent
dconf write /org/gnome/shell/extensions/user-theme/name "'Fluent-round-Light'"

# set theme for accent-gtk-theme
dconf write /org/gnome/shell/extensions/accent-gtk-theme/blue-theme-dark "'Fluent-round-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/blue-theme-light "'Fluent-round-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/green-theme-dark "'Fluent-round-green-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/green-theme-light "'Fluent-round-green-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/orange-theme-dark "'Fluent-round-orange-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/orange-theme-light "'Fluent-round-orange-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/pink-theme-dark "'Fluent-round-pink-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/pink-theme-light "'Fluent-round-pink-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/purple-theme-dark "'Fluent-round-purple-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/purple-theme-light "'Fluent-round-purple-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/red-theme-dark "'Fluent-round-red-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/red-theme-light "'Fluent-round-red-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/slate-theme-dark "'Fluent-round-grey-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/slate-theme-light "'Fluent-round-grey-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/teal-theme-dark "'Fluent-round-teal-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/teal-theme-light "'Fluent-round-teal-Light-compact'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/yellow-theme-dark "'Fluent-round-yellow-Dark'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/yellow-theme-light "'Fluent-round-yellow-Light'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/set-link-gtk4 "true"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/set-theme-path "'/usr/share/themes'"

# set theme Fluent for accent-user-theme
dconf write /org/gnome/shell/extensions/accent-user-theme/blue-theme-dark "'Fluent-round-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/blue-theme-light "'Fluent-round-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/green-theme "'Fluent-round-green-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/green-theme-dark "'Fluent-round-green-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/green-theme-light "'Fluent-round-green-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/orange-theme-dark "'Fluent-round-orange-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/orange-theme-light "'Fluent-round-orange-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/pink-theme-dark "'Fluent-round-pink-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/pink-theme-light "'Fluent-round-pink-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/purple-theme-dark "'Fluent-round-purple-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/purple-theme-light "'Fluent-round-purple-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/red-theme-dark "'Fluent-round-red-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/red-theme-light "'Fluent-round-red-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/slate-theme-dark "'Fluent-round-grey-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/slate-theme-light "'Fluent-round-grey-Light'"
dconf write /org/gnome/shell/extensions/accent-user-theme/teal-theme-dark "'Fluent-round-teal-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/teal-theme-light "'Fluent-round-teal-Light-compact'"
dconf write /org/gnome/shell/extensions/accent-user-theme/yellow-theme-dark "'Fluent-round-yellow-Dark'"
dconf write /org/gnome/shell/extensions/accent-user-theme/yellow-theme-light "'Fluent-round-yellow-Light'"

# set Fluent icons for accent-icons-theme
dconf write /org/gnome/shell/extensions/accent-icons-theme/blue-theme-dark "'Fluent-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/blue-theme-light "'Fluent-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/green-theme-dark "'Fluent-green-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/green-theme-light "'Fluent-green-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/orange-theme-dark "'Fluent-orange-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/orange-theme-light "'Fluent-orange-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/pink-theme-dark "'Fluent-purple-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/pink-theme-light "'Fluent-purple-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/purple-theme-dark "'Fluent-purple-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/purple-theme-light "'Fluent-purple-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/red-theme-dark "'Fluent-red-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/red-theme-light "'Fluent-red-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/slate-theme-dark "'Fluent-grey-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/slate-theme-light "'Fluent-grey-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/teal-theme-dark "'Fluent-teal-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/teal-theme-light "'Fluent-teal-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/yellow-theme-dark "'Fluent-yellow-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/yellow-theme-light "'Fluent-yellow-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/change-app-colors "false"

# set Fluent light-dark-cursor-theme
dconf write /org/gnome/shell/extensions/light-dark-cursor-theme/default "'Fluent-cursors'"
dconf write /org/gnome/shell/extensions/light-dark-cursor-theme/prefer-dark "'Fluent-dark-cursors'"

# set Fluent background
dconf write /org/gnome/desktop/background/color-shading-type "'solid'"
dconf write /org/gnome/desktop/background/picture-options "'zoom'"
dconf write /org/gnome/desktop/background/picture-uri "'file:///usr/share/backgrounds/gnome/fluent_3-l.png'"
dconf write /org/gnome/desktop/background/picture-uri-dark "'file:///usr/share/backgrounds/gnome/fluent_3-d.png'"
dconf write /org/gnome/desktop/background/primary-color "'#ff0000'"
dconf write /org/gnome/desktop/background/secondary-color "'#00ffff'"

# set preferences position for buttons on windows
dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'"

# set position on panel for simple-weather
dconf write /org/gnome/shell/extensions/simple-weather/panel-box "'left'"
dconf write /org/gnome/shell/extensions/simple-weather/main-location-index "int64 0"

# in Wayland we can't restart gnome-shell so next message work only X
#killall -HUP gnome-shell

# so in Wayland logout is solution with prompt maybe is necessary to save something
gnome-session-quit
