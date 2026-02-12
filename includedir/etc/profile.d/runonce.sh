#!/bin/bash

# This file is executed at log in

if [ ! -e $HOME/.runonce ]
then
    flatpak override --user --filesystem=xdg-config/gtk-3.0
    flatpak override --user --filesystem=xdg-config/gtk-4.0
    touch $HOME/.runonce
    cat << 'EOF' > $HOME/.runonce
    ############################################################
    ###                                                      ###
    ### This file was created by /etc/profile.d/runoance.sh  ###
    ### Look on the file what commands is run. If you        ###
    ### delete this file at next logon commands is run       ###
    ### again at next log in                                 ###
    ### If you need do stop this delete or move the file     ###
    ### /etc/profile.d/runonce.sh                           ###
    ###                                                      ###
    ### If you wish to reset flatpak commands run next       ###
    ### flatpak override --user --reset                      ###
    ###                                                      ###
    ############################################################

EOF
    # add install.desktop for user brgos only because after install I delete file install.desktop from system
    if [ -e /usr/local/share/applications/install.desktop ]; then
	    mkdir -p $HOME/Desktop
	    cp /usr/local/share/applications/install.desktop $HOME/Desktop
        # do not autostart for brgvos user apparmor-notify.desktop
        sed -i 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' $HOME/.config/autostart/apparmor-notify.desktop
    fi 
    # Disable if audit or apparmor are not installed, maybe wish to install later the missing package
    if ! xbps-query -S audit >/dev/null 2>&1 || ! xbps-query -S apparmor >/dev/null 2>&1; then
        if [ -f "$HOME/.config/autostart/apparmor-notify.desktop" ]; then
            sed -i 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' "$HOME/.config/autostart/apparmor-notify.desktop"
        fi
    fi
    # Delete if audit and apparmor are not installed
    if ! xbps-query -S audit >/dev/null 2>&1 && ! xbps-query -S apparmor >/dev/null 2>&1; then
        if [ -f "$HOME/.config/autostart/apparmor-notify.desktop" ]; then
            rm -f "$HOME/.config/autostart/apparmor-notify.desktop"
            rm -f "$HOME/.local/bin/run-aa-notify.sh"
        fi
    fi
fi
