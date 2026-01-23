#!/bin/bash

# Function to get the current language
get_language() {
    gdbus call --system \
  --dest org.freedesktop.Accounts \
  --object-path /org/freedesktop/Accounts/User$(id -u) \
  --method org.freedesktop.DBus.Properties.Get \
  org.freedesktop.Accounts.User Language | awk -F "'" '{print $2}'
}

# Print the current language
CURRENT_LANGUAGE=$(get_language)
echo "Current Language: $CURRENT_LANGUAGE"

# Function to handle the language change
on_language_change() {
    local new_language="$1"
    #echo "Language changed to: $new_language"
    case "$CURRENT_LANGUAGE" in
        de_DE.UTF-8|es_ES.UTF-8|fr_FR.UTF-8|it_IT.UTF-8|pt_BR.UTF-8|pt_PT.UTF-8|ro_RO.UTF-8|ru_RU.UTF-8|zh_TE.UTF-8) set_"$CURRENT_LANGUAGE"_gnome.sh 4;;
    esac
    case "$new_language" in
        de_DE.UTF-8|es_ES.UTF-8|fr_FR.UTF-8|it_IT.UTF-8|pt_BR.UTF-8|pt_PT.UTF-8|ro_RO.UTF-8|ru_RU.UTF-8|zh_TE.UTF-8) set_"$new_language"_gnome.sh 2;;
        en_US.UTF-8) set_"$CURRENT_LANGUAGE"_gnome.sh 4;;
    esac
    CURRENT_LANGUAGE=$new_language
    #echo "New current language is $CURRENT_LANGUAGE"
}

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
