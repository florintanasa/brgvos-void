#!/bin/bash

# Function to get the current language
get_language() {
    gdbus call --system \
  --dest org.freedesktop.Accounts \
  --object-path /org/freedesktop/Accounts/User$(id -u) \
  --method org.freedesktop.DBus.Properties.Get \
  org.freedesktop.Accounts.User Language | awk -F "'" '{print $2}'
}

# Function to handle the language change
on_language_change() {
    local new_language="$1"
    echo "Language changed to: $new_language"
    case "$CURRENT_LANGUAGE" in
        de_DE.UTF-8|es_ES.UTF-8|fr_FR.UTF-8|it_IT.UTF-8|pt_BR.UTF-8|pt_PT.UTF-8|ro_RO.UTF-8|ru_RU.UTF-8|zh_TW.UTF-8) set_"$CURRENT_LANGUAGE"_gnome.sh 4;;
    esac
    case "$new_language" in
        de_DE.UTF-8|es_ES.UTF-8|fr_FR.UTF-8|it_IT.UTF-8|pt_BR.UTF-8|pt_PT.UTF-8|ro_RO.UTF-8|ru_RU.UTF-8|zh_TW.UTF-8) set_"$new_language"_gnome.sh 2;;
        en_US.UTF-8) set_"$CURRENT_LANGUAGE"_gnome.sh 4;;
    esac
    CURRENT_LANGUAGE=$new_language
    echo "New current language is $CURRENT_LANGUAGE"
}

# Get the current language, at first login from locale and then using D-Bus call
# using Accounts service for the user.
if [ ! -e $HOME/.set_locale_gnome ]
    then
        CURRENT_LANGUAGE=$(locale | grep LANG | awk -F "=" '{print $2}')
        echo "Current Language (using locale): $CURRENT_LANGUAGE"
        # If the user have English current language so also the system is in English,
        # I set also in Gnome English language because the language was not set for the Gnome
        if [ "$CURRENT_LANGUAGE" == "en_US.UTF-8" ]; then
            gdbus call --system \
            --dest org.freedesktop.Accounts \
            --object-path /org/freedesktop/Accounts/User$(id -u) \
            --method org.freedesktop.Accounts.User.SetLanguage "en_US.UTF-8"
        else
            # Call funtion with parameter to be sure the language is set for the user,
            # in case was not set when the user was created,
            # in this case the language in Gnome is set with system language.
            gdbus call --system \
            --dest org.freedesktop.Accounts \
            --object-path /org/freedesktop/Accounts/User$(id -u) \
            --method org.freedesktop.Accounts.User.SetLanguage "$CURRENT_LANGUAGE" 
            on_language_change "$CURRENT_LANGUAGE"
        fi
        # Create the file .set_locale_gnome
        touch $HOME/.set_locale_gnome
        # Write the message in file .set_locale_gnome
        cat << 'EOF' > $HOME/.set_locale_gnome
        ############################################################
        ###                                                      ###
        ### This file was created by next script:                ###
        ### %HOME/.local/bin/language_change_monitor.sh          ###
        ### and is created only once at first login in Gnome.    ###
        ### If you delete this file is created again.            ###
        ###                                                      ###
        ############################################################

EOF
    else
        CURRENT_LANGUAGE=$(get_language)
        echo "Current Language (using D-BUS): $CURRENT_LANGUAGE"

fi

# Listen for changes in user language
gdbus monitor -y -d org.freedesktop.Accounts -o "/org/freedesktop/Accounts/User$(id -u)" |
while IFS= read -r line; do
    if [[ "$line" =~ "PropertiesChanged" ]] && [[ "$line" =~ "Language" ]]; then
        # Extracting the new language value
        new_lang=$(echo "$line" | grep -oP "(?<=Language': <')[^']+" )
        # Call funtion with parameter
         on_language_change "$new_lang"
    fi
done
