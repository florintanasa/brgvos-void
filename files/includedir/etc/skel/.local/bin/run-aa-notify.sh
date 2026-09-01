#!/bin/bash
# Define some local variables
local _group
_group="audit"

# Check if the user is part from _group
if id | grep -q "$_group"; then
    aa-notify -p -s -1 -w 60 -f /var/log/audit/audit.log
else
    zenity --warning \
    --text="You are not in audit group. Add <i>$USER</i> to audit group\n\n \
<b>sudo gpasswd -a $USER audit</b>\n\n \
or set <b>X-GNOME-Autostart-enabled=false</b>\n \
in $HOME/.config/autostart/apparmor-notify.desktop,\n \
to disable this message" \
    --width 450 --height 150
fi
