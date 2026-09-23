#!/bin/bash

# disable extensions used in Fluent
gnome-extensions disable 'mediacontrols@cliffniff.github.com'
gnome-extensions disable 'arcmenu@arcmenu.com'
gnome-extensions disable 'dash-to-panel@jderose9.github.com'
gnome-extensions disable 'tilingshell@ferrarodomenico.com'

# enable extensions used in WhiteSur
gnome-extensions enable 'dash-to-dock@micxgx.gmail.com'
gnome-extensions enable 'logomenu@aryan_k'
gnome-extensions enable 'space-bar@luchrioh'
gnome-extensions enable 'tiling-assistant@leleat-on-github'

# set interface to Light theme
dconf write /org/gnome/desktop/interface/accent-color "'red'"
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/cursor-theme "'MacTahoe-dark-cursors'"
dconf write /org/gnome/desktop/interface/gtk-theme "'WhiteSur-Dark-red'"
dconf write /org/gnome/desktop/interface/icon-theme "'WhiteSur-red-dark'"

# set user theme for WhiteSur
dconf write /org/gnome/shell/extensions/user-theme/name "'WhiteSur-Dark-red'"

# set theme for accent-gtk-theme
dconf write /org/gnome/shell/extensions/accent-gtk-theme/blue-theme-dark "'WhiteSur-Dark-blue'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/blue-theme-light "'WhiteSur-Light-blue'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/green-theme-dark "'WhiteSur-Dark-green'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/green-theme-light "'WhiteSur-Light-grey'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/orange-theme-dark "'WhiteSur-Dark-orange'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/orange-theme-light "'WhiteSur-Light-orange'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/pink-theme-dark "'WhiteSur-Dark-pink'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/pink-theme-light "'WhiteSur-Light-pink'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/purple-theme-dark "'WhiteSur-Dark-purple'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/purple-theme-light "'WhiteSur-Light-purple'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/red-theme-dark "'WhiteSur-Dark-red'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/red-theme-light "'WhiteSur-Light-red'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/slate-theme-dark "'WhiteSur-Dark-grey'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/slate-theme-light "'WhiteSur-Light-grey'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/teal-theme-dark "'WhiteSur-Dark-blue'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/teal-theme-light "'WhiteSur-Light-blue'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/yellow-theme-dark "'WhiteSur-Dark-yellow'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/yellow-theme-light "'WhiteSur-Light-yellow'"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/set-link-gtk4 "true"
dconf write /org/gnome/shell/extensions/accent-gtk-theme/set-theme-path "'/usr/share/themes'"

# set theme WhiteSur for accent-user-theme
dconf write /org/gnome/shell/extensions/accent-user-theme/blue-theme-dark "'WhiteSur-Dark-blue'"
dconf write /org/gnome/shell/extensions/accent-user-theme/blue-theme-light "'WhiteSur-Light-blue'"
dconf write /org/gnome/shell/extensions/accent-user-theme/green-theme-dark "'WhiteSur-Dark-green'"
dconf write /org/gnome/shell/extensions/accent-user-theme/green-theme-light "'WhiteSur-Light-grey'"
dconf write /org/gnome/shell/extensions/accent-user-theme/orange-theme-dark "'WhiteSur-Dark-orange'"
dconf write /org/gnome/shell/extensions/accent-user-theme/orange-theme-light "'WhiteSur-Light-orange'"
dconf write /org/gnome/shell/extensions/accent-user-theme/pink-theme-dark "'WhiteSur-Dark-pink'"
dconf write /org/gnome/shell/extensions/accent-user-theme/pink-theme-light "'WhiteSur-Light-pink'"
dconf write /org/gnome/shell/extensions/accent-user-theme/purple-theme-dark "'WhiteSur-Dark-purple'"
dconf write /org/gnome/shell/extensions/accent-user-theme/purple-theme-light "'WhiteSur-Light-purple'"
dconf write /org/gnome/shell/extensions/accent-user-theme/red-theme-dark "'WhiteSur-Dark-red'"dconf write /org/gnome/shell/extensions/accent-user-theme/red-theme-light "'WhiteSur-Light-red'"
dconf write /org/gnome/shell/extensions/accent-user-theme/slate-theme-dark "'WhiteSur-Dark-grey'"
dconf write /org/gnome/shell/extensions/accent-user-theme/slate-theme-light "'WhiteSur-Light-grey'"
dconf write /org/gnome/shell/extensions/accent-user-theme/teal-theme-dark "'WhiteSur-Dark-blue'"
dconf write /org/gnome/shell/extensions/accent-user-theme/teal-theme-light "'WhiteSur-Light-blue'"
dconf write /org/gnome/shell/extensions/accent-user-theme/yellow-theme-dark "'WhiteSur-Dark-yellow'"
dconf write /org/gnome/shell/extensions/accent-user-theme/yellow-theme-light "'WhiteSur-Light-yellow'"

# set WhiteSur icons for accent-icons-theme
dconf write /org/gnome/shell/extensions/accent-icons-theme/blue-theme-dark "'WhiteSur-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/blue-theme-light "'WhiteSur-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/green-theme-dark "'WhiteSur-green-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/green-theme-light "'WhiteSur-green-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/orange-theme-dark "'WhiteSur-orange-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/orange-theme-light "'WhiteSur-orange-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/pink-theme-dark "'WhiteSur-pink-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/pink-theme-light "'WhiteSur-pink-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/purple-theme-dark "'WhiteSur-purple-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/purple-theme-light "'WhiteSur-purple-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/red-theme-dark "'WhiteSur-red-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/red-theme-light "'WhiteSur-red-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/slate-theme-dark "'WhiteSur-grey-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/slate-theme-light "'WhiteSur-grey-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/teal-theme-dark "'WhiteSur-nord-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/teal-theme-light "'WhiteSur-nord-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/yellow-theme-dark "'WhiteSur-yellow-dark'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/yellow-theme-light "'WhiteSur-yellow-light'"
dconf write /org/gnome/shell/extensions/accent-icons-theme/change-app-colors "false"

# set WhiteSur light-dark-cursor-theme
dconf write /org/gnome/shell/extensions/light-dark-cursor-theme/default "'MacTahoe-cursors'"
dconf write /org/gnome/shell/extensions/light-dark-cursor-theme/prefer-dark "'MacTahoe-dark-cursors'"

# set WhiteSur background
dconf write /org/gnome/desktop/background/color-shading-type "'solid'"
dconf write /org/gnome/desktop/background/picture-options "'zoom'"
dconf write /org/gnome/desktop/background/picture-uri "'file:///usr/share/backgrounds/gnome/ios-l-r.jpg'"
dconf write /org/gnome/desktop/background/picture-uri-dark "'file:///usr/share/backgrounds/gnome/ios-d-r.jpg'"
dconf write /org/gnome/desktop/background/primary-color "'#ff0000'"
dconf write /org/gnome/desktop/background/secondary-color "'#00ffff'"

# set preferences position for buttons on windows
dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,minimize,maximize:appmenu'"

# set position on panel for simple-weather
dconf write /org/gnome/shell/extensions/simple-weather/panel-box "'center'"
dconf write /org/gnome/shell/extensions/simple-weather/main-location-index "int64 0"
dconf write /org/gnome/shell/extensions/simple-weather/panel-priority "int64 0"

# set space-bar appearence
dconf write /org/gnome/shell/extensions/space-bar/appearance/active-workspace-text-color "'rgb(255,255,255)'"
dconf write /org/gnome/shell/extensions/space-bar/appearance/inactive-workspace-text-color "'rgb(222,221,218)'"

# in Wayland we can't restart gnome-shell so next message work only X
#killall -HUP gnome-shell

# so in Wayland logout is solution with prompt maybe is necessary to save something
gnome-session-quit
