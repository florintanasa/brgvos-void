#!/bin/bash
#-
# Copyright (c) 2026 Florin Tanasă <florin.tanasa@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# License GPLv3
#-
# Check for flag and if flag is not '2' or '4' check if the script is run by root
if [[ "$1" == "2" || "$1" == "4" || "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Run the script for current user, only for parameters '2', '4' or '--help'"
elif [[ "$(id -u)" != "0" ]]; then
  echo "this script must run as root" 1>&2
  exit 1
fi

# Set variables for text formating
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

# Set some variables
app_folders="/etc/dconf/db/local.d/27-app-folders"
extensions_arcmenu="/etc/dconf/db/local.d/12-extensions-arcmenu"
input_sources="/etc/dconf/db/local.d/01-input-sources"

# Get username
username=$(logname)

function display_help() {
  echo -e "${bold}${cyan}Usage:${reset}"
  echo -e "  ./set_ro_RO_gnome.sh [PARAMETER]"
  echo -e "\n${bold}${cyan}Description:${reset}"
  echo -e "  This script add modify for Romanian language, from English to Romanian, in dconf for all new users and/or actual user"
  echo -e "  Also, set as keyboard 'ro' and install some localized packages xbps."
  echo -e "  If a the user provide an ARGUMENT, like '1' or '2' or '1 2' this script is run directly"
  echo -e "  If a the user not provide an ARGUMENT appear a menu with some options."
  echo -e "\n${bold}${cyan}Options${reset}:"
  echo -e "     ${magenta}With PARAMETER\tModify for Romanian language, for all new user or actual user.${reset}"
  echo -e "  ${yellow}Without PARAMETER\tIs open a options menu with next options:${reset}"
  echo -e "  ${blue}Option 1 - Modify for Romanian language, from English to Romanian, in dconf for${reset}"
  echo -e "             ${blue}all new users, add 'ro' keyboard and add additional packages for localized language.${reset}"
  echo -e "  ${blue}Option 2 - Modify for Romanian language, from English to Romanian, in dconf for${reset}"
  echo -e "             ${blue}current user, add 'ro' keyboard and add additional packages for localized language.${reset}"
  echo -e "  ${blue}Option 3 - Modify for Romanian language, from English to Romanian, in dconf for${reset}"
  echo -e "             ${blue}all new users and current user, add 'ro' keyboard and add additional packages for localized language.${reset}"
  echo -e "  ${blue}Option 4 - Modify for English language, from Romanian to English, in dconf for${reset}"
  echo -e "             ${blue}all new users, set 'us' default keyboard and 'ro' secondary keyboard.${reset}"
  echo -e "  ${blue}Option 5 - Enable Romanian language in libc-locales and install additional packages for localized language.${reset}"
  echo -e "  ${blue}Option 6 - Modify for English language, from Romanian to English, in dconf for${reset}"
  echo -e "             ${blue}current user, set 'us' default keyboard and 'ro' secondary keyboard.${reset}"
  echo -e "  ${blue}Option 7 - Modify for English language, from Romanian to English, in dconf for${reset}"
  echo -e "             ${blue}all new users and current user, set 'us' default keyboard and 'ro' secondary keyboard.${reset}"
  echo -e "  ${red}Option 8 - Exit from script.${reset}"
  echo -e "\n${bold}${cyan}Examples:${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 1${reset}\t\t${blue}# Option 1${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 2\t${reset}\t${blue}# Option 2${reset}"
  echo -e "  ${magenta}set_ro_RO_gnome.sh 2\t\t${reset}\t${blue}# Option 2, can be run by current user, but without to install the packages${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 1 2${reset}\t\t${blue}# Option 3${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 2 1${reset}\t\t${blue}# Option 3${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 3${reset}\t\t${blue}# Option 4${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 4\t${reset}\t${blue}# Option 6${reset}"
  echo -e "  ${magenta}set_ro_RO_gnome.sh 4\t\t${reset}\t${blue}# Option 6, can be run by current user${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 5\t${reset}\t${blue}# Option 5${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 3 4${reset}\t\t${blue}# Option 7${reset}"
  echo -e "  ${magenta}sudo set_ro_RO_gnome.sh 4 3${reset}\t\t${blue}# Option 7${reset}"
  echo -e "  ${yellow}sudo set_ro_RO_gnome.sh$\t\t# Use the menu to choose an option${reset}"
  echo -e "  set_ro_RO_gnome.sh --help or -h \t# This help."
  exit 0
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  display_help
fi

# Modify for Romanian language in central/system dconf (for all new user)
set_for_all_users_EN_RO() {
  # First make backup for dconf files 27-app-folders, 12-extensions-arcmenu and 01-input-sources in the root directory,
  # if not already exist
  printf "Make backup of dconf files '27-app-folders', '12-extensions-arcmenu', and '01-input-sources'
in the '/root/backup' directory, if they do not already exist.\n"
  if [ ! -d /root/backup ]; then # check if directory not exist, if not make directory backup on /root
    mkdir -p /root/backup
  fi
  if [ ! -f /root/backup/27-app-folders ]; then # check if the file not exist, if exist do nothing, else copy from system in /root/backup
    cp "$app_folders" /root/backup
  fi
  if [ ! -f /root/backup/12-extensions-arcmenu ]; then # check if the file not exist, if exist do nothing, else copy from system in /root/backup
    cp "$extensions_arcmenu" /root/backup
  fi
  if [ ! -f /root/backup/01-input-sources ]; then # check if the file not exist, if exist do nothing, else copy from system in /root/backup
    cp "$input_sources" /root/backup
  fi

  # Modify for Romanian language in central/system dconf (for new user)
  sed -i "s/name='Themes settings'/name='Setări teme'/g"  "$app_folders"
  sed -i "s/name='Office'/name='Birou'/g" "$app_folders"
  sed -i "s/name='Graphics'/name='Grafică'/g" "$app_folders"
  sed -i "s/name='Programming'/name='Programare'/g"  "$app_folders"
  sed -i "s/name='Accessories'/name='Accesorii'/g" "$app_folders"
  sed -i "s/name='Internet'/name='Internet'/g"  "$app_folders"
  sed -i "s/name='Multimedia'/name='Multimedia'/g" "$app_folders"
  sed -i "s/'name': 'Programming'/'name': 'Programare'/g"  "$extensions_arcmenu"
  sed -i "s/'name': 'System'/'name': 'Sistem'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Office'/'name': 'Birou'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Graphics'/'name': 'Grafică'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Accessories'/'name': 'Accesorii'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Themes settings'/'name': 'Setări teme'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Internet'/'name': 'Internet'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Multimedia'/'name': 'Multimedia'/g" "$extensions_arcmenu"
  sed -i "s/sources=\[('xkb', 'us')]\s*/sources=[('xkb', 'ro'), ('xkb', 'us')]/g" "$input_sources"
  sed -i "s/mru-sources=\[('xkb', 'us')]\s*/mru-sources=[('xkb', 'ro'), ('xkb', 'us')]/g" "$input_sources"

  # Update dconf database
  printf "Update dconf database\n"
  dconf update
}

# Modify for Romanian language in dconf (for actual user)
set_for_current_user_EN_RO() {
  if [ "$(id -u)" == "0" ]; then # check if is run by root
    # Generate dconf.ini file
    printf "Generate dconf.ini file\n"
    if [ ! -d /home/"$username"/backup ]; then # Check if directory not exist, if not exist make the directory backup
      sudo -u "$username" mkdir -p /home/"$username"/backup
    fi
    dconf_file="/home/$username/backup/dconf.ini"
    sudo -u "$username" dconf dump / >"$dconf_file"

    # Make backup for dconf.ini
    printf "Make backup of 'dconf.ini' into 'dconf.bak' file\n"
    sudo -u "$username" cp /home/"$username"/backup/dconf.ini /home/"$username"/backup/dconf.bak

    # Now modify in dconf.ini file groups programming name for Romanian language
    printf "Now modify the group names for app in dconf.ini file for Romanian language\n"
    sudo -u "$username" sed -i "s/name='Themes settings'/name='Setări teme'/g"  "$dconf_file"
    sudo -u "$username" sed -i "s/name='Office'/name='Birou'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Graphics'/name='Grafică'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Programming'/name='Programare'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Accessories'/name='Accesorii'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Internet'/name='Internet'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Multimedia'/name='Multimedia'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Programming'/'name': 'Programare'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'System'/'name': 'Sistem'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Office'/'name': 'Birou'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Graphics'/'name': 'Grafică'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Accessories'/'name': 'Accesorii'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Themes settings'/'name': 'Setări teme'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Internet'/'name': 'Internet'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Multimedia'/'name': 'Multimedia'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/sources=\[('xkb', 'us')]\s*/sources=[('xkb', 'ro'), ('xkb', 'us')]/g" "$dconf_file"
    sudo -u "$username" sed -i "s/mru-sources=\[('xkb', 'us')]\s*/mru-sources=[('xkb', 'ro'), ('xkb', 'us')]/g" "$dconf_file"

    # Load modified configs from dconf.ini file
    printf "Load modified configs from dconf.ini file\n\n"
    sudo -u "$username" bash -c "pid=\$(pgrep -u \$USER -n gnome-shell);
    addr=\$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/\$pid/environ | cut -d= -f2- | tr -d '\0');
    export DBUS_SESSION_BUS_ADDRESS=\$addr;
    dconf load / < \"$dconf_file\""

    # Change the language for current user to Romanian 
    if [ -f /var/lib/AccountsService/users/"$username" ]; then
      printf "Change the language, for current user, to Romanian at next Logon\n"
      if cat /var/lib/AccountsService/users/"$username" | grep -q "Languages=en_US.UTF-8;"; then # Check if already set the language to English
        sed -i "s/Languages=en_US.UTF-8;/Languages=ro_RO.UTF-8;/g" /var/lib/AccountsService/users/"$username" # If yes, change the line and set to Romanian language
      else
        sed -i "2i Languages=ro_RO.UTF-8;" /var/lib/AccountsService/users/"$username" # If not, add the line what set to Romanian language before to the second line 
      fi
      # Close the session (Logout)
      sudo -u "$username" bash -c "pid=\$(pgrep -u \$USER -n gnome-shell);
      addr=\$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/\$pid/environ | cut -d= -f2- | tr -d '\0');
      export DBUS_SESSION_BUS_ADDRESS=\$addr;
      gnome-session-quit"
    fi

  elif [ "$(id -u)" != "0" ]; then # check if is run by non admin user
    # Generate dconf.ini file
    printf "Generate dconf.ini file\n"
    if [ ! -d /home/"$username"/backup ]; then # Check if directory not exist, if not exist make the directory backup
      mkdir -p /home/"$username"/backup
    fi
    dconf_file="/home/$username/backup/dconf.ini"
    dconf dump / >"$dconf_file"

    # Make backup for dconf.ini
    printf "Make backup of 'dconf.ini' into 'dconf.bak' file\n"
    cp /home/"$username"/backup/dconf.ini /home/"$username"/backup/dconf.bak

    # Now modify in dconf.ini file groups programming name for Romanian language
    printf "Now modify the group names for app in dconf.ini file for Romanian language\n"
    sed -i "s/name='Themes settings'/name='Setări teme'/g"  "$dconf_file"
    sed -i "s/name='Office'/name='Birou'/g" "$dconf_file"
    sed -i "s/name='Graphics'/name='Grafică'/g" "$dconf_file"
    sed -i "s/name='Programming'/name='Programare'/g" "$dconf_file"
    sed -i "s/name='Accessories'/name='Accesorii'/g" "$dconf_file"
    sed -i "s/name='Internet'/name='Internet'/g" "$dconf_file"
    sed -i "s/name='Multimedia'/name='Multimedia'/g" "$dconf_file"
    sed -i "s/'name': 'Programming'/'name': 'Programare'/g" "$dconf_file"
    sed -i "s/'name': 'System'/'name': 'Sistem'/g" "$dconf_file"
    sed -i "s/'name': 'Office'/'name': 'Birou'/g" "$dconf_file"
    sed -i "s/'name': 'Graphics'/'name': 'Grafică'/g" "$dconf_file"
    sed -i "s/'name': 'Accessories'/'name': 'Accesorii'/g" "$dconf_file"
    sed -i "s/'name': 'Themes settings'/'name': 'Setări teme'/g" "$dconf_file"
    sed -i "s/'name': 'Internet'/'name': 'Internet'/g" "$dconf_file"
    sed -i "s/'name': 'Multimedia'/'name': 'Multimedia'/g" "$dconf_file"
    sed -i "s/sources=\[('xkb', 'us')]\s*/sources=[('xkb', 'ro'), ('xkb', 'us')]/g" "$dconf_file"
    sed -i "s/mru-sources=\[('xkb', 'us')]\s*/mru-sources=[('xkb', 'ro'), ('xkb', 'us')]/g" "$dconf_file"

    # Load modified configs from dconf.ini file
    printf "Load modified configs from dconf.ini file\n\n"
    dconf load / <"$dconf_file"
  fi
}

# Modify for English language for all new user
set_for_all_users_RO_EN() {
  # First make backup for dconf files 27-app-folders, 12-extensions-arcmenu and 01-input-sources in the root directory,
  # if not already exist
  printf "Make backup of dconf files '27-app-folders', '12-extensions-arcmenu', and '01-input-sources'
in the '/root/backup' directory, if they do not already exist.\n"
  if [ ! -d /root/backup ]; then # check if directory not exist, if not exist make directory the backup on /root
    mkdir -p /root/backup
  fi
  if [ ! -f /root/backup/27-app-folders ]; then # check if the file not exist, if exist do nothing, else copy from system in /root/backup
    cp "$app_folders" /root/backup
  fi
  if [ ! -f /root/backup/12-extensions-arcmenu ]; then # check if the file not exist, if exist do nothing, else copy from system in /root/backup
    cp "$extensions_arcmenu" /root/backup
  fi
  if [ ! -f /root/backup/01-input-sources ]; then # check if the file not exist, if exist do nothing, else copy from system in /root/backup
    cp "$input_sources" /root/backup
  fi

  # Modify for English language in dconf for all new users
  sed -i "s/name='Setări teme'/name='Themes settings'/g" "$app_folders"
  sed -i "s/name='Birou'/name='Office'/g" "$app_folders"
  sed -i "s/name='Grafică'/name='Graphics'/g" "$app_folders"
  sed -i "s/name='Programare'/name='Programming'/g" "$app_folders"
  sed -i "s/name='Accesorii'/name='Accessories'/g" "$app_folders"
  sed -i "s/name='Internet'/name='Internet'/g" "$app_folders"
  sed -i "s/name='Multimedia'/name='Internet'/g" "$app_folders"
  sed -i "s/'name': 'Programare'/'name': 'Programming'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Sistem'/'name': 'System'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Birou'/'name': 'Office'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Grafică'/'name': 'Graphics'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Accesorii'/'name': 'Accessories'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Setări teme'/'name': 'Themes settings'/g"  "$extensions_arcmenu"
  sed -i "s/'name': 'Internet'/'name': 'Internet'/g" "$extensions_arcmenu"
  sed -i "s/'name': 'Multimedia'/'name': 'Multimedia'/g"  "$extensions_arcmenu"
  sed -i "s/sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/sources=[('xkb', 'us')]/g"  "$input_sources"
  sed -i "s/mru-sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/mru-sources=[('xkb', 'us')]/g" "$input_sources"

  # Update dconf database
  printf "Update dconf database\n"
  dconf update
}

# Modify for English language in dconf (for actual user)
set_for_current_user_RO_EN() {
  if [ "$(id -u)" == "0" ]; then # check if is run by root
    # Generate dconf.ini file
    printf "Generate dconf.ini file\n"
    if [ ! -d /home/"$username"/backup ]; then # Check if directory not exist, if not exist make the directory backup
      sudo -u "$username" mkdir -p /home/"$username"/backup
    fi
    dconf_file="/home/$username/backup/dconf.ini"
    sudo -u "$username" dconf dump / >"$dconf_file"

    # Make backup for dconf.ini
    printf "Make backup of 'dconf.ini' into 'dconf.bak' file\n"
    sudo -u "$username" cp /home/"$username"/backup/dconf.ini /home/"$username"/backup/dconf.bak

    # Now modify in dconf.ini file groups programming name for English language
    printf "Now modify the group names for app in dconf.ini file for English language\n"
    sudo -u "$username" sed -i "s/name='Setări teme'/name='Themes settings'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Birou'/name='Office'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Grafică'/name='Graphics'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Programare'/name='Programming'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Accesorii'/name='Accessories'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Internet'/name='Internet'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/name='Multimedia'/name='Multimedia'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Programare'/'name': 'Programming'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Sistem'/'name': 'System'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Birou'/'name': 'Office'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Grafică'/'name': 'Graphics'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Accesorii'/'name': 'Accessories'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Setări teme'/'name': 'Themes settings'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Internet'/'name': 'Internet'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/'name': 'Multimedia'/'name': 'Multimedia'/g" "$dconf_file"
    sudo -u "$username" sed -i "s/sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/sources=[('xkb', 'us')]/g" "$dconf_file"
    sudo -u "$username" sed -i "s/mru-sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/mru-sources=[('xkb', 'us')]/g" "$dconf_file"
    # Load modified configs from dconf.ini file
    printf "Load modified configs from dconf.ini file\n\n"
    sudo -u "$username" bash -c "pid=\$(pgrep -u \$USER -n gnome-shell);
    addr=\$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/\$pid/environ | cut -d= -f2- | tr -d '\0');
    export DBUS_SESSION_BUS_ADDRESS=\$addr;
    dconf load / < \"$dconf_file\""

    # Change the language for current user to English 
    if [ -f /var/lib/AccountsService/users/"$username" ]; then
      printf "Change the language, for current user, to English at next Logon\n"
      if cat /var/lib/AccountsService/users/"$username" | grep -q "Languages=ro_RO.UTF-8;"; then # Check if already set the language to Romanian
        sed -i "s/Languages=ro_RO.UTF-8;/Languages=en_US.UTF-8;/g" /var/lib/AccountsService/users/"$username" # If yes, change the line and set to English language
      else
        sed -i "2i Languages=en_US.UTF-8;" /var/lib/AccountsService/users/"$username" # If not, add the line what set to English language before to the second line
      fi
      # Close the session (Logout)
      sudo -u "$username" bash -c "pid=\$(pgrep -u \$USER -n gnome-shell);
      addr=\$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/\$pid/environ | cut -d= -f2- | tr -d '\0');
      export DBUS_SESSION_BUS_ADDRESS=\$addr;
      gnome-session-quit"
    fi

  elif [ "$(id -u)" != "0" ]; then # check if is run by non admin user
    # Generate dconf.ini file
    printf "Generate dconf.ini file\n"
    if [ ! -d /home/"$username"/backup ]; then # Check if directory not exist, if not exist make the directory backup
      mkdir -p /home/"$username"/backup
    fi
    dconf_file="/home/$username/backup/dconf.ini"
    dconf dump / >"$dconf_file"

    # Make backup for dconf.ini
    printf "Make backup of 'dconf.ini' into 'dconf.bak' file\n"
    sudo -u "$username" cp /home/"$username"/backup/dconf.ini /home/"$username"/backup/dconf.bak

    # Now modify in dconf.ini file groups programming name for English language
    printf "Now modify the group names for app in dconf.ini file for English language\n"
    sed -i "s/name='Setări teme'/name='Themes settings'/g" "$dconf_file"
    sed -i "s/name='Birou'/name='Office'/g" "$dconf_file"
    sed -i "s/name='Grafică'/name='Graphics'/g" "$dconf_file"
    sed -i "s/name='Programare'/name='Programming'/g" "$dconf_file"
    sed -i "s/name='Accesorii'/name='Accessories'/g" "$dconf_file"
    sed -i "s/name='Internet'/name='Internet'/g" "$dconf_file"
    sed -i "s/name='Multimedia'/name='Multimedia'/g" "$dconf_file"
    sed -i "s/'name': 'Programare'/'name': 'Programming'/g" "$dconf_file"
    sed -i "s/'name': 'Sistem'/'name': 'System'/g" "$dconf_file"
    sed -i "s/'name': 'Birou'/'name': 'Office'/g" "$dconf_file"
    sed -i "s/'name': 'Grafică'/'name': 'Graphics'/g" "$dconf_file"
    sed -i "s/'name': 'Accesorii'/'name': 'Accessories'/g" "$dconf_file"
    sed -i "s/'name': 'Setări teme'/'name': 'Themes settings'/g" "$dconf_file"
    sed -i "s/'name': 'Internet'/'name': 'Internet'/g" "$dconf_file"
    sed -i "s/'name': 'Multimedia'/'name': 'Multimedia'/g" "$dconf_file"
    sed -i "s/sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/sources=[('xkb', 'us')]/g" "$dconf_file"
    sed -i "s/mru-sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/mru-sources=[('xkb', 'us')]/g" "$dconf_file"

    # Load modified configs from dconf.ini file
    printf "Load modified configs from dconf.ini file\n\n"
    dconf load / <"$dconf_file"
  fi
}

set_localize_packages() {
  # Add other packages for Romanian language
  printf "Install other packages for Romanian language\n\n"
  xbps-install -Sy firefox-i18n-ro libreoffice-i18n-ro mythes-ro hyphen-ro manpages-ro hunspell-ro_RO
}

# Modify to Romanian language the system
set_system_language_EN_RO() {
  printf "Set system language for Romanian language\n\n"
  sed -i "s/#ro_RO.UTF-8 UTF-8/ro_RO.UTF-8 UTF-8/g" /etc/default/libc-locales
  sed -i "s/LANG=en_US.UTF-8/LANG=ro_RO.UTF-8/g" /etc/locale.conf
  sed -i "s/KEYMAP=us/KEYMAP=ro/g" /etc/rc.conf
  LANG=ro_RO.UTF-8
  xbps-reconfigure --force glibc-locales
  update-grub # for loading message in Romanian language
}

# Modify to English language the system
set_system_language_RO_EN() {
  printf "Set system language for English language\n\n"
  # I not change back to '#ro_RO.UTF-8 UTF-8' in '/etc/default/libc-locales',
  # because can exist in system over users what use Romanian language
  sed -i "s/LANG=ro_RO.UTF-8/LANG=en_US.UTF-8/g" /etc/locale.conf
  sed -i "s/KEYMAP=ro/KEYMAP=us/g" /etc/rc.conf
  LANG=en_US.UTF-8
  xbps-reconfigure --force glibc-locales
  update-grub # for loading message in English language
}

# Add Romanian language in the system
add_system_language_ro_RO() {
  printf "Add Romanian language in the system (glibc)\n\n"
  sed -i "s/#ro_RO.UTF-8 UTF-8/ro_RO.UTF-8 UTF-8/g" /etc/default/libc-locales
  xbps-reconfigure --force glibc-locales
}

# Final messages 1
final_message_1() {
  printf "\n\n%s%sFinish and thanks for usage%s\n\n
%sRead carefully:%s
%sIf is not OK, you have a backup files for '27-app-folders', '12-extensions-arcmenu' , and '01-input-sources' in the '/root/backup' directory.
These files can be put back in then '/etc/dconf/db/local.d/' directory, and then run 'sudo dconf update', but only if the patch is not applied correctly in your case.
It is a good idea to archive these files or/and to put it in another safe place.%s\n" \
    "$bold" "$cyan" "$reset" "$red" "$reset" "$green" "$reset"
}

# Final messages 2
final_message_2() {
  printf "\n\n%s%sFinish and thanks for usage%s\n\n
%sRead carefully:%s
%sIf is not OK, the old configs can be loaded using 'dconf load / < /home/%s/backup/dconf.bak', but only if the patch is not applied correctly in your case.
It is a good idea to archive 'dconf.bak' or to put it in another safe place, because if you run once again this script, the file is overwritten.%s\n" \
    "$bold" "$cyan" "$reset" "$red" "$reset" "$green" "$username" "$reset"
}

# Final messages 3
final_message_3() {
  printf "\n\n%s%sFinish and thanks for usage%s\n\n
%sRead carefully:%s
%sIf is not OK, the old configs can be loaded using 'dconf load / < /home/%s/backup/dconf.bak'.
Also, you have a backup files for '27-app-folders', '12-extensions-arcmenu' , and '01-input-sources' in the '/root/backup' directory.
These files can be put back in then '/etc/dconf/db/local.d/' directory, and then run 'sudo dconf update', but only if the patch is not applied correctly in your case.
It is a good idea to archive 'dconf.bak' or to put it in another safe place, because if you run once again this script, the file is overwritten.
Also, is a good idea to archive the files from '/root/backup' or/and to put it in another safe place.%s\n" \
    "$bold" "$cyan" "$reset" "$red" "$reset" "$green" "$username" "$reset"
}

# Final messages 4
final_message_4() {
  printf "\n\n%s%sFinish and thanks for usage%s\n\n
%sRead carefully:%s
%sIf is not OK, you have a backup files for '27-app-folders', '12-extensions-arcmenu' , and '01-input-sources' in the '/root/backup' directory.
These files can be put back in then '/etc/dconf/db/local.d/' directory, and then run 'sudo dconf update', but only if the patch is not applied correctly in your case.
It is a good idea to archive these files or/and to put it in another safe place.%s\n" \
    "$bold" "$cyan" "$reset" "$red" "$reset" "$green" "$reset"
}

# Final messages 5
final_message_5() {
  printf "\n\n%s%sFinish and thanks for usage%s\n\n
%sRead carefully:%s
%sIf is not OK, the old configs can be loaded using 'dconf load / < /home/%s/backup/dconf.bak', but only if the patch is not applied correctly in your case.
It is a good idea to archive 'dconf.bak' or to put it in another safe place, because if you run once again this script, the file is overwritten.%s\n" \
    "$bold" "$cyan" "$reset" "$red" "$reset" "$green" "$username" "$reset"
}

# Final messages 6
final_message_6() {
  printf "\n\n%s%sFinish and thanks for usage%s\n\n
%sRead carefully:%s
%sIf is not OK, the old configs can be loaded using 'dconf load / < /home/%s/backup/dconf.bak'.
Also, you have a backup files for '27-app-folders', '12-extensions-arcmenu' , and '01-input-sources' in the '/root/backup' directory.
These files can be put back in then '/etc/dconf/db/local.d/' directory, and then run 'sudo dconf update', but only if the patch is not applied correctly in your case.
It is a good idea to archive 'dconf.bak' or to put it in another safe place, because if you run once again this script, the file is overwritten.
Also, is a good idea to archive the files from '/root/backup' or/and to put it in another safe place.%s\n" \
    "$bold" "$cyan" "$reset" "$red" "$reset" "$green" "$username" "$reset"
}

# Check if was sent a parameter
if [ $# -eq 0 ]; then
  echo "${blue}Please select an option from menu:${reset}"

  select opt in "EN->RO for the all new users" "EN->RO for the current user" \
    "EN->RO for all new users and the current user" "Add ro_RO in libc-locales and install additional packages" \
    "RO->EN for the all new users" "RO->EN for the current user" "RO->EN for all new users and the current user" \
    "Exit"; do
    case $opt in
    "EN->RO for the all new users")
      echo "${blue}You choose - Modify for Romanian language in dconf for all new users.${reset}"
      set_for_all_users_EN_RO
      set_localize_packages
      set_system_language_EN_RO
      final_message_1
      break
      ;;
    "EN->RO for the current user")
      echo "${blue}You choose - Modify for Romanian language in dconf for the current user.${reset}"
      set_for_current_user_EN_RO
      set_localize_packages
      final_message_2
      break
      ;;
    "EN->RO for all new users and the current user")
      echo "${blue}You choose - Modify for Romanian language in dconf for all new users and the current user.${reset}"
      set_for_all_users_EN_RO
      set_for_current_user_EN_RO
      set_localize_packages
      set_system_language_EN_RO
      final_message_3
      break
      ;;
    "Add ro_RO in libc-locales and install additional packages")
      echo "${blue}You choose - Enable Romanian language in libc-locales and install additional packages for localized language.${reset}"
      add_system_language_ro_RO
      set_localize_packages
      break
      ;;
    "RO->EN for the all new users")
      echo "${blue}You choose - Modify for English language in dconf for all new users.${reset}"
      set_for_all_users_RO_EN
      # localized packages remain because can exist another user what need these
      set_system_language_RO_EN
      final_message_4
      break
      ;;
    "RO->EN for the current user")
      echo "${blue}You choose - Modify for English language in dconf for the current user.${reset}"
      set_for_current_user_RO_EN
      # localized packages remain because can exist another user what need these
      final_message_5
      break
      ;;
    "RO->EN for all new users and the current user")
      echo "${blue}You choose - Modify for English language in dconf for all new users and the current user.${reset}"
      set_for_all_users_RO_EN
      set_for_current_user_RO_EN
      # localized packages remain because can exist another user what need these
      set_system_language_RO_EN
      final_message_6
      break
      ;;
    "Exit")
      echo "Exit from menu."
      break
      ;;
    *)
      echo "${red}Invalid option, please try once again.${reset}"
      ;;
    esac
  done
else
  # If a parameter was send is executed directly
  if [[ "$1" == "1" && "$2" == "2" ]] || [[ "$1" == "2" && "$2" == "1" ]]; then
    echo "${blue}You choose - Modify for Romanian language in dconf for all new users and the current user.${reset}"
    set_for_all_users_EN_RO
    set_for_current_user_EN_RO
    set_localize_packages
    set_system_language_EN_RO
  elif [ "$1" == "1" ]; then
    echo "${blue}You choose - Modify for Romanian language in dconf for all new users.${reset}"
    set_for_all_users_EN_RO
    set_localize_packages
    set_system_language_EN_RO
  elif [ "$1" == "2" ]; then
    echo "${blue}You choose - Modify for Romanian language in dconf for the current user.${reset}"
    set_for_current_user_EN_RO
    if [ "$(id -u)" == "0" ]; then # check if is run by root
      set_localize_packages
    else
      echo "${red}You run without 'root' rights, so you can't install the packages${reset}"
    fi
  elif [[ "$1" == "3" && "$2" == "4" ]] || [[ "$1" == "4" && "$2" == "3" ]]; then
    echo "${blue}You choose - Modify for English language in dconf for all new users and the current user.${reset}"
    set_for_all_users_RO_EN
    set_for_current_user_RO_EN
    # localized packages remain because can exist another user what need these
    set_system_language_RO_EN
  elif [ "$1" == "3" ]; then
    echo "${blue}You choose - Modify for English language in dconf for all new users.${reset}"
    set_for_all_users_RO_EN
    # localized packages remain because can exist another user what need these
    set_system_language_RO_EN
  elif [ "$1" == "4" ]; then
    echo "${blue}You choose - Modify for English language in dconf for the current user.${reset}"
    set_for_current_user_RO_EN
    # localized packages remain because can exist other users what need these
  elif [ "$1" == "5" ]; then
    echo "${blue}You choose - Enable Romanian language in libc-locales and install additional packages for localized language.${reset}"
    add_system_language_ro_RO
    set_localize_packages
  else
    echo -e "${red}Invalid parameter. Please use for parameters numbers:\n
    '1' to Modify for Romanian language in system dconf, for all new users;
    '2' to Modify for Romanian language in dconf, for the current user;
    '1' '2' or '2' '1' to Modify for Romanian language in system dconf, for all new users and for current user;\n
    '3' to Modify for English language in system dconf, for all new users;
    '4' to Modify for English language in dconf, for the current user;
    '3' '4' or '2' '1' to Modify for English language in system dconf, for all new users and for current user;\n
    Run './set_ro_RO_gnome.sh --help or -h for more help.'${reset}"
  fi
fi
