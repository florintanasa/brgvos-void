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
    ### If you need do stop this delte or move file.         ###
    ###                                                      ###
    ### If you wish to reset flatpak commands run next       ###
    ### flatpak override --user --reset                      ###
    ###                                                      ###
    ############################################################

EOF
    # add install.desktop for user brgos only because after install I delete file install.desktop
    if [ -e /usr/local/share/applications/install.desktop ]; then
	mkdir -p $HOME/Desktop
	cp /usr/local/share/applications/install.desktop $HOME/Desktop
    fi
fi
