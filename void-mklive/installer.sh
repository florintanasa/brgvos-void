#!/bin/bash
#-
# Copyright (c) 2012-2015 Juan Romero Pardines <xtraeme@gmail.com>.
#               2012 Dave Elusive <davehome@redthumb.info.tm>.
#               2025-2026 Florin Tanasă <florin.tanasa@gmail.com>
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
#-

# Set the color for dialog interface
dialogRcFile="$HOME/.dialogrc"

# Function to create file .dialogrc
sh_create_dialogrc() {
  cat > "$dialogRcFile" <<-EOF
# Set aspect-ration.
aspect = 0

# Set separator (for multiple widgets output).
separate_widget = ""

# Set tab-length (for textbox tab-conversion).
tab_len = 0

# Make tab-traversal for checklist, etc., include the list.
visit_items = OFF

# Show scrollbar in dialog boxes?
use_scrollbar = OFF

# Shadow dialog boxes? This also turns on color.
use_shadow = OFF

# Turn color support ON or OFF
use_colors = ON

# Screen color
screen_color = (CYAN,BLACK,ON)

# Shadow color
shadow_color = (RED,RED,ON)

# Dialog box color
dialog_color = (CYAN,BLACK,ON)

# Dialog box title color
title_color = (WHITE,BLACK,ON)

# Dialog box border color
border_color = screen_color

# Active button color
button_active_color = (BLACK,CYAN,OFF)

# Inactive button color
button_inactive_color = screen_color

# Active button key color
button_key_active_color = button_active_color

# Inactive button key color
button_key_inactive_color = (CYAN,BLACK,ON)

# Active button label color
button_label_active_color = (BLACK,CYAN,OFF)

# Inactive button label color
button_label_inactive_color = (WHITE,BLACK,ON)

# Input box color
inputbox_color = screen_color

# Input box border color
inputbox_border_color = screen_color

# Search box color
searchbox_color = screen_color

# Search box title color
searchbox_title_color = (WHITE,BLACK,OFF)

# Search box border color
searchbox_border_color = border_color

# File position indicator color
position_indicator_color = (WHITE,BLACK,OFF)

# Menu box color
menubox_color = screen_color

# Menu box border color
menubox_border_color = screen_color

# Item color
item_color = screen_color

# Selected item color
item_selected_color = (BLACK,CYAN,OFF)

# Tag color
tag_color = (WHITE,BLACK,OFF)

# Selected tag color
tag_selected_color = button_label_active_color

# Tag key color
tag_key_color = button_key_inactive_color

# Selected tag key color
tag_key_selected_color = (WHITE,CYAN,ON)

# Check box color
check_color = screen_color

# Selected check box color
check_selected_color = button_active_color

# Up arrow color
uarrow_color = (YELLOW,BLACK,ON)

# Down arrow color
darrow_color = uarrow_color

# Item help-text color
itemhelp_color = (WHITE,BLACK,OFF)

# Active form text color
form_active_text_color = button_active_color

# Form text color
form_text_color = (WHITE,CYAN,ON)

# Readonly form item color
form_item_readonly_color = (CYAN,WHITE,ON)

# Dialog box gauge color
gauge_color = (WHITE,BLACK,OFF)

# Dialog box border2 color
border2_color = screen_color

# Input box border2 color
inputbox_border2_color = screen_color

# Search box border2 color
searchbox_border2_color = screen_color

# Menu box border2 color
menubox_border2_color = screen_color
EOF
}

# Next function remove file .dialogrc
cleanup() {
  rm -f "$dialogRcFile"
}

# Check if file .dialogrc not exist. If is true create call function to create the .dialogrc file
if [[ ! -e "$dialogRcFile" ]]; then
  sh_create_dialogrc
fi

# Make sure we don't inherit these from env.
SOURCE_DONE=
HOSTNAME_DONE=
KEYBOARD_DONE=
LOCALE_DONE=
TIMEZONE_DONE=
ROOTPASSWORD_DONE=
USERLOGIN_DONE=
USERPASSWORD_DONE=
USERNAME_DONE=
USERGROUPS_DONE=
USERACCOUNT_DONE=
HARDENING_DONE=
BOOTLOADER_DONE=
PARTITIONS_DONE=
RAID_DONE=
LVMLUKS_DONE=
NETWORK_DONE=
FILESYSTEMS_DONE=
MIRROR_DONE=
AUDIT_FILE=""
SYSCTL_FILE=""

# set the date and time
date_time=$(date +'%d%m%Y_%H%M%S')

# Set directory where is mount new partition for rootfs
TARGETDIR=/mnt/target

# Set the name file for logs saving
#LOG=/dev/tty9
LOG="/tmp/install_brgvos_$date_time.log"

# Create saving file for logs
touch -f "$LOG"

# Set the name for config file using by installer
CONF_FILE=/tmp/.brgvos-installer.conf

# Check if exist the file is not create the file
if [ ! -f "$CONF_FILE" ]; then
  touch -f "$CONF_FILE"
fi

# Set variables with the temporal files used by installer
ANSWER=$(mktemp -t vinstall-XXXXXXXX || exit 1)
TARGET_SERVICES=$(mktemp -t vinstall-sv-XXXXXXXX || exit 1)
TARGET_FSTAB=$(mktemp -t vinstall-fstab-XXXXXXXX || exit 1)

# Exit clean from script brgvos-installer.sh
# Call function "DIE" when installer.sn catch INT (Ctrl+C) TERM (terminate request) or QUIT (Ctrl+\)
trap "DIE" INT TERM QUIT

# disable printk
if [ -w /proc/sys/kernel/printk ]; then
  echo 0 >/proc/sys/kernel/printk
fi

# Detect if this is an EFI system.
if [ -e /sys/firmware/efi/systab ]; then
  EFI_SYSTEM=1
  EFI_FW_BITS=$(cat /sys/firmware/efi/fw_platform_size)
  if [ "$EFI_FW_BITS" -eq 32 ]; then
    EFI_TARGET=i386-efi
  else
    EFI_TARGET=x86_64-efi
  fi
fi

# For message with echo or printf in bash
bold=$(tput bold) # Start bold text
underline=$(tput smul) # Start underlined text
reset=$(tput sgr0) # Turn off all attributes
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)


# Dialog colors
BLACK="\Z0"
RED="\Z1"
GREEN="\Z2"
YELLOW="\Z3"
BLUE="\Z4"
MAGENTA="\Z5"
CYAN="\Z6"
WHITE="\Z7"
BOLD="\Zb"
REVERSE="\Zr"
UNDERLINE="\Zu"
RESET="\Zn"

# Function to display help for usage
display_help() {
  echo -e "${bold}${cyan}Usage:${reset}"
  echo -e " brgvos-installer [ARGUMENT]"
  echo -e "\nDescription:"
  echo -e " Installer for BRGV-OS"
  echo -e "\nOptions:"
  echo -e "  ARGUMENT: -a /file/path/yourfileconfig.rules # to load you prepared file with config audit rules\n
           -s /file/path/yourfileconfig.conf # to load you prepared file with config sysctl config\n
           Check examples files from /usr/local/share for the form accepted"
  echo -e "\nEXAMPLES:"
  echo -e " brgvos-installer # without any argument is used defaults config rules for audit and config sysyctl"
  echo -e " brgvos-installer -a /usr/local/share/rules.d/99-myconfig-installer.rules"
  echo -e " brgvos-installer -s /usr/local/share/sysctl.d/99-desktop-installer.conf"
  echo -e " brgvos-installer -a /usr/local/share/rules.d/99-myconfig-installer.rules -s /usr/local/share/sysctl.d/99-desktop-installer.conf"
  exit 0
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  display_help
fi

# Parse args: -a audit-file, -s sysctl-file
while getopts "a:s:" opt; do
  case "$opt" in
  a) AUDIT_FILE=$OPTARG ;;
  s) SYSCTL_FILE=$OPTARG ;;
  *) ;;
  esac
done

# Properties shared per widget.
MENULABEL="${BOLD}Use UP and DOWN keys to navigate \
menus. Use TAB to switch between buttons and ENTER to select.${RESET}"
MENUSIZE="14 70 0"
INPUTSIZE="8 70"
MSGBOXSIZE="8 80"
YESNOSIZE="$INPUTSIZE"
WIDGET_SIZE="10 70"

DIALOG() {
  rm -f $ANSWER
  dialog --colors --keep-tite --no-shadow --no-mouse \
    --backtitle "${BOLD}${WHITE}BRGV-OS Linux installation -- https://github.com/florintanasa/brgvos-void (@@MKLIVE_VERSION@@)${RESET}" \
    --cancel-label "Back" --aspect 20 "$@" 2>$ANSWER
  return $?
}

INFOBOX() {
  # Note: dialog --infobox and --keep-tite don't work together
  dialog --colors --no-shadow --no-mouse \
    --backtitle "${BOLD}${WHITE}BRGV-OS Linux installation -- https://github.com/florintanasa/brgvos-void (@@MKLIVE_VERSION@@)${RESET}" \
    --title "${TITLE}" --aspect 20 --infobox "$@"
}

GAUGE() {
  # Note: dialog --infobox and --keep-tite don't work together
  dialog --colors --no-shadow --no-mouse \
    --backtitle "${BOLD}${WHITE}BRGV-OS Linux installation -- https://github.com/florintanasa/brgvos-void (@@MKLIVE_VERSION@@)${RESET}" \
    --title "${TITLE}" --aspect 20 --gauge "$@"
}

# Function used for clean exit from script
DIE() {
  # Define some variable local
  local rval
  rval=$1
  [ -z "$rval" ] && rval=0
  clear
  set_option INDEX "" # clear INDEX value
  set_option DEVCRYPT "" # clear DEVCRYPT value
  set_option CRYPTS "" # clear CRYPTS value
  set_option BOOTLOADER "" # clear BOOTLOADER value
  set_option TEXTCONSOLE "" # clear TEXTCONSOLE value
  set_option RAID "" # clear RAID value
  set_option RAIDPV "" # clear RAIDPV value
  set_option INDEXRAID "" # clear INDEXRAID value
  set_option APPARMOR "" # clear APPARMOR value
  set_option HARDENING "" # clear HARDENING value
  set_option AUDIT "" # clear AUDIT value
  set_option FIREWALL "" # clear FIREWALL value
  rm -f "$ANSWER" "$TARGET_FSTAB" "$TARGET_SERVICES"
  # re-enable printk
  if [ -w /proc/sys/kernel/printk ]; then
    echo 4 >/proc/sys/kernel/printk
  fi
  umount_filesystems
  cleanup
  exit "$rval"
}

# Function used to save chosen options in configure file
set_option() {
  if grep -Eq "^${1} .*" "$CONF_FILE"; then
    sed -i -e "/^${1} .*/d" "$CONF_FILE"
  fi
  echo "${1} ${2}" >>"$CONF_FILE"
}

# Function used to load saved chosen options from configure file
get_option() {
  grep -E "^${1} .*" "$CONF_FILE" | sed -e "s|^${1} ||"
}

# ISO-639 language names for locales
iso639_language() {
  case "$1" in
  aa)  echo "Afar" ;;
  af)  echo "Afrikaans" ;;
  an)  echo "Aragonese" ;;
  ar)  echo "Arabic" ;;
  ast) echo "Asturian" ;;
  be)  echo "Belgian" ;;
  bg)  echo "Bulgarian" ;;
  bhb) echo "Bhili" ;;
  br)  echo "Breton" ;;
  bs)  echo "Bosnian" ;;
  ca)  echo "Catalan" ;;
  cs)  echo "Czech" ;;
  cy)  echo "Welsh" ;;
  da)  echo "Danish" ;;
  de)  echo "German" ;;
  el)  echo "Greek" ;;
  en)  echo "English" ;;
  es)  echo "Spanish" ;;
  et)  echo "Estonian" ;;
  eu)  echo "Basque" ;;
  fi)  echo "Finnish" ;;
  fo)  echo "Faroese" ;;
  fr)  echo "French" ;;
  ga)  echo "Irish" ;;
  gd)  echo "Scottish Gaelic" ;;
  gl)  echo "Galician" ;;
  gv)  echo "Manx" ;;
  he)  echo "Hebrew" ;;
  hr)  echo "Croatian" ;;
  hsb) echo "Upper Sorbian" ;;
  hu)  echo "Hungarian" ;;
  id)  echo "Indonesian" ;;
  is)  echo "Icelandic" ;;
  it)  echo "Italian" ;;
  iw)  echo "Hebrew" ;;
  ja)  echo "Japanese" ;;
  ka)  echo "Georgian" ;;
  kk)  echo "Kazakh" ;;
  kl)  echo "Kalaallisut" ;;
  ko)  echo "Korean" ;;
  ku)  echo "Kurdish" ;;
  kw)  echo "Cornish" ;;
  lg)  echo "Ganda" ;;
  lt)  echo "Lithuanian" ;;
  lv)  echo "Latvian" ;;
  mg)  echo "Malagasy" ;;
  mi)  echo "Maori" ;;
  mk)  echo "Macedonian" ;;
  ms)  echo "Malay" ;;
  mt)  echo "Maltese" ;;
  nb)  echo "Norwegian Bokmål" ;;
  nl)  echo "Dutch" ;;
  nn)  echo "Norwegian Nynorsk" ;;
  oc)  echo "Occitan" ;;
  om)  echo "Oromo" ;;
  pl)  echo "Polish" ;;
  pt)  echo "Portuguese" ;;
  ro)  echo "Romanian" ;;
  ru)  echo "Russian" ;;
  sk)  echo "Slovak" ;;
  sl)  echo "Slovenian" ;;
  so)  echo "Somali" ;;
  sq)  echo "Albanian" ;;
  st)  echo "Southern Sotho" ;;
  sv)  echo "Swedish" ;;
  tcy) echo "Tulu" ;;
  tg)  echo "Tajik" ;;
  th)  echo "Thai" ;;
  tl)  echo "Tagalog" ;;
  tr)  echo "Turkish" ;;
  uk)  echo "Ukrainian" ;;
  uz)  echo "Uzbek" ;;
  wa)  echo "Walloon" ;;
  xh)  echo "Xhosa" ;;
  yi)  echo "Yiddish" ;;
  zh)  echo "Chinese" ;;
  zu)  echo "Zulu" ;;
  *)   echo "$1" ;;
  esac
}

# ISO-3166 country codes for locales
iso3166_country() {
  case "$1" in
  AD) echo "Andorra" ;;
  AE) echo "United Arab Emirates" ;;
  AL) echo "Albania" ;;
  AR) echo "Argentina" ;;
  AT) echo "Austria" ;;
  AU) echo "Australia" ;;
  BA) echo "Bosnia and Herzegovina" ;;
  BE) echo "Belgium" ;;
  BG) echo "Bulgaria" ;;
  BH) echo "Bahrain" ;;
  BO) echo "Bolivia" ;;
  BR) echo "Brazil" ;;
  BW) echo "Botswana" ;;
  BY) echo "Belarus" ;;
  CA) echo "Canada" ;;
  CH) echo "Switzerland" ;;
  CL) echo "Chile" ;;
  CN) echo "China" ;;
  CO) echo "Colombia" ;;
  CR) echo "Costa Rica" ;;
  CY) echo "Cyprus" ;;
  CZ) echo "Czech Republic" ;;
  DE) echo "Germany" ;;
  DJ) echo "Djibouti" ;;
  DK) echo "Denmark" ;;
  DO) echo "Dominican Republic" ;;
  DZ) echo "Algeria" ;;
  EC) echo "Ecuador" ;;
  EE) echo "Estonia" ;;
  EG) echo "Egypt" ;;
  ES) echo "Spain" ;;
  FI) echo "Finland" ;;
  FO) echo "Faroe Islands" ;;
  FR) echo "France" ;;
  GB) echo "Great Britain" ;;
  GE) echo "Georgia" ;;
  GL) echo "Greenland" ;;
  GR) echo "Greece" ;;
  GT) echo "Guatemala" ;;
  HK) echo "Hong Kong" ;;
  HN) echo "Honduras" ;;
  HR) echo "Croatia" ;;
  HU) echo "Hungary" ;;
  ID) echo "Indonesia" ;;
  IE) echo "Ireland" ;;
  IL) echo "Israel" ;;
  IN) echo "India" ;;
  IQ) echo "Iraq" ;;
  IS) echo "Iceland" ;;
  IT) echo "Italy" ;;
  JO) echo "Jordan" ;;
  JP) echo "Japan" ;;
  KE) echo "Kenya" ;;
  KR) echo "Korea, Republic of" ;;
  KW) echo "Kuwait" ;;
  KZ) echo "Kazakhstan" ;;
  LB) echo "Lebanon" ;;
  LT) echo "Lithuania" ;;
  LU) echo "Luxembourg" ;;
  LV) echo "Latvia" ;;
  LY) echo "Libya" ;;
  MA) echo "Morocco" ;;
  MG) echo "Madagascar" ;;
  MK) echo "Macedonia" ;;
  MT) echo "Malta" ;;
  MX) echo "Mexico" ;;
  MY) echo "Malaysia" ;;
  NI) echo "Nicaragua" ;;
  NL) echo "Netherlands" ;;
  NO) echo "Norway" ;;
  NZ) echo "New Zealand" ;;
  OM) echo "Oman" ;;
  PA) echo "Panama" ;;
  PE) echo "Peru" ;;
  PH) echo "Philippines" ;;
  PL) echo "Poland" ;;
  PR) echo "Puerto Rico" ;;
  PT) echo "Portugal" ;;
  PY) echo "Paraguay" ;;
  QA) echo "Qatar" ;;
  RO) echo "Romania" ;;
  RU) echo "Russian Federation" ;;
  SA) echo "Saudi Arabia" ;;
  SD) echo "Sudan" ;;
  SE) echo "Sweden" ;;
  SG) echo "Singapore" ;;
  SI) echo "Slovenia" ;;
  SK) echo "Slovakia" ;;
  SO) echo "Somalia" ;;
  SV) echo "El Salvador" ;;
  SY) echo "Syria" ;;
  TH) echo "Thailand" ;;
  TJ) echo "Tajikistan" ;;
  TN) echo "Tunisia" ;;
  TR) echo "Turkey" ;;
  TW) echo "Taiwan" ;;
  UA) echo "Ukraine" ;;
  UG) echo "Uganda" ;;
  US) echo "United States of America" ;;
  UY) echo "Uruguay" ;;
  UZ) echo "Uzbekistan" ;;
  VE) echo "Venezuela" ;;
  YE) echo "Yemen" ;;
  ZA) echo "South Africa" ;;
  ZW) echo "Zimbabwe" ;;
  *)  echo "$1" ;;
  esac
}

# Function to display the disc(s) size in GB and sector size from system
show_disks() {
  # Define some variables local
  local dev size sectorsize gbytes

  # IDE
  for dev in $(ls /sys/block|grep -E '^hd'); do
    if [ "$(cat /sys/block/"$dev"/device/media)" = "disk" ]; then
      # Find out nr sectors and bytes per sector;
      echo "/dev/$dev"
      size=$(cat /sys/block/"$dev"/size)
      sectorsize=$(cat /sys/block/"$dev"/queue/hw_sector_size)
      gbytes="$((size * sectorsize / 1024 / 1024 / 1024))"
      echo "size:${gbytes}GB;sector_size:$sectorsize"
    fi
  done
  # SATA/SCSI and Virtual disks (virtio)
  for dev in $(ls /sys/block|grep -E '^([sv]|xv)d|mmcblk|nvme'); do
    echo "/dev/$dev"
    size=$(cat /sys/block/"$dev"/size)
    sectorsize=$(cat /sys/block/"$dev"/queue/hw_sector_size)
    gbytes="$((size * sectorsize / 1024 / 1024 / 1024))"
    echo "size:${gbytes}GB;sector_size:$sectorsize"
  done
  # cciss(4) devices
  for dev in $(ls /dev/cciss 2>/dev/null|grep -E 'c[0-9]d[0-9]$'); do
    echo "/dev/cciss/$dev"
    size=$(cat /sys/block/cciss\!"$dev"/size)
    sectorsize=$(cat /sys/block/cciss\!"$dev"/queue/hw_sector_size)
    gbytes="$((size * sectorsize / 1024 / 1024 / 1024))"
    echo "size:${gbytes}GB;sector_size:$sectorsize"
  done
}

# Function to get fs type from configuration if available.
# This ensures that, the user is shown the proper fs type if they install the system.
get_partfs() {
  # Get fs type from configuration if available. This ensures
  # that the user is shown the proper fs type if they install the system.

  # Define some variables local
  local part default fstype

  part="$1"
  default="${2:-none}"
  fstype=$(grep "MOUNTPOINT ${part} " "$CONF_FILE"|awk '{print $3}')
  echo "${fstype:-$default}"
}

# Function show partitions
show_partitions() {
  local dev fstype fssize p part

  set -- $(show_disks)
  while [ $# -ne 0 ]; do
    disk=$(basename $1)
    shift 2
    # ATA/SCSI/SATA
    for p in /sys/block/$disk/$disk*; do
      if [ -d $p ]; then
        part=$(basename "$p")
        fstype=$(lsblk -nfr /dev/"$part"|awk '{print $2}'|head -1)
        [ "$fstype" = "iso9660" ] && continue
        [ "$fstype" = "crypto_LUKS" ] && continue
        [ "$fstype" = "LVM2_member" ] && continue
        fssize=$(lsblk -nr /dev/"$part"|awk '{print $4}'|head -1)
        echo "/dev/$part"
        echo "size:${fssize:-unknown};fstype:$(get_partfs "/dev/$part")"
      fi
    done
  done
  # Device Mapper
  for p in /dev/mapper/*; do
    part=$(basename "$p")
    [ "${part}" = "live-rw" ] && continue
    [ "${part}" = "live-base" ] && continue
    [ "${part}" = "control" ] && continue

    fstype=$(lsblk -nfr "$p"|awk '{print $2}'|head -1)
    fssize=$(lsblk -nr "$p"|awk '{print $4}'|head -1)
    echo "${p}"
    echo "size:${fssize:-unknown};fstype:$(get_partfs "$p")"
  done
  # Software raid (md)
  for p in $(ls -d /dev/md* 2>/dev/null|grep '[0-9]'); do
    part=$(basename $p)
    if cat /proc/mdstat|grep -qw "$part"; then
      fstype=$(lsblk -nfr /dev/"$part"|awk '{print $2}')
      [ "$fstype" = "crypto_LUKS" ] && continue
      [ "$fstype" = "LVM2_member" ] && continue
      echo "$fstype" | grep -q "crypto_LUKS" && echo "$fstype" | grep -q "LVM2_member" && continue # for LVM on LUKS on RAID
      fssize=$(lsblk -nr /dev/"$part"|awk '{print $4}')
      echo "$p"
      echo "size:${fssize:-unknown};fstype:$(get_partfs "$p")"
    fi
  done
  # cciss(4) devices
  for part in $(ls /dev/cciss 2>/dev/null|grep -E 'c[0-9]d[0-9]p[0-9]+'); do
    fstype=$(lsblk -nfr /dev/cciss/"$part"|awk '{print $2}')
    [ "$fstype" = "crypto_LUKS" ] && continue
    [ "$fstype" = "LVM2_member" ] && continue
    fssize=$(lsblk -nr /dev/cciss/"$part"|awk '{print $4}')
    echo "/dev/cciss/$part"
    echo "size:${fssize:-unknown};fstype:$(get_partfs "/dev/cciss/$part")"
  done
  if [ -e /sbin/lvs ]; then
    # LVM
    lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"
      echo "size:${size};fstype:$(get_partfs "/dev/mapper/${vgname}-${lvname}" lvm)"
    done
  fi
}

# Function to chose and set the filesystem used to format the device selected and mount point
menu_filesystems() {
  # Define some variables local
  local dev fstype fssize mntpoint reformat bdev ddev result _dev

  while true; do
    DIALOG --ok-label "Change" --cancel-label "Done" \
      --title " Select the partition to edit " --menu "$MENULABEL" \
      ${MENUSIZE} $(show_partitions_filtered "$_dev")
    result=$?
    [ "$result" -ne 0 ] && return

    dev=$(cat $ANSWER)
    _dev+=" $dev"
    DIALOG --title " Select the filesystem type for $dev " \
      --menu "$MENULABEL" ${MENUSIZE} \
      "btrfs" "Subvolume @,@home,@var_log,@var_lib,@snapshots" \
      "ext2" "Linux ext2 (no journaling)" \
      "ext3" "Linux ext3 (journal)" \
      "ext4" "Linux ext4 (journal)" \
      "f2fs" "Flash-Friendly Filesystem" \
      "f2fs_c" "Flash-Friendly Filesystem with compression, lazytime" \
      "swap" "Linux swap" \
      "vfat" "FAT32" \
      "xfs" "SGI's XFS"
    if [ $? -eq 0 ]; then
      fstype=$(cat "$ANSWER")
    else
      continue
    fi
    if [ "$fstype" != "swap" ]; then
      DIALOG --inputbox "Please specify the mount point for $dev:" ${INPUTSIZE}
      result=$?
      if [ "$result" -eq 0 ]; then
        mntpoint=$(cat "$ANSWER")
      elif [ $? -eq 1 ]; then
        continue
      fi
    else
      mntpoint=swap
    fi
    DIALOG --yesno "Do you want to create a new filesystem on $dev?" ${YESNOSIZE}
    result=$?
    if [ "$result" -eq 0 ]; then
      reformat=1
    elif [ $? -eq 1 ]; then
      reformat=0
    else
      continue
    fi
    fssize=$(lsblk -nr "$dev"|awk '{print $4}')
    set -- "$fstype" "$fssize" "$mntpoint" "$reformat"
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]; then
      bdev=$(basename "$dev")
      ddev=$(basename "$(dirname "$dev")")
      if [ "$ddev" != "dev" ]; then
        sed -i -e "/^MOUNTPOINT \/dev\/${ddev}\/${bdev} .*/d" "$CONF_FILE"
      else
        sed -i -e "/^MOUNTPOINT \/dev\/${bdev} .*/d" "$CONF_FILE"
      fi
      echo "MOUNTPOINT $dev $1 $2 $3 $4" >>"$CONF_FILE"
    fi
  done
  FILESYSTEMS_DONE=1
}

# Function for the list with partitions filtered by selected partitions
show_partitions_filtered() {
  # Define some local variables
  local _dev filtered_list
  _dev=$1 # function parameter
  # Function that filters the list to remove lines matching _dev parameter
  filtered_list=$(show_partitions | awk -v dev="$_dev" '
  BEGIN {
    # Separate _dev into the 'partitions' array
    split(dev, partitions, " ")
  }

  {
    # Check if the current line is a partition to be excluded
    match_found = 0
    for (i in partitions) {
      if ($1 == partitions[i]) {
        match_found = 1  # Mark the lines to be excluded
        break
      }
    }

    # If we found a match, we set the skip flag and ignore the next line too
    if (match_found) {
      skip = 1  # Set the flag to skip
      next  # Jump to the next line
    }

    # Print the line in the output
    if (!skip) {
      print $0  # Print the current line
    } else {
      skip = 0  # Reset the skip flag for the next line
    }
  }
')
  # Print the filtered list
  echo "$filtered_list"
}

# Function for menu Hardening
menu_hardening() {
  # Define some local variables
  local _desc _checklist _answers rv _apparmor _hardening _state_armor _state_hardening _audit _state_audit _options \
    _tag _label _label_for _raw _selected_tags _file_audit _file_sysctl _status _line _firewall _state_firewall
  # Loading local variable from config file
  _apparmor=$(get_option APPARMOR)
  if  [ -n "$_apparmor" ] && [ "$_apparmor" -eq 1 ]; then
    _state_armor="on"
  else
    _state_armor="off"
  fi
  _hardening=$(get_option HARDENING)
  if [ -n "$_hardening" ] && [ "$_hardening" -eq 1 ]; then
    _state_hardening="on"
  else
    _state_hardening="off"
  fi
  _audit=$(get_option AUDIT)
  if [ -n "$_audit" ] && [ "$_audit" -eq 1 ]; then
    _state_audit="on"
  else
    _state_audit="off"
  fi
  _firewall=$(get_option FIREWALL)
  if [ -n "$_firewall" ] && [ "$_firewall" -eq 1 ]; then
    _state_firewall="on"
  else
    _state_firewall="off"
  fi
  # Messagebox with some info
  DIALOG --title "Hardening" --msgbox "\n
  ${BOLD}${RED}WARNING: If you're beginner, try these options on a test machine first!${RESET}\n\n
  In the next window you can choose which configurations to load at boot:\n\n
${BOLD}${YELLOW}AppArmor${RESET} – a Linux security module that confines programs to a set of defined permissions (profiles). \
It enforces access control by restricting file, network, and capability usage, helping prevent exploits even if an \
application is compromised.\n\n
${BOLD}${YELLOW}Firewall Manager(vuurmuur)${RESET} – Is a firewall manager for Linux, built on top of iptables. Purpose \
a high-level interface for netfilter - you create zones, networks, hosts, and rules in an easy-to-understand way; it \
generates iptables rules or scripts. Interface is interactive Ncurses(terminal); can be managed over SSH.\n
${BOLD}${YELLOW}Audit${RESET} – the Linux auditing subsystem (auditd) that records security‑relevant events such as \
system calls, file accesses, and user actions. Administrators configure rules to log specific activities, then review \
the logs for compliance or incident investigation.\n
User is necessary to be part from ${BLUE}'audit'${RESET} group for reading the log.\n
You have some examples to choose and finally these setting can be edited, before to install, on ${BLUE}'/tmp/99-myconfig.rules'${RESET}.\n
Settings are stored on ${BLUE}'/etc/audit/rules.d/99-myconfig.conf'${RESET}, after install.\n\n
${BOLD}${YELLOW}Hardening(sysctl)${RESET} – a kernel interface for viewing and modifying runtime parameters.\n
You have some examples for a Desktop or Server machine, and finally these setting can be edited, before to install, on \
${BLUE}'/tmp/99-myconfig.conf'${RESET}.\n
Settings are stored on ${BLUE}'/etc/sysctl.d/99-myconfig.conf'${RESET}, after install.\n
It controls networking, security, and performance options." 30 80
  # Description for checklist box
  _desc="Select if you wish to setting AppArmor, firewall and hardening"
  # Description for checklist box
  _checklist=(
  "apparmor" "AppArmor" "$_state_armor" \
  "firewall" "Firewall Manager(vuurmuur)" "$_state_firewall" \
  "audit" "Audit" "$_state_audit" \
  "hardening" "Hardening(sysctl)" "$_state_hardening")
  # Create dialog
  DIALOG --no-tags --checklist "$_desc" 20 60 4 "${_checklist[@]}"
  # Verify if the user accept the dialog
  rv=$?
  if [ "$rv" -eq 0 ]; then
    _answers=$(cat "$ANSWER")
    if echo "$_answers" | grep -q "apparmor"; then
      set_option APPARMOR "1"
    else
      set_option APPARMOR "0"
    fi
    if echo "$_answers" | grep -q "firewall"; then\
      set_option FIREWALL "1"
    else
      set_option FIREWALL "0"
    fi
    _firewall=$(get_option FIREWALL)
    if [ "$_firewall" -eq 1 ]; then
      vuurmuur_conf -W 2>>"$LOG"
      clear
    fi
    if echo "$_answers" | grep -q "audit"; then\
      set_option AUDIT "1"
    else
      set_option AUDIT "0"
    fi
    _audit=$(get_option AUDIT)
    if [ "$_audit" -eq 1 ]; then
      # Build the list with options for hardening
    #_file="${1:-}" # Default to empty, file can be passed as an argument
      _file_audit=$AUDIT_FILE
      if [ -n "$_file_audit" ] && [ -f "$_file_audit" ]; then
        # Empty the array
        _options=()
        # Read every line from file
        while IFS= read -r _line; do
          # Ignore empty lines
          [[ -z "$_line" ]] && continue
          # Line have the form: <tag> "<label>" <status>
          # Use eval to evaluated correctly ""
          eval "set -- $_line"
          _tag=$1
          _label=$2
          _status=$3
          # Add elements in _options array
          _options+=( "$_tag" "$_label" "$_status" )
        done < "$_file_audit" # Open file send as argument
      else
      _options=(
        1 "# Audit for BRGV-OS ###############################################################" off
        2 "# Self Auditing ###################################################################" off
        3 "## Audit the audit logs" off
        4 "### Successful and unsuccessful attempts to read information from the audit records" off
        5 "-a always,exit -F arch=b64 -F dir=/var/log/audit/ -F perm=wra -F key=auditlog" off
        6 "## Auditd configuration" off
        7 "### Modifications to audit configuration that occur while the audit collection functions are operating" off
        8 "-a always,exit -F arch=b64 -F dir=/etc/audit/ -F perm=wa -F key=auditconfig" off
        9 "-a always,exit -F arch=b64 -F path=/etc/libaudit.conf -F perm=wa -F key=auditconfig" off
        10 "## Monitor for use of audit management tools" off
        11 "-a always,exit -F arch=b64 -F path=/usr/sbin/auditctl -F perm=x -F key=audittools" off
        12 "-a always,exit -F arch=b64 -F path=/usr/sbin/auditd -F perm=x -F key=audittools" off
        13 "-a always,exit -F arch=b64 -F path=/usr/sbin/augenrules -F perm=x -F key=audittools" off
        14 "## Access to all audit trails" off
        15 "-a always,exit -F arch=b64 -F path=/usr/sbin/ausearch -F perm=x -F key=audittools" off
        16 "-a always,exit -F arch=b64 -F path=/usr/sbin/aureport -F perm=x -F key=audittools" off
        17 "-a always,exit -F arch=b64 -F path=/usr/sbin/aulast -F perm=x -F key=audittools" off
        18 "-a always,exit -F arch=b64 -F path=/usr/sbin/aulastlog -F perm=x -F key=audittools" off
        19 "# Filters ######################################################################" off
        20 "### We put these early because audit is a first match wins system" off
        21 "## Ignore current working directory records" off
        22 "## -a always,exclude -F arch=b64 -F msgtype=CWD" off
        23 "## Cron jobs fill the logs with stuff we normally do not want" off
        24 "-a never,user -F arch=b64 -F subj_type=crond_t" off
        25 "-a never,exit -F arch=b64 -F subj_type=crond_t" off
        26 "## This prevents chrony from overwhelming the logs" off
        27 "-a never,exit -F arch=b64 -S adjtimex -F auid=-1 -F uid=chrony -F subj_type=chronyd_t" off
        28 "## This is not very interesting and wastes a lot of space if the server is public facing" off
        29 "-a always,exclude -F arch=b64 -F msgtype=CRYPTO_KEY_USER" off
        30 "## High Volume Event Filter (especially on Linux Workstations)" off
        31 "-a never,exit -F arch=b32 -F dir=/dev/shm/ -F key=sharedmemaccess" off
        32 "-a never,exit -F arch=b64 -F dir=/dev/shm/ -F key=sharedmemaccess" off
        33 "-a never,exit -F arch=b32 -F dir=/var/lock/lvm/ -F key=locklvm" off
        34 "-a never,exit -F arch=b64 -F dir=/var/lock/lvm/ -F key=locklvm" off
        35 "# Rules #######################################################################" off
        36 "## Kernel parameters" off
        37 "-a always,exit -F arch=b64 -F path=/etc/sysctl.conf -F perm=wa -F key=sysctl" off
        38 "-a always,exit -F arch=b64 -F path=/etc/sysctl.d -F perm=wa -F key=sysctl" off
        39 "## Kernel module loading and unloading" off
        40 "-a always,exit -F arch=b64 -F perm=x -F auid!=-1 -F path=/usr/sbin/insmod -F key=modules" off
        41 "-a always,exit -F arch=b64 -F perm=x -F auid!=-1 -F path=/usr/sbin/modprobe -F key=modules" off
        42 "-a always,exit -F arch=b64 -F perm=x -F auid!=-1 -F path=/usr/sbin/rmmod -F key=modules" off
        43 "-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -F key=modules" off
        44 "## Modprobe configuration" off
        45 "-a always,exit -F arch=b64 -F path=/etc/modprobe.d -F perm=wa -F key=modprobe" off
        46 "## Special files" off
        47 "-a always,exit -F arch=b64 -S mknod -S mknodat -F key=specialfiles" off
        48 "## Mount operations (only attributable)" off
        49 "-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -F key=mount" off
        50 "## Change swap (only attributable)" off
        51 "-a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -F key=swap" off
        52 "## Time" off
        53 "### Local time zone" off
        54 "-a always,exit -F arch=b64 -F path=/etc/localtime -F perm=wa -F key=localtime" off
        55 "## Cron configuration & scheduled jobs" off
        56 "-a always,exit -F arch=b64 -F path=/etc/cron.deny -F perm=wa -F key=cron" off
        57 "-a always,exit -F arch=b64 -F dir=/etc/cron.d/ -F perm=wa -F key=cron" off
        58 "-a always,exit -F arch=b64 -F dir=/etc/cron.daily/ -F perm=wa -F key=cron" off
        59 "-a always,exit -F arch=b64 -F dir=/etc/cron.hourly/ -F perm=wa -F key=cron" off
        60 "-a always,exit -F arch=b64 -F dir=/etc/cron.monthly/ -F perm=wa -F key=cron" off
        61 "-a always,exit -F arch=b64 -F dir=/etc/cron.weekly/ -F perm=wa -F key=cron" off
        62 "-a always,exit -F arch=b64 -F dir=/var/spool/cron/ -F perm=wa -F key=cron" off
        63 "## User, group, password databases" off
        64 "-a always,exit -F arch=b64 -F path=/etc/group -F perm=wa -F key=etcgroup" off
        65 "-a always,exit -F arch=b64 -F path=/etc/passwd -F perm=wa -F key=etcpasswd" off
        66 "-a always,exit -F arch=b64 -F path=/etc/gshadow -F perm=wa -F key=etcgroup" off
        67 "-a always,exit -F arch=b64 -F path=/etc/shadow -F perm=wa -F key=etcpasswd" off
        68 "## Sudoers file changes" off
        69 "-a always,exit -F arch=b64 -F path=/etc/sudoers -F perm=wa -F key=actions" off
        70 "-a always,exit -F arch=b64 -F dir=/etc/sudoers.d/ -F perm=wa -F key=actions" off
        71 "## Passwd" off
        72 "-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -F key=passwd_modification" off
        73 "## Tools to change group identifiers" off
        74 "-a always,exit -F arch=b64 -F path=/usr/sbin/groupadd -F perm=x -F key=group_modification" off
        75 "-a always,exit -F arch=b64 -F path=/usr/sbin/groupmod -F perm=x -F key=group_modification" off
        76 "-a always,exit -F arch=b64 -F path=/usr/sbin/useradd -F perm=x -F key=user_modification" off
        77 "-a always,exit -F arch=b64 -F path=/usr/sbin/userdel -F perm=x -F key=user_modification" off
        78 "-a always,exit -F arch=b64 -F path=/usr/sbin/usermod -F perm=x -F key=user_modification" off
        79 "## Login configuration and information" off
        80 "-a always,exit -F arch=b64 -F path=/etc/login.defs -F perm=wa -F key=login" off
        81 "-a always,exit -F arch=b64 -F path=/etc/securetty -F perm=wa -F key=login" off
        82 "-a always,exit -F arch=b64 -F path=/var/log/lastlog -F perm=wa -F key=login" off
        83 "## Network Environment" off
        84 "### Changes to hostname" off
        85 "-a always,exit -F arch=b64 -S sethostname -S setdomainname -F key=network_modifications" off
        86 "### Detect Remote Shell Use" off
        87 "-a always,exit -F arch=b64 -F exe=/usr/bin/bash -F success=1 -S connect -F key=remote_shell" off
        88 "### Successful IPv4 Connections" off
        89 "-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4" off
        90 "### Successful IPv6 Connections" off
        91 "-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6" off
        92 "### Changes to other files" off
        93 "-a always,exit -F arch=b64 -F path=/etc/hosts -F perm=wa -F key=network_modifications" off
        94 "-a always,exit -F arch=b64 -F dir=/etc/NetworkManager/ -F perm=wa -F key=network_modifications" off
        95 "## Library search paths" off
        96 "-a always,exit -F arch=b64 -F path=/etc/ld.so.conf -F perm=wa -F key=libpath" off
        97 "-a always,exit -F arch=b64 -F path=/etc/ld.so.conf.d -F perm=wa -F key=libpath" off
        98 "## Pam configuration" off
        99 "-a always,exit -F arch=b64 -F dir=/etc/pam.d/ -F perm=wa -F key=pam" off
        100 "-a always,exit -F arch=b64 -F path=/etc/security/limits.conf -F perm=wa  -F key=pam" off
        101 "-a always,exit -F arch=b64 -F path=/etc/security/limits.d -F perm=wa  -F key=pam" off
        102 "-a always,exit -F arch=b64 -F path=/etc/security/namespace.conf -F perm=wa -F key=pam" off
        103 "-a always,exit -F arch=b64 -F path=/etc/security/namespace.d -F perm=wa -F key=pam" off
        104 "-a always,exit -F arch=b64 -F path=/etc/security/namespace.init -F perm=wa -F key=pam" off
        105 "## SSH configuration" off
        106 "-a always,exit -F arch=b64 -F path=/etc/ssh/sshd_config -F key=sshd" off
        107 "-a always,exit -F arch=b64 -F path=/etc/ssh/sshd_config.d -F key=sshd" off
        108 "## AppArmor events that modify the system's Mandatory Access Controls (MAC)" off
        109 "-a always,exit -F arch=b64 -F dir=/etc/apparmor.d/ -F perm=wa -F key=mac_policy" off
        110 "## Critical elements access failures" off
        111 "-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -F key=unauthedfileaccess" off
        112 "-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -F key=unauthedfileaccess" off
        113 "-a always,exit -F arch=b64 -S open -F dir=/sbin -F success=0 -F key=unauthedfileaccess" off
        114 "-a always,exit -F arch=b64 -S open -F dir=/usr/bin -F success=0 -F key=unauthedfileaccess" off
        115 "-a always,exit -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -F key=unauthedfileaccess" off
        116 "-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -F key=unauthedfileaccess" off
        117 "-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -F key=unauthedfileaccess" off
        118 "## Process ID change (switching accounts) applications" off
        119 "-a always,exit -F arch=b64 -F path=/usr/bin/su -F perm=x -F key=priv_esc" off
        120 "-a always,exit -F arch=b64 -F path=/usr/bin/sudo -F perm=x -F key=priv_esc" off
        121 "## Power state" off
        122 "-a always,exit -F arch=b64 -F path=/sbin/shutdown -F perm=x -F key=power" off
        123 "-a always,exit -F arch=b64 -F path=/sbin/poweroff -F perm=x -F key=power" off
        124 "-a always,exit -F arch=b64 -F path=/sbin/reboot -F perm=x -F key=power" off
        125 "-a always,exit -F arch=b64 -F path=/sbin/halt -F perm=x -F key=power" off
        126 "## Session initiation information" off
        127 "-a always,exit -F arch=b64 -F path=/var/run/utmp -F perm=wa -F key=session" off
        128 "## Discretionary Access Control (DAC) modifications" off
        129 "-a always,exit -F arch=b64 -S chmod  -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        130 "-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        131 "-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        132 "-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        133 "-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        134 "-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        135 "-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        136 "-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        137 "-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        138 "-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        139 "-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        140 "-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        141 "-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" off
        142 "# Software Management #############################################################" off
        143 "# XBPS (Void)" off
        144 "-a always,exit -F arch=b64 -F path=/usr/bin/xbps-install -F perm=x -F key=software_mgmt" off
        145 "-a always,exit -F arch=b64 -F path=/usr/bin/xbps-remove -F perm=x -F key=software_mgmt" off
        146 "-a always,exit -F arch=b64 -F dir=/var/db/xbps/ -F perm=wa -F key=software_mgmt" off
        147 "# High Volume Events ##############################################################" off
        148 "## Root command executions" off
        149 "-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -F key=rootcmd" off
        150 "## File Deletion Events by User" off
        151 "-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -F key=delete" off
        152 "## File Access" off
        153 "### Unauthorized Access (unsuccessful)" off
        154 "-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -F key=file_access" off
        155 "-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -F key=file_access" off
        156 "### Unsuccessful Creation" off
        157 "-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -F key=file_creation" off
        158 "-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -F key=file_creation" off
        159 "### Unsuccessful Modification" off
        160 "-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -F key=file_modification" off
        161 "-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -F key=file_modification" off
        162 "## 32bit ABI Exploitation" off
        163 "### https://github.com/linux-audit/audit-userspace/blob/c014eec64b3a16c004f4a75e5792a4ac2fcc0df2/rules/21-no32bit.rules" off
        164 "### If you are on a 64 bit platform, everything _should_ be running" off
        165 "### in 64 bit mode. This rule will detect any use of the 32 bit syscalls" off
        166 "### because this might be a sign of someone exploiting a hole in the 32" off
        167 "### bit ABI." off
        168 "-a always,exit -F arch=b32 -S all -F key=32bit_abi" off
      )
      fi
      # Empty variable used before
      _label=
      _tag=
      _raw=
      # Create a tag → label map (associative array)
      declare -A label_for
      for ((i=0; i<${#_options[@]}; i+=3)); do
        _tag=${_options[i]}
        _label=${_options[i+1]}
        _label_for[$_tag]="$_label"
      done
      # Open form dialog
      exec 3>&1
      # Show the build list dialog
      _raw=$(dialog --colors --keep-tite --no-shadow --no-mouse --visit-items --title "Audit Options" \
        --backtitle "${BOLD}${WHITE}BRGV-OS Linux installation -- https://github.com/florintanasa/brgvos-void (@@MKLIVE_VERSION@@)${RESET}" \
        --buildlist "Select (using space key) the options you want. To select the window use '^', for left, or '$', for right:" 30 130 2 \
        "${_options[@]}" 3>&1 1>&2 2>&3)
      # Close form dialog
      exec 3>&-
      # Translate the returned tags back to their labels
      _selected_tags=($_raw)               # split on whitespace
      {
        for _tag in "${_selected_tags[@]}"; do
          # If the user removed an entry, the tag may no longer exist
          # in the map – skip empty results.
          [[ -n ${_label_for[$_tag]} ]] && printf '%s\n' "${_label_for[$_tag]}"
        done
      } > /tmp/99-myconfig.rules
    fi
    if echo "$_answers" | grep -q "hardening"; then
      set_option HARDENING "1"
    else
      set_option HARDENING "0"
    fi
  elif [ "$rv" -eq 1 ]; then # Verify is user not accept the dialog
    return
  fi
  _hardening=$(get_option HARDENING)
  if [ "$_hardening" -eq 1 ]; then
    # Build the list with options for hardening
    #_file="${1:-}" # Default to empty, file can be passed as an argument
    _file_sysctl=$SYSCTL_FILE
    if [ -n "$_file_sysctl" ] && [ -f "$_file_sysctl" ]; then
      # Empty the array
      _options=()
      # Read every line from file
      while IFS= read -r _line; do
        # Ignore empty lines
        [[ -z "$_line" ]] && continue
        # Line have the form: <tag> "<label>" <status>
        # Use eval to evaluated correctly ""
        eval "set -- $_line"
        _tag=$1
        _label=$2
        _status=$3
        # Add elements in _options array
        _options+=( "$_tag" "$_label" "$_status" )
      done < "$_file_sysctl" # Open file send as argument
    else
    _options=(
      1 "# Desktop — compatibility, privacy, security" off
      2 "kernel.yama.ptrace_scope = 1" off
      3 "kernel.kptr_restrict = 2" off
      4 "kernel.dmesg_restrict = 1" off
      5 "kernel.sysrq = 0" off
      6 "fs.protected_symlinks = 1" off
      7 "fs.protected_hardlinks = 1" off
      8 "fs.protected_fifos = 2" off
      9 "fs.protected_regular = 2" off
      10 "# Permit user namespaces for containerized desktop apps" off
      11 "kernel.unprivileged_userns_clone = 1" off
      12 "# Allow unprivileged eBPF for desktop tooling" off
      13 "kernel.unprivileged_bpf_disabled = 0" off
      14 "net.core.bpf_jit_harden = 2" off
      15 "# ICMP and networking — enable IPv6 and ping for usability" off
      16 "net.ipv4.icmp_echo_ignore_all = 0" off
      17 "net.ipv6.conf.all.disable_ipv6 = 0" off
      18 "net.ipv6.conf.default.disable_ipv6 = 0" off
      19 "# TCP behaviour: keep timestamps (better perf), conservative swappiness" off
      20 "net.ipv4.tcp_timestamps = 1" off
      21 "vm.swappiness = 10" off
      22 "# Reasonable defaults for local workloads" off
      23 "net.core.somaxconn = 128" off
      24 "net.core.netdev_max_backlog = 4096" off
      25 "# Moderate socket buffers" off
      26 "net.core.rmem_default = 262144" off
      27 "net.core.rmem_max = 4194304" off
      28 "net.core.wmem_default = 262144" off
      29 "net.core.wmem_max = 4194304" off
      30 "net.core.optmem_max = 65536" off
      31 "# TCP memory (min, default, max)" off
      32 "net.ipv4.tcp_rmem = 4096 131072 2097152" off
      33 "net.ipv4.tcp_wmem = 4096 131072 2097152" off
      34 "# UDP minimum buffers" off
      35 "net.ipv4.udp_rmem_min = 8192" off
      36 "net.ipv4.udp_wmem_min = 8192" off
      37 "# Other desktop-friendly defaults" off
      38 "kernel.perf_event_paranoid = 2" off
      98 "############################################################" off
      99 "############################################################" off
      101 "# Server — hardening + network tuning for throughput and resilience" off
      102 "kernel.yama.ptrace_scope = 3" off
      103 "kernel.kexec_load_disabled = 1" off
      104 "kernel.kptr_restrict = 2" off
      105 "kernel.dmesg_restrict = 1" off
      106 "kernel.sysrq = 0" off
      107 "dev.tty.ldisc_autoload = 0" off
      108 "kernel.unprivileged_userns_clone = 0" off
      109 "kernel.unprivileged_bpf_disabled = 1" off
      110 "net.core.bpf_jit_harden = 2" off
      111 "kernel.perf_event_paranoid = 3" off
      112 "# SYN flood / TCP protections" off
      113 "net.ipv4.tcp_syncookies = 1" off
      114 "net.ipv4.tcp_rfc1337 = 1" off
      115 "# ASLR / entropy for mmap" off
      116 "vm.mmap_rnd_bits = 32" off
      117 "vm.mmap_rnd_compat_bits = 16" off
      118 "# Spoofing / ICMP redirects" off
      119 "net.ipv4.conf.all.rp_filter = 1" off
      120 "net.ipv4.conf.default.rp_filter = 1" off
      121 "net.ipv4.conf.all.accept_redirects = 0" off
      122 "net.ipv4.conf.default.accept_redirects = 0" off
      123 "net.ipv4.conf.all.secure_redirects = 0" off
      124 "net.ipv4.conf.default.secure_redirects = 0" off
      125 "net.ipv4.conf.all.send_redirects = 0" off
      126 "net.ipv4.conf.default.send_redirects = 0" off
      127 "# ICMP echo: disable to reduce surface (set 1 to block)" off
      128 "net.ipv4.icmp_echo_ignore_all = 1" off
      129 "# Protect filesystems" off
      130 "fs.protected_fifos = 2" off
      131 "fs.protected_regular = 2" off
      132 "fs.protected_symlinks = 1" off
      133 "fs.protected_hardlinks = 1" off
      134 "# Source route / redirects" off
      135 "net.ipv4.conf.all.accept_source_route = 0" off
      136 "net.ipv4.conf.default.accept_source_route = 0" off
      137 "# TCP SACK: disable only if kernel is vulnerable; otherwise consider enabling" off
      138 "net.ipv4.tcp_sack = 0" off
      139 "net.ipv4.tcp_dsack = 0" off
      140 "net.ipv4.tcp_fack = 0" off
      141 "# IPv6: disable if not used; enable/configure if required" off
      142 "net.ipv6.conf.all.disable_ipv6 = 1" off
      143 "net.ipv6.conf.default.disable_ipv6 = 1" off
      144 "net.ipv6.conf.lo.disable_ipv6 = 1" off
      145 "net.ipv6.conf.default.router_solicitations = 0" off
      146 "net.ipv6.conf.default.accept_ra_rtr_pref = 0" off
      147 "net.ipv6.conf.default.accept_ra_pinfo = 0" off
      148 "net.ipv6.conf.default.accept_ra_defrtr = 0" off
      149 "net.ipv6.conf.all.accept_ra = 0" off
      150 "net.ipv6.conf.default.accept_ra = 0" off
      151 "net.ipv6.conf.default.autoconf = 0" off
      152 "net.ipv6.conf.default.dad_transmits = 0" off
      153 "net.ipv6.conf.default.max_addresses = 1" off
      154 "# Privacy for IPv6 addresses (temporary addresses)" off
      155 "net.ipv6.conf.all.use_tempaddr = 2" off
      156 "net.ipv6.conf.default.use_tempaddr = 2" off
      157 "# Prevent time leakage" off
      158 "net.ipv4.tcp_timestamps = 0" off
      159 "# Networking performance tuning" off
      160 "net.core.netdev_max_backlog = 16384" off
      161 "net.core.somaxconn = 8192" off
      162 "net.core.rmem_default = 1048576" off
      163 "net.core.rmem_max = 16777216" off
      164 "net.core.wmem_default = 1048576" off
      165 "net.core.wmem_max = 16777216" off
      166 "net.core.optmem_max = 65536" off
      167 "net.ipv4.tcp_rmem = 4096 1048576 2097152" off
      168 "net.ipv4.tcp_wmem = 4096 65536 16777216" off
      169 "net.ipv4.udp_rmem_min = 8192" off
      170 "net.ipv4.udp_wmem_min = 8192" off
      171 "net.ipv4.tcp_fastopen = 3" off
      172 "net.ipv4.tcp_max_syn_backlog = 8192" off
      173 "net.ipv4.tcp_max_tw_buckets = 2000000" off
      174 "net.ipv4.tcp_tw_reuse = 1" off
      175 "net.ipv4.tcp_fin_timeout = 10" off
      176 "net.ipv4.tcp_slow_start_after_idle = 0" off
      177 "net.ipv4.tcp_mtu_probing = 1" off
      178 "# Swappiness tuned for servers - use more from 99% RAM and then from swap" off
      179 "vm.swappiness = 1" off
    )
    fi
    # Empty variable used before
    _label=
    _tag=
    _raw=
    # Create a tag → label map (associative array)
    declare -A label_for
    for ((i=0; i<${#_options[@]}; i+=3)); do
      _tag=${_options[i]}
      _label=${_options[i+1]}
      _label_for[$_tag]="$_label"
    done
    # Open form dialog
    exec 3>&1
    # Show the build list dialog
    _raw=$(dialog --colors --keep-tite --no-shadow --no-mouse --visit-items --title "Hardening(sysctl) Options" \
      --backtitle "${BOLD}${WHITE}BRGV-OS Linux installation -- https://github.com/florintanasa/brgvos-void (@@MKLIVE_VERSION@@)${RESET}" \
      --buildlist "Select (using space key) the options you want. To select the window use '^', for left, or '$', for right:" 30 130 2 \
      "${_options[@]}" 3>&1 1>&2 2>&3)
    # Close form dialog
    exec 3>&-
    # Translate the returned tags back to their labels
   _selected_tags=($_raw)               # split on whitespace
    {
      for _tag in "${_selected_tags[@]}"; do
        # If the user removed an entry, the tag may no longer exist
        # in the map – skip empty results.
        [[ -n ${_label_for[$_tag]} ]] && printf '%s\n' "${_label_for[$_tag]}"
      done
    } > /tmp/99-myconfig.conf
  fi
  # set hardening done
  HARDENING_DONE=1
}

# Function to setting Firewall Manager (vuurmuur
set_firewall() {
  # Define some local function
  local _source
  _source=$(get_option SOURCE)
  echo "Enable service 'vuurmuur' to start at boot..."  >>"$LOG"
  chroot "$TARGETDIR" ln -s /etc/sv/vuurmuur /etc/runit/runsvdir/default/
  echo "Enable service 'vuurmuur-log' to start at boot..." >>"$LOG"
  chroot "$TARGETDIR" ln -s /etc/sv/vuurmuur-log /etc/runit/runsvdir/default/
  # Copy rules file from /etc/vuurmuur/rules to $TARGET/tmp, then copy rules file to /etc/vuurmuur/rules
  if [ -f /tmp/99-myconfig.rules ] && [ "$_source" = "net" ]; then
    echo "Copy firewall directory /etc/vuurmuur to $TARGETDIR/tmp, then copy rules file to /etc" >>"$LOG"
    cp -r /etc/vuurmuur "$TARGETDIR"/tmp
    chroot "$TARGETDIR" cp -r /tmp/vuurmuur /etc/
  fi
}

# Function for setting audit
set_audit() {
  # Define some local variables
  local _user
  # Get username
  _user=$(get_option USERLOGIN)
  {
    if cat "$TARGETDIR"/etc/group | grep -q "audit"; then
      echo "Group 'audit' exist, so is not created..."
    else
      echo "Create group 'audit'..."
      # Create group audit
      chroot "$TARGETDIR" groupadd -r audit
    fi
    # Add user to audit group
    chroot "$TARGETDIR" gpasswd -a "$_user" audit
    if cat "$TARGETDIR"/etc/audit/auditd.conf | grep -q "log_group = root"; then
      echo "Change log_group to audit..."
      # Change log_group to audit
      chroot "$TARGETDIR" sed -i 's/log_group = root/log_group = audit/g' /etc/audit/auditd.conf
    fi
    if cat "$TARGETDIR"/usr/lib/tmpfiles.d/audit.conf | grep -q "d /var/log/audit 0700 root root - -"; then
      echo "Change file mode and group for directory /var/log/audit..."
      # Change file mode and group for directory /var/log/audit
      chroot "$TARGETDIR" sed -i 's/d \/var\/log\/audit 0700 root root - -/d \/var\/log\/audit 0750 root audit - -/g'  /usr/lib/tmpfiles.d/audit.conf
    fi
    echo "Enable service auditctl to start at boot..."
    chroot "$TARGETDIR" ln -s /etc/sv/auditctl /etc/runit/runsvdir/default/
    echo "Enable service auditd to start at boot..."
    chroot "$TARGETDIR" ln -s /etc/sv/auditd /etc/runit/runsvdir/default/
    # Copy rules file from /tmp to $TARGET/tmp, then copy rules file to /etc/audit/rules.d
    if [ -f /tmp/99-myconfig.rules ]; then
      echo "Copy rules file from /tmp to $TARGET/tmp, then copy rules file to /etc/audit/rules.d"
      cp /tmp/99-myconfig.rules "$TARGETDIR"/tmp
      chroot "$TARGETDIR" cp /tmp/99-myconfig.rules /etc/audit/rules.d/
    fi
    echo "Added -i (Ignore errors) in /etc/audit/rules.d/10-base-config.rules"
    chroot "$TARGETDIR" sed -i '$a# Ignore errors' /etc/audit/rules.d/10-base-config.rules
    chroot "$TARGETDIR" sed -i '$a-i' /etc/audit/rules.d/10-base-config.rules
  } >>$LOG 2>&1
}

# Function for setting hardening
set_hardening() {
  # Define some local variables
  local _hardening
  # Load variable with value saved in config file
  _hardening=$(get_option HARDENING)
  # Copy config file from /tmp to $TARGET/tmp, then create directory sysctl.d in $TARGET and copy here the config file
  if [ -f /tmp/99-myconfig.conf ]; then
    {
      cp /tmp/99-myconfig.conf "$TARGETDIR"/tmp
      chroot "$TARGETDIR" mkdir -p /etc/sysctl.d
      chroot "$TARGETDIR" cp /tmp/99-myconfig.conf /etc/sysctl.d/
    } >>$LOG 2>&1
  fi
}

# Function for menu LVM&LUKS
menu_lvm_luks() {
  # Define some local variables
  local _desc _checklist _answers rv _lvm _dev _map _values _mem_total
  local _vgname _lvswap _lvrootfs _lvhome _slvswap _slvrootfs _slvhome _lvextra_1 _lvextra_2 _slvextra_1 _slvextra_2
  # Load some variables from configure file if exist else define presets
  _vgname=$(get_option VGNAME)
  _lvswap=$(get_option LVSWAP)
  _lvrootfs=$(get_option LVROOTFS)
  _lvhome=$(get_option LVHOME)
  _lvextra_1=$(get_option LVEXTRA-1)
  _lvextra_2=$(get_option LVEXTRA-2)
  _slvswap=$(get_option SLVSWAP)
  _slvrootfs=$(get_option SLVROOTFS)
  _slvhome=$(get_option SLVHOME)
  _slvextra_1=$(get_option SLVEXTRA-1)
  _slvextra_2=$(get_option SLVEXTRA-2)
  # Presets some variables
  [ -z "$_vgname" ] && _vgname="vg0"
  [ -z "$_lvswap" ] && _lvswap="lvswap"
  [ -z "$_lvrootfs" ] && _lvrootfs="lvbrgvos"
  [ -z "$_lvhome" ] && _lvhome="lvhome"
  [ -z "$_lvextra_1" ] && _lvextra_1="lvlibvirt"
  [ -z "$_lvextra_2" ] && _lvextra_2="lvsrv"
  [ -z "$_slvrootfs" ] && _slvrootfs="30"
  [ -z "$_slvhome" ] && _slvhome="70"
  [ -z "$_slvextra_1" ] && _slvextra_1="0"
  [ -z "$_slvextra_2" ] && _slvextra_2="0"
  if [ -z "$_slvswap" ]; then
    # Calculate total memory in GB
    _mem_total=$(free -t -g | grep -oP '\d+' | sed '10!d')
    # Calculate swap need, usually 2*RAM
    _slvswap=$((_mem_total*2))
  fi
  # Description for checklist box
  _desc="Select if you wish to use LVM and/or crypt partition"
  # Options for checklist box
  _checklist="
  lvm LVM off \
  crypto_luks CRYPTO_LUKS off"
  # Create dialog
  DIALOG --no-tags --checklist "$_desc" 20 60 2 ${_checklist}
  # Verify if the user accept the dialog
  rv=$?
  if [ "$rv" -eq 0 ]; then
    _answers=$(cat "$ANSWER")
    if echo "$_answers" | grep -q "lvm"; then
      set_option LVM "1"
    else
      set_option LVM "0"
    fi
    if echo "$_answers" | grep -q "crypto_luks"; then
      set_option CRYPTO_LUKS "1"
    else
      set_option CRYPTO_LUKS "0"
    fi
  elif [ "$rv" -eq 1 ]; then # Verify if the user not accept the dialog
    return
  fi
  # Input box is available only if LVM and/or CRYPTO_LUKS was selected
  _lvm=$(get_option LVM)
  _crypto_luks=$(get_option CRYPTO_LUKS)
  # Check if user select LVM or CRYPTO_LUKS
  if [ "$_lvm" -eq 1 ] || [ "$_crypto_luks" -eq 1 ]; then
    while true; do
      DIALOG --ok-label "Select" --cancel-label "Done" --extra-button --extra-label "Abort" \
        --title " Select partition(s) for physical volume" --menu "$MENULABEL" \
        ${MENUSIZE} $(show_partitions_filtered "$_dev")
      rv=$?
      if [ "$rv" = 0 ]; then # Check if user press Select button
        _dev+=$(cat "$ANSWER")
        _dev+=" "
      elif [[ -z "$_dev" ]] || [[ "$rv" -eq 3 ]]; then # Check if user press Abort or Done buttons without selection
        return
      elif [ "$rv" -ne 0 ]; then # Check if user press Done button
        break
      fi
    done
    # Delete last space
    _dev=$(echo "$_dev"|awk '{$1=$1;print}')
    set_option PV "$_dev"
    # Check if user select CRYPTO_LUKS and not select LVM
    if [ "$_crypto_luks" -eq 1 ] && [ "$_lvm" -eq 0 ]; then
      # Call function set_lvm_luks
      set_lvm_luks
    else
      # Open form dialog
      exec 3>&1
      # Store data to _values variable
      _values=$(dialog --colors --keep-tite --no-shadow --no-mouse --ok-label "Save" \
        --backtitle "${BOLD}${WHITE}BRGV-OS Linux installation -- https://github.com/florintanasa/brgvos-void (@@MKLIVE_VERSION@@)${RESET}" \
        --title "Define some necessary data" \
        --form "Input the names for volume group, logical volume for swap and rootfs, also the size for this" \
        20 60 0 \
        "Volume group name (VG):"             1 1	  "$_vgname" 	      1 34 20 0 \
        "Logical volume name for swap:"       2 1	  "$_lvswap" 	      2 34 20 0 \
        "Logical volume name for rootfs:"     3 1	  "$_lvrootfs" 	    3 34 20 0 \
        "Logical volume name for home:"       4 1	  "$_lvhome" 	      4 34 20 0 \
        "Logical volume name for extra-1:"    5 1	  "$_lvextra_1" 	  5 34 20 0 \
        "Logical volume name for extra-2:"    6 1	  "$_lvextra_2" 	  6 34 20 0 \
        "Size for LVSWAP (GB):"               7 1	  "$_slvswap"   	  7 34  4 0 \
        "Size for LVROOTFS (%):"              8 1	  "$_slvrootfs" 	  8 34  3 0 \
        "Size for LVHOME (%):"                9 1	  "$_slvhome" 	    9 34  3 0 \
        "Size for LVEXTRA-1 (%):"            10 1	  "$_slvextra_1" 	 10 34  3 0 \
        "Size for LVEXTRA-2 (%):"            11 1	  "$_slvextra_2" 	 11 34  3 0 \
      2>&1 1>&3)
      rv=$?
      # Check if the user press Save button
      if [ "$rv" = 0 ] && [ "$_lvm" -eq 1 ]; then
        mapfile -t _map <<< "$_values"
        set_option VGNAME "${_map[0]}"
        set_option LVSWAP "${_map[1]}"
        set_option LVROOTFS "${_map[2]}"
        set_option LVHOME "${_map[3]}"
        set_option LVEXTRA-1 "${_map[4]}"
        set_option LVEXTRA-2 "${_map[5]}"
        set_option SLVSWAP "${_map[6]}"
        set_option SLVROOTFS "${_map[7]}"
        set_option SLVHOME "${_map[8]}"
        set_option SLVEXTRA-1 "${_map[9]}"
        set_option SLVEXTRA-2 "${_map[10]}"
        # Call function set_lvm_luks
        set_lvm_luks
      else
        # If the user press Cancel button then eliminate all values
        set_option VGNAME ""
        set_option LVSWAP ""
        set_option LVROOTFS ""
        set_option LVHOME ""
        set_option LVEXTRA-1 ""
        set_option LVEXTRA-2 ""
        set_option SLVSWAP ""
        set_option SLVROOTFS ""
        set_option SLVHOME ""
        set_option SLVEXTRA-1 ""
        set_option SLVEXTRA-2 ""
      fi
    fi
    # Close form dialog
    exec 3>&-
  fi
  #set_lvm_luks
  LVMLUKS_DONE=1
}

# Function to create lvm and/or luks with loaded parameters from saved configure file
set_lvm_luks() {
  local _pv _vgname _lvm _lvswap _lvrootfs _lvhome _slvswap _slvrootfs _slvhome _crypt _device _crypt_name _index _cd
  local  _devcrypt _FREE_PE _PE_Size _slvrootfs_MB _slvhome_MB _lvextra_1 _lvextra_2 _slvextra_1 _slvextra_2 _slvextra_1_MB _slvextra_2_MB
  # Load variables from configure file if exist else define presets
  _pv=$(get_option PV)
  _lvm=$(get_option LVM)
  _crypt=$(get_option CRYPTO_LUKS)
  _vgname=$(get_option VGNAME)
  _lvswap=$(get_option LVSWAP)
  _lvrootfs=$(get_option LVROOTFS)
  _lvhome=$(get_option LVHOME)
  _lvextra_1=$(get_option LVEXTRA-1)
  _lvextra_2=$(get_option LVEXTRA-2)
  _slvswap=$(get_option SLVSWAP)
  _slvrootfs=$(get_option SLVROOTFS)
  _slvhome=$(get_option SLVHOME)
  _slvextra_1=$(get_option SLVEXTRA-1)
  _slvextra_2=$(get_option SLVEXTRA-2)
  _index=$(get_option INDEX)
  _devcrypt=$(get_option DEVCRYPT)
  _crypts=$(get_option CRYPTS)
  # Check if user choose to encrypt the device
  if [ "$_crypt" = 1 ]; then
      PASSPHRASE=$(get_option USERPASSWORD)
      [ -z "$_index" ] && _index=0  # Initialize an index for unique naming if not exist saved in configure file
      for _device in $_pv; do  # Ensure $_pv contains the correct devices
          {
              TITLE="Starting encryption..."
              echo "$TITLE" >>"$LOG"
              echo -n "$PASSPHRASE" | cryptsetup luksFormat --type=luks1 "$_device" -d - &
              luks_pid=$! # load PID
              # Monitor the process with an infobox
              start_time=$(date +%s)
              while kill -0 "$luks_pid" 2>/dev/null; do
                  current_time=$(date +%s)
                  elapsed=$((current_time - start_time))
                  echo -ne "Encrypting $_device... Time elapsed: $elapsed seconds\033[0K\r" >>"$LOG"
                  INFOBOX "Start encrypting ${BOLD}$_device${RESET} ...\nTime elapsed: ${BOLD}$elapsed${RESET} seconds" 4 80
                  sleep 1
              done
              # Wait for the process to finish
              wait "$luks_pid"
              # Generate a unique name based on the index
              _crypt_name="crypt_${_index}"
              echo -n "$PASSPHRASE" | cryptsetup luksOpen "$_device" "$_crypt_name" -d -
              _cd+="/dev/mapper/$_crypt_name "
              _cd+=" "
              _crypts+="${_crypt_name}"
              _crypts+=" "
              _index=$((_index + 1))  # Increment the index for the next device
          } #>>"$LOG" 2>&1
          _devcrypt+=$(for s in /sys/class/block/$(basename "$(readlink -f /dev/mapper/$_crypt_name)")/slaves/*; do
            echo "/dev/${s##*/}"; done)
          _devcrypt+=" "
      done
      set_option INDEX "$_index" # Save the last unused index for the next set_lvm_luks appellation
      # Delete last space
      _cd=$(echo "$_cd"|awk '{$1=$1;print}')
      # Save the options in configure file
      set_option CRYPTS "${_crypts}"
      set_option DEVCRYPT "${_devcrypt}"
      # Send the message with job done
      echo -e "\nDevice(s) ${_devcrypt} is/are encrypted" >>"$LOG"
  fi
  # Check if user choose to use LVM for devices
  if [ "$_lvm" = 1 ]; then
    {
      # Check if user choose to use LVM without encrypt for devices
      if [ "$_crypt" = 0 ]; then
        set -- $_pv; pvcreate "$@" # Create physical volume
        set -- $_pv; vgcreate "$_vgname" "$@" # Create volume group
      fi
      # Check if user choose to use LVM with encrypt for devices
      if [ "$_crypt" = 1 ]; then
        set -- $_cd; pvcreate "$@" # Create physical volume
        set -- $_cd; vgcreate "$_vgname" "$@" # Create volume group
      fi
      # Create logical volume for extra-1, extra-2, swap, home and rootfs
      if [ "$_slvswap" -gt 0 ]; then # If user enter a size for swap logical volume create this lvswap
        lvcreate --yes --name "$_lvswap" -L "$_slvswap"G "$_vgname"
      fi
      # Calculate some variables needed for _slvextra_2, _slvextra_1, _slvrootfs and _slvhome
      _FREE_PE=$(vgdisplay $_vgname | grep "Free  PE" | awk '{print $5}')
      _PE_Size=$(vgdisplay $_vgname | grep "PE Size" | awk '{print int($3)}')
      echo "_FREE_PE=$_FREE_PE"
      echo "_PE_Size=$_PE_Size"
      _FREE_PE=$((_FREE_PE-2)) # subtract 2 units, it is possible to give an error for 100% (rounded to the whole number)
      if [ "$_slvextra_2" -gt 0 ] ; then # If user enter a size for lvextra-2 logical volume
         # Convert _slvextra_2 from percent to MB
        _slvextra_2_MB=$(((_FREE_PE*_PE_Size*_slvextra_2)/100))
        lvcreate --yes --name "$_lvextra_2" -L "$_slvextra_2_MB"M "$_vgname"
        echo "$_lvextra_2 (MB)=$_slvextra_2_MB"
      fi
      if [ "$_slvextra_1" -gt 0 ] ; then # If user enter a size for lvextra-1 logical volume
         # Convert _slvextra_1 from percent to MB
        _slvextra_1_MB=$(((_FREE_PE*_PE_Size*_slvextra_1)/100))
        lvcreate --yes --name "$_lvextra_1" -L "$_slvextra_1_MB"M "$_vgname"
        echo "$_lvextra_1 (MB)=$_slvextra_1_MB"
      fi
      if [ "$_slvhome" -gt 0 ] ; then # If user enter a size for home logical volume
         # Convert _slvhome from percent to MB
        _slvhome_MB=$(((_FREE_PE*_PE_Size*_slvhome)/100))
        lvcreate --yes --name "$_lvhome" -L "$_slvhome_MB"M "$_vgname"
        echo "$_lvhome (MB)=$_slvhome_MB"
      fi
      if [ "$_slvrootfs" -gt 0 ] && [ "$_slvhome" -eq 0 ] ; then # If user not enter a size for home logical volume make lvrootfs xxx% from Free
        lvcreate --yes --name "$_lvrootfs" -l +"$_slvrootfs"%FREE "$_vgname"
      elif [ "$_slvrootfs" -gt 0 ]; then # If user enter a size for rootfs logical volume create this lvrootfs
        # Convert _slvrootfs from percent to MB
        _slvrootfs_MB=$(((_FREE_PE*_PE_Size*_slvrootfs)/100))
        lvcreate --yes --name "$_lvrootfs" -L "$_slvrootfs_MB"M "$_vgname"
        echo "$_lvrootfs (MB)=$_slvrootfs_MB"
      fi
    } >>"$LOG" 2>&1
  fi
}

# Function for choose partitions for raid software
menu_raid() {
  # Define some local variables
  local _desc _answers _dev _raid rv
  # Description for radiolist box
  _desc="Select what Raid Software you wish to define"
  DIALOG --title "RAID software" --msgbox "\n
${BOLD}${RED}WARNING:\n
When a partition is added to an existing RAID array, the data on that partition is lost because the RAID subsystem
zeroes the device before incorporating it.\n
The ${BLUE}'/boot/efi' ${RED}partition, only for the RAID configuration, has the ${BLUE}'noauto' ${RED}option in
${BLUE}'/etc/fstab'${RED}, so it is not mounted automatically at boot. Mount it manually only when needed (e.g., before
running update, dracut etc.).${RESET}
\n
\n
${BOLD}RAID enhances storage performance, boosts read/write speed, provides data redundancy, enables fault
tolerance, minimizes downtime, and protects against data loss, making systems more reliable and efficient.${RESET}\n
\n
\n
${BOLD}${MAGENTA}RAID ${RED}0 ${YELLOW}(Stripe)${RESET}\n
- Disks/partitions (DP) = minimum 2\n
- Fault tolerance 0\n
- Read speed gain 2x\n
- Write speed gain 2x\n
- Disk space efficiency 100%\n
\n
${BOLD}${MAGENTA}RAID ${RED}1 ${YELLOW}(Mirror)${RESET}\n
- Disks/partitions  2\n
- Fault tolerance 1\n
- Read speed gain 2x\n
- Write speed gain 1x\n
- Disk space efficiency 50%\n
\n
${BOLD}${MAGENTA}RAID ${RED}4 ${YELLOW}(Stripe + Parity)${RESET}\n
- Disks/partitions (DP) = minimum 3\n
- Fault tolerance 1\n
- Read speed gain 2x\n
- Write speed gain 1x\n
- Disk space efficiency > 66%\n
\n
${BOLD}${MAGENTA}RAID ${RED}5 ${YELLOW}(Stripe + Parity)${RESET}\n
- Disks/partitions (DP) = minimum 3\n
- Fault tolerance 1\n
- Read speed gain (DP)x\n
- Write speed gain 1x\n
- Disk space efficiency > 66%\n
\n
${BOLD}${MAGENTA}RAID ${RED}6 ${YELLOW}(Stripe + Double Parity)${RESET}\n
- Disks/partitions (DP) = minimum 4\n
- Fault tolerance 2\n
- Read speed gain (DP)x\n
- Write speed gain 1x\n
- Disk space efficiency >= 50%\n
\n
${BOLD}${MAGENTA}RAID ${RED}10 ${YELLOW}(Striped Mirrors)${RESET}\n
- Disks/partitions (DP) = minimum 4\n
- Fault tolerance 1 to (DP/2)\n
- Read speed gain (DP)x\n
- Write speed gain (DP/2)x\n
- Disk space efficiency 50%\n
\n
${BOLD}${MAGENTA}RAID ${RED}50 ${YELLOW}(Parity + Stripe)${RESET}\n
- Disks/partitions (DP) = minimum 6\n
- Fault tolerance 1 per group\n
- Read speed gain (DP-2)x\n
- Write speed gain 1x\n
- Disk space efficiency > 66%\n
\n
${BOLD}${MAGENTA}RAID ${RED}60 ${YELLOW}(Double Parity + Stripe)${RESET}\n
- Disks/partitions (DP) = minimum 8\n
- Fault tolerance 2 per group\n
- Read speed gain (DP-2)x\n
- Write speed gain 1x\n
- Disk space efficiency 50%\n
" 23 80
  # Verify if the user accept the dialog
  rv=$?
  if [ "$rv" -eq 0 ]; then
    # Create dialog
    DIALOG --no-tags --radiolist "$_desc" 20 60 2 \
      raid0 "RAID 0" on \
      raid1 "RAID 1" off \
      raid4 "RAID 4" off \
      raid5 "RAID 5" off \
      raid6 "RAID 6" off \
      raid10 "RAID 10" off
    # Verify if the user accept the dialog
    rv=$?
    if [ "$rv" -eq 0 ]; then
      _answers=$(cat "$ANSWER")
      if echo "$_answers" | grep -w "raid0"; then
        set_option RAID "0"
      elif echo "$_answers" | grep -w "raid1"; then
        set_option RAID "1"
      elif echo "$_answers" | grep -w "raid4"; then
        set_option RAID "4"
      elif echo "$_answers" | grep -w "raid5"; then
        set_option RAID "5"
      elif echo "$_answers" | grep -w "raid6"; then
        set_option RAID "6"
      elif echo "$_answers" | grep -w "raid10"; then
        set_option RAID "10"
      fi
    elif [ "$rv" -eq 1 ]; then # Verify if the user not accept the dialog
      return
    fi
    # Read selected RAID option
    _raid=$(get_option RAID)
    # Check if the user select RAID
    if [ "$_raid" -ge 0 ]; then
      while true; do
        DIALOG --ok-label "Select" --cancel-label "Done" --extra-button --extra-label "Abort" \
          --title " Select partitions for RAID $_raid" --menu "$MENULABEL" \
          ${MENUSIZE} $(show_partitions_filtered "$_dev")
        rv=$?
        if [ "$rv" = 0 ]; then # Check if user press Select button
          _dev+=$(cat "$ANSWER")
          _dev+=" "
        elif [[ -z "$_dev" ]] || [[ "$rv" -eq 3 ]]; then # Check if user press Abort or Done buttons without selection
          return
        elif [ "$rv" -ne 0 ]; then # Check if user press Done button
          break
        fi
      done
      # Delete last space
      _dev=$(echo "$_dev"|awk '{$1=$1;print}')
      if [[ -n "$_dev" ]]; then\
        set_option RAIDPV "$_dev"
        set_raid
      else
        set_option RAIDPV ""
      fi
    fi
    RAID_DONE=1
  else
    return
  fi
}

#  Function to calculate total capacity, out used on set_raid function
calculate_total_capacity() {
  local -a devs=("$@")
  local total=0 size
  for d in "${devs[@]}"; do
    size=$(blockdev --getsize64 "$d")
    total=$((total + size))
  done
  echo $((total / 1024))          # transform in KB
}

# Function to monitor progress for --write-zeroes
#  $1 – total capacity in KB - calculated by function calculate_total_capacity
#  $2 – device name for RAID (ex: md0)
#  $3 - RAID type (ex: 5)
#  $@ – Devices list
monitor_progress() {
  local total_kb=$1
  local md_name=$2
  local _raid=$3
  shift 3
  local -a devs=("$@")
  # PID of mdadm launch by set_raid function
  local mdadm_pid=$mdadm_pid
  local last_perc=0
  local written=0
  TITLE="Progress for writing zero"
  GAUGE "Start of the process…" 10 70 0 &
  local dlg_pid=$!
  while :; do
    local cur_written=0
    for d in "${devs[@]}"; do
      if [[ -b "$d" ]]; then
        # iostat with -dk, jump the header and take col 7 (KB written)
        local kb
        kb=$(iostat -dk "$d" 1 1 | tail -n +4 | awk '{print $7}' | head -n1)
        [[ -z $kb ]] && kb=0
        cur_written=$((cur_written + kb))
      fi
    done
    written=$cur_written
    # Percent calcul
    local perc=0
    (( total_kb > 0 )) && perc=$((written * 100 / total_kb))
    # Check the RAID status from /proc/mdstat
    local status=$(grep "md${_index}" /proc/mdstat)
    if echo "$status" | grep -q "active"; then
      echo "Complete zeroing!" >> "$LOG"
      perc=100
    fi
    # Refresh gauge dialog only if percentage is changed
    if (( perc != last_perc )); then
      last_perc=$perc
      echo "$perc" | GAUGE "RAID $_raid: $md_name\nTotal capacity to write zero: ${total_kb}KB\nWritten: ${written}KB" 10 70
    fi

    # Out from function when the mdadm command is closed
    if ! ps -p $mdadm_pid > /dev/null; then
      echo "The mdadm command is finished." >> "$LOG"
      break
    fi
    # Wait 1s
    sleep 1
  done
  # Kill dialog using PID at the final
  kill "$dlg_pid" 2>/dev/null
}

# Function to create raid software with loaded parameters from saved configure file
set_raid() {
  # Define some local variables
  local _raid _raidpv _raidnbdev _mdadm _hostname _index _raid_uuid
  # Load variables from configure file if exist else define presets
  _raid=$(get_option RAID)
  _raidpv=$(get_option RAIDPV)
  _hostname=$(get_option HOSTNAME)
  _index=$(get_option INDEXRAID)
  # Add config file for dracut if not exist
  if [ ! -f /etc/dracut.conf.d/md.conf ]; then
    echo "mdadmconf=\"yes\"" > /etc/dracut.conf.d/md.conf
  fi
  # Check if the user choose an option for raid software and physically partitions for the raid
  if [ -n "$_raid" ] && [ -n "$_raidpv" ]; then
    [ -z "$_index" ] && _index=0  # Initialize an index for unique naming raid block if not exist saved in configure file
    _raidnbdev=$(wc -w <<< "$_raidpv") # count numbers of partitions
    echo "Create RAID $_raid for $_raidpv" >>"$LOG"
    {
      if [ "$_raid" -eq 0 ]; then
        if echo "$_raidpv" | grep -q md; then # Check if used a raid, if yes do not write zero again
          set -- $_raidpv; mdadm --create --verbose /dev/md${_index} --level=0 --homehost="$_hostname" \
            --raid-devices="$_raidnbdev" "$@"
        else
          set -- $_raidpv;
          mdadm --create --verbose /dev/md${_index} --level=0 --write-zeroes --homehost="$_hostname" \
                --raid-devices="$_raidnbdev" "$@" &> /dev/null &
          mdadm_pid=$!
          set -- $_raidpv;
          # Call the function calculate_total_capacity with parameters (list of partitions) and assign the result
          total_kb=$(calculate_total_capacity "$@")
          set -- $_raidpv;
          # Call the function with parameters
          monitor_progress "$total_kb" "md${_index}" "$_raid" "$@"
        fi
      elif [ "$_raid" -eq 1 ]; then
        set -- $_raidpv;
        #mdadm --create --verbose /dev/md${_index} --level=1 --write-zeroes --homehost="$_hostname" \
        #--bitmap='internal' --metadata=1.2 --raid-devices="$_raidnbdev" "$@"
        mdadm --create --verbose /dev/md${_index} --level=1 --write-zeroes --homehost="$_hostname" \
          --bitmap='internal' --metadata=1.2 --raid-devices="$_raidnbdev" "$@" &> /dev/null &
        mdadm_pid=$!
        set -- $_raidpv;
        # Call the function calculate_total_capacity with parameters (list of partitions) and assign the result
        total_kb=$(calculate_total_capacity "$@")
        set -- $_raidpv;
        # Call the function with parameters
        monitor_progress "$total_kb" "md${_index}" "$_raid" "$@"
      elif [ "$_raid" -eq 4 ]; then
        set -- $_raidpv;
        #mdadm --create --verbose /dev/md${_index} --level=4 --write-zeroes --homehost="$_hostname" \
        #--bitmap='internal' --raid-devices="$_raidnbdev" "$@"
        mdadm --create --verbose /dev/md${_index} --level=4 --write-zeroes --homehost="$_hostname" \
          --bitmap='internal' --raid-devices="$_raidnbdev" "$@" &> /dev/null &
        mdadm_pid=$!
        set -- $_raidpv;
        # Call the function calculate_total_capacity with parameters (list of partitions) and assign the result
        total_kb=$(calculate_total_capacity "$@")
        set -- $_raidpv;
        # Call the function with parameters
        monitor_progress "$total_kb" "md${_index}" "$_raid" "$@"
      elif [ "$_raid" -eq 5 ]; then
        set -- $_raidpv;
        #mdadm --create --verbose /dev/md${_index} --level=5 --write-zeroes --homehost="$_hostname" \
        #--bitmap='internal' --raid-devices="$_raidnbdev" "$@"
        mdadm --create --verbose /dev/md${_index} --level=5 --write-zeroes --homehost="$_hostname" \
          --bitmap='internal' --raid-devices="$_raidnbdev" "$@" &> /dev/null &
        mdadm_pid=$!
        set -- $_raidpv;
        # Call the function calculate_total_capacity with parameters (list of partitions) and assign the result
        total_kb=$(calculate_total_capacity "$@")
        set -- $_raidpv;
        # Call the function with parameters
        monitor_progress "$total_kb" "md${_index}" "$_raid" "$@"
      elif [ "$_raid" -eq 6 ]; then
        set -- $_raidpv;
        #mdadm --create --verbose /dev/md${_index} --level=6 --write-zeroes --homehost="$_hostname" \
        #--bitmap='internal' --raid-devices="$_raidnbdev" "$@"
        mdadm --create --verbose /dev/md${_index} --level=6 --write-zeroes --homehost="$_hostname" \
          --bitmap='internal' --raid-devices="$_raidnbdev" "$@" &> /dev/null &
        mdadm_pid=$!
        set -- $_raidpv;
        # Call the function calculate_total_capacity with parameters (list of partitions) and assign the result
        total_kb=$(calculate_total_capacity "$@")
        set -- $_raidpv;
        # Call the function with parameters
        monitor_progress "$total_kb" "md${_index}" "$_raid" "$@"
      elif [ "$_raid" -eq 10 ]; then
        set -- $_raidpv;
        #mdadm --create --verbose /dev/md${_index} --level=10 --write-zeroes --homehost="$_hostname" \
        #--bitmap='internal' --raid-devices="$_raidnbdev" "$@"
        mdadm --create --verbose /dev/md${_index} --level=10 --write-zeroes --homehost="$_hostname" \
          --bitmap='internal' --raid-devices="$_raidnbdev" "$@" &> /dev/null &
        mdadm_pid=$!
        set -- $_raidpv;
        # Call the function calculate_total_capacity with parameters (list of partitions) and assign the result
        total_kb=$(calculate_total_capacity "$@")
        set -- $_raidpv;
        # Call the function with parameters
        monitor_progress "$total_kb" "md${_index}" "$_raid" "$@"
      fi
    } #>>"$LOG" 2>&1
    # Prepare config file /etc/mdadm.conf
    _mdadm=$(mdadm --detail --scan)
    echo "$_mdadm" > /etc/mdadm.conf
    # Prepare variable used in grub for kernel command line
    _raid_uuid=$(sudo mdadm --detail /dev/md${_index} | grep UUID | awk '{print $NF}') # Got UUID for RAID block
    RD_MD_UUID+="rd.md.uuid=$_raid_uuid " # Global variable used in set_boot function
    _index=$((_index + 1))  # Increment the index for the next raid block
    set_option INDEXRAID "$_index" # save in configure file the last unused index to be used for next set_raid appellation
  fi
}

# Function for chose partition tool for modify partition table
menu_partitions() {
  DIALOG --title " Select the disk to partition " \
    --menu "$MENULABEL" ${MENUSIZE} $(show_disks)
  if [ $? -eq 0 ]; then
    local device=$(cat $ANSWER)

    DIALOG --title " Select the software for partitioning " \
      --menu "$MENULABEL" ${MENUSIZE} \
      "cfdisk" "Easy to use" \
      "fdisk" "More advanced"
    if [ $? -eq 0 ]; then
      local software=$(cat $ANSWER)

      DIALOG --title "Modify Partition Table on $device" --msgbox "\n
${BOLD}${MAGENTA}${software}${RESET} ${BOLD}will be executed in disk $device.${RESET}\n
\n
If exist old ${BOLD}${BLUE}'LUKS'${RESET} or ${BOLD}${BLUE}'LVM'${RESET} signatures please use \
${BOLD}${MAGENTA}'fdisk'${RESET} because ${BOLD}${MAGENTA}'cfdisk'${RESET} not delete this signatures.\n
\n
For BIOS systems, MBR or GPT partition tables are supported. To use GPT on PC BIOS systems, an empty partition of 1MB \
must be added at the first 2GB of the disk with the partition type ${BOLD}${BLUE}'BIOS Boot'${RESET}.\n
${BOLD}${GREEN}NOTE: you don't need this on EFI systems.${RESET}\n
\n
For EFI systems, GPT is mandatory and a FAT32 partition with at least 100MB must be created with the partition type \
${BOLD}${BLUE}'EFI System'${RESET}. This will be used as the EFI System Partition. For this partition is necessary to \
have the mounting point in ${BOLD}${BLUE}'/boot/efi'${RESET}.\n
\n
At least 1 partition is required for the rootfs (/). For this partition,at least 12GB is required, but more is \
recommended. The rootfs partition should have the partition type ${BOLD}${BLUE}'Linux Filesystem'${RESET}. For swap, \
RAM*2 should be enough and the partition type ${BOLD}${BLUE}'Linux swap'${RESET} should be used.\n
\n
${BOLD}${RED}WARNING: /usr is not supported as a separate partition.${RESET}\n
\n
${BOLD}${GREEN}INFO: If you have in plan to use ${BOLD}${BLUE}'LVM'${RESET} ${BOLD}${GREEN}is not necessary to create \
separated partition for ${BOLD}${BLUE}'Linux swap'${RESET}. ${BOLD}${GREEN}You can create a${RESET} \
${BOLD}${BLUE}'swap'${RESET} ${BOLD}${GREEN}logical volume in${RESET} ${BOLD}${BLUE}'LVM'${RESET} \
${BOLD}${GREEN}options in next menu${RESET} ${BOLD}${BLUE}'LVM&LUKS'${RESET}${BOLD}${GREEN}.${RESET}\n
\n
${BOLD}${RED}WARNING: After you save something in ${BOLD}${MAGENTA}${software}${RESET} \
${BOLD}${RED}the partition table is modify. KEEP ATTENTION!!!${RESET}\n" 23 80
      if [ $? -eq 0 ]; then
        while true; do
          clear; $software $device; PARTITIONS_DONE=1
          break
        done
      else
        return
      fi
    fi
  fi
}

menu_keymap() {
  local _keymaps="$(find /usr/share/kbd/keymaps/ -type f -iname "*.map.gz" -printf "%f\n" | sed 's|.map.gz||g' | sort)"
  local _KEYMAPS=

  for f in ${_keymaps}; do
    _KEYMAPS="${_KEYMAPS} ${f} -"
  done
  while true; do
    DIALOG --title " Select your keymap " --menu "$MENULABEL" 14 70 14 ${_KEYMAPS}
    if [ $? -eq 0 ]; then
      set_option KEYMAP "$(cat $ANSWER)"
      loadkeys "$(cat $ANSWER)"
      KEYBOARD_DONE=1
      break
    else
      return
    fi
  done
}

# Function to set keymap from loaded saved configure file
set_keymap() {
  local KEYMAP=$(get_option KEYMAP)

  if [ -f /etc/vconsole.conf ]; then
    sed -i -e "s|KEYMAP=.*|KEYMAP=$KEYMAP|g" $TARGETDIR/etc/vconsole.conf
  else
    sed -i -e "s|#\?KEYMAP=.*|KEYMAP=$KEYMAP|g" $TARGETDIR/etc/rc.conf
  fi
}

# Function for chose and set locale
menu_locale() {
  local _locales="$(grep -E '\.UTF-8' /etc/default/libc-locales|awk '{print $1}'|sed -e 's/^#//')"
  local LOCALES ISO639 ISO3166
  local TMPFILE=$(mktemp -t vinstall-XXXXXXXX || exit 1)
  INFOBOX "Scanning locales ..." 4 60
  for f in ${_locales}; do
    eval $(echo $f | awk 'BEGIN { FS="." } \
            { FS="_"; split($1, a); printf "ISO639=%s ISO3166=%s\n", a[1], a[2] }')
    echo "$f|$(iso639_language $ISO639) ($(iso3166_country $ISO3166))|" >> $TMPFILE
  done
  clear
  # Sort by ISO-639 language names
  LOCALES=$(sort -t '|' -k 2 < $TMPFILE | xargs | sed -e's/| /|/g')
  rm -f $TMPFILE
  while true; do
    (IFS="|"; DIALOG --title " Select your locale " --menu "$MENULABEL" 18 70 18 ${LOCALES})
    if [ $? -eq 0 ]; then
      set_option LOCALE "$(cat $ANSWER)"
      LOCALE_DONE=1
      break
    else
      return
    fi
  done
}

# Function to set locale from loaded saved configure file
set_locale() {
  if [ -f $TARGETDIR/etc/default/libc-locales ]; then
    local LOCALE="$(get_option LOCALE)"
    : "${LOCALE:=C.UTF-8}"
    sed -i -e "s|LANG=.*|LANG=$LOCALE|g" $TARGETDIR/etc/locale.conf
    # Uncomment locale from /etc/default/libc-locales and regenerate it.
    sed -e "/${LOCALE}/s/^\#//" -i $TARGETDIR/etc/default/libc-locales
    echo "Running xbps-reconfigure -f glibc-locales ..." >>$LOG
    chroot $TARGETDIR xbps-reconfigure -f glibc-locales >>$LOG 2>&1
  fi
}

# Function to chose and set timezone
menu_timezone() {
  local areas=(Africa America Antarctica Arctic Asia Atlantic Australia Europe Indian Pacific)

  local area locations location
  while (IFS='|'; DIALOG ${area:+--default-item|"$area"} --title " Select area " --menu "$MENULABEL" 19 51 19 $(printf '%s||' "${areas[@]}")); do
    area=$(cat $ANSWER)
    read -a locations -d '\n' < <(find /usr/share/zoneinfo/$area -type f -printf '%P\n' | sort)
    if (IFS='|'; DIALOG --title " Select location (${area}) " --menu "$MENULABEL" 19 51 19 $(printf '%s||' "${locations[@]//_/ }")); then
      location=$(tr ' ' '_' < $ANSWER)
      set_option TIMEZONE "$area/$location"
      TIMEZONE_DONE=1
      return 0
    else
      continue
    fi
  done
  return 1
}

# Function to set timezone from loaded saved configure file
set_timezone() {
  local TIMEZONE="$(get_option TIMEZONE)"

  ln -sf "/usr/share/zoneinfo/${TIMEZONE}" "${TARGETDIR}/etc/localtime"
}

# Function to set hostname
menu_hostname() {
  while true; do
    DIALOG --inputbox "Set the machine hostname:" ${INPUTSIZE}
    if [ $? -eq 0 ]; then
      set_option HOSTNAME "$(cat $ANSWER)"
      HOSTNAME_DONE=1
      break
    else
      return
    fi
  done
}

# Function to set hostname from loaded saved configure file
set_hostname() {
  local hostname="$(get_option HOSTNAME)"
  echo "${hostname:-void}" > $TARGETDIR/etc/hostname
}

# Function to set password for root
menu_rootpassword() {
  local _firstpass _secondpass _again _desc

  while true; do
    if [ -z "${_firstpass}" ]; then
      _desc="Enter the root password"
    else
      _again=" again"
    fi
    DIALOG --insecure --passwordbox "${_desc}${_again}" ${INPUTSIZE}
    if [ $? -eq 0 ]; then
      if [ -z "${_firstpass}" ]; then
        _firstpass="$(cat $ANSWER)"
      else
        _secondpass="$(cat $ANSWER)"
      fi
      if [ -n "${_firstpass}" -a -n "${_secondpass}" ]; then
        if [ "${_firstpass}" != "${_secondpass}" ]; then
          INFOBOX "${RED}ERROR:${RESET}Passwords do not match! Please enter again." 6 60
          unset _firstpass _secondpass _again
          sleep 2 && clear && continue
        fi
        set_option ROOTPASSWORD "${_firstpass}"
        ROOTPASSWORD_DONE=1
        break
      fi
    else
      return
    fi
  done
}

# Function to set password for root from loaded saved configure file
set_rootpassword() {
  echo "root:$(get_option ROOTPASSWORD)" | chroot $TARGETDIR chpasswd -c SHA512
}

# Function to set user account
menu_useraccount() {
  # Define some local variables
  local _firstpass _secondpass _desc _again
  local _groups _status _group _checklist
  local _preset _userlogin _audit

  while true; do
    _preset=$(get_option USERLOGIN)
    [ -z "$_preset" ] && _preset="brgvos"
    DIALOG --inputbox "Enter a primary login name:" ${INPUTSIZE} "$_preset"
    if [ $? -eq 0 ]; then
      _userlogin="$(cat $ANSWER)"
      # based on useradd(8) § Caveats
      if [ "${#_userlogin}" -le 32 ] && [[ "${_userlogin}" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
        set_option USERLOGIN "${_userlogin}"
        USERLOGIN_DONE=1
        break
      else
        INFOBOX "${RED}ERROR:${RESET}Invalid login name! Please try again." 6 60
        unset _userlogin
        sleep 2 && clear && continue
      fi
    else
      return
    fi
  done

  while true; do
    _preset=$(get_option USERNAME)
    [ -z "$_preset" ] && _preset="User Name"
    DIALOG --inputbox "Enter a display name for login '$(get_option USERLOGIN)' :" \
      ${INPUTSIZE} "$_preset"
    if [ $? -eq 0 ]; then
      set_option USERNAME "$(cat $ANSWER)"
      USERNAME_DONE=1
      break
    else
      return
    fi
  done

  while true; do
    if [ -z "${_firstpass}" ]; then
      _desc="Enter the password for login '$(get_option USERLOGIN)'"
    else
      _again=" again"
    fi
    DIALOG --insecure --passwordbox "${_desc}${_again}" ${INPUTSIZE}
    if [ $? -eq 0 ]; then
      if [ -z "${_firstpass}" ]; then
        _firstpass="$(cat $ANSWER)"
      else
        _secondpass="$(cat $ANSWER)"
      fi
      if [ -n "${_firstpass}" -a -n "${_secondpass}" ]; then
        if [ "${_firstpass}" != "${_secondpass}" ]; then
          INFOBOX "${RED}ERROR:${RESET}Passwords do not match! Please enter again." 6 60
          unset _firstpass _secondpass _again
          sleep 2 && clear && continue
        fi
        set_option USERPASSWORD "${_firstpass}"
        USERPASSWORD_DONE=1
        break
      fi
    else
      return
    fi
  done
  SOURCE_DONE="$(get_option SOURCE)"
  _audit=$(get_option AUDIT)
  # If source not set use defaults.
  if [ "$(get_option SOURCE)" = "local" ] || [ -z "$SOURCE_DONE" ]; then # check if user request local installation
    if [ -n "$_audit" ] && [ "$_audit" -eq 1 ]; then # check if user request to setting audit
      _groups="wheel,audio,video,floppy,lp,dialout,cdrom,optical,storage,scanner,kvm,plugdev,users,socklog,lpadmin,bluetooth,xbuilder,audit"
    else
      _groups="wheel,audio,video,floppy,lp,dialout,cdrom,optical,storage,scanner,kvm,plugdev,users,socklog,lpadmin,bluetooth,xbuilder"
    fi
  else # if not request local installation remain network install
    if [ -n "$_audit" ] && [ "$_audit" -eq 1 ]; then # check if user request to setting audit for network install
      _groups="wheel,audio,video,floppy,cdrom,optical,kvm,users,xbuilder,audit"
    else
      _groups="wheel,audio,video,floppy,cdrom,optical,kvm,users,xbuilder"
    fi
  fi
  while true; do
    _desc="Select group membership for login '$(get_option USERLOGIN)':"
    for _group in $(cat /etc/group); do
      _gid="$(echo ${_group} | cut -d: -f3)"
      _group="$(echo ${_group} | cut -d: -f1)"
      _status="$(echo ${_groups} | grep -w ${_group})"
      if [ -z "${_status}" ]; then
        _status=off
      else
        _status=on
      fi
      # ignore the groups of root, existing users, and package groups
      if [[ "${_gid}" -ge 1000 || "${_group}" = "_"* || "${_group}" =~ ^(root|nogroup|chrony|dbus|lightdm|polkitd)$ ]]; then
        continue
      fi
      if [ -z "${_checklist}" ]; then
        _checklist="${_group} ${_group}:${_gid} ${_status}"
      else
        _checklist="${_checklist} ${_group} ${_group}:${_gid} ${_status}"
      fi
    done
    DIALOG --no-tags --checklist "${_desc}" 20 60 18 ${_checklist}
    if [ $? -eq 0 ]; then
      set_option USERGROUPS $(cat $ANSWER | sed -e's| |,|g')
      USERGROUPS_DONE=1
      break
    else
      return
    fi
  done
}

# Function to set user account from loaded saved configure file
set_useraccount() {
  [ -z "$USERACCOUNT_DONE" ] && return
  if [ "$(get_option SOURCE)" = "net" ] && [ "$(get_option AUDIT)" -eq 1 ]; then
    chroot "$TARGETDIR" groupadd -r audit
    chroot "$TARGETDIR" sed -i 's/log_group = root/log_group = audit/g' /etc/audit/auditd.conf
    chroot "$TARGETDIR" sed -i 's/d \/var\/log\/audit 0700 root root - -/d \/var\/log\/audit 0750 root audit - -/g'  /usr/lib/tmpfiles.d/audit.conf
  fi
  chroot "$TARGETDIR" useradd -m -G "$(get_option USERGROUPS)" \
    -c "$(get_option USERNAME)" "$(get_option USERLOGIN)"
  echo "$(get_option USERLOGIN):$(get_option USERPASSWORD)" | \
    chroot "$TARGETDIR" chpasswd -c SHA512
}

# Function to choose bootloader
menu_bootloader() {
  while true; do
    DIALOG --title " Select the disk to install the bootloader" \
      --menu "$MENULABEL" ${MENUSIZE} $(show_disks) none "Manage bootloader otherwise"
    if [ $? -eq 0 ]; then
      set_option BOOTLOADER "$(cat $ANSWER)"
      BOOTLOADER_DONE=1
      break
    else
      return
    fi
  done
  while true; do
    DIALOG --yesno "Use a graphical terminal for the boot loader?" ${YESNOSIZE}
    if [ $? -eq 0 ]; then
      set_option TEXTCONSOLE 0
      break
    elif [ $? -eq 1 ]; then
      set_option TEXTCONSOLE 1
      break
    else
      return
    fi
  done
}

# Function to set bootloader from loaded saved configure file
set_bootloader() {
  # Declare some local variables
  local dev _encrypt _rootfs _bool bool index _boot _rd_luks_uuid _crypts _apparmor _audit _hardening _firewall
  local -a luks_devices # Declare matrices
  # Initialise variables
  dev=$(get_option BOOTLOADER)
  _crypts=$(get_option CRYPTS)
  _apparmor=$(get_option APPARMOR)
  _firewall=$(get_option FIREWALL)
  _audit=$(get_option AUDIT)
  _hardening=$(get_option HARDENING)
  grub_args=
  bool=0
  _bool=0
  index=0 # Init index
  # Check if is defined mount device for /boot
  [ -n "$(grep -E '/boot .*' /tmp/.brgvos-installer.conf)" ] && _boot=1 || _boot=0
  # Check if user choose an option in witch device bootloader to be installed, if not chose return
  if [ "$dev" = "none" ]; then return; fi
  # Check if it's an EFI system via efivars module.
  if [ -n "$EFI_SYSTEM" ]; then
    grub_args="--target=$EFI_TARGET --efi-directory=/boot/efi --bootloader-id=brgvos_grub --recheck"
  fi
  echo "Check if root file system have minimum one device encrypt" >>$LOG
  for _rootfs in $ROOTFS; do
    if cryptsetup isLuks "$_rootfs"; then
      _bool=1
    fi
    # Add detected encrypted device to the matrices luks_devices
    if [ "$_bool" -eq 1 ];then
      bool=1
      echo "Detected crypted device on ${bold}$_rootfs${reset}"  >>$LOG
      luks_devices+=("$_rootfs")
    fi
  done
  _crypts=$(echo "$_crypts"|awk '{$1=$1;print}') # Delete last space
  # If exist encrypted device prepare the files needed for boot with Passphrase on initramfs
  if [ "$bool" -eq 1 ] && [ "$_boot" -eq 0 ]; then # We choose full encrypted without specific mount point for /boot dev
    echo "Prepare /boot/cryptlvm.key, /etc/crypttab and /etc/dracut.conf.d/10-crypt.conf for full encrypted" >>$LOG
    # Create cryptlvm.key file to store Passphrase
    chroot $TARGETDIR dd bs=512 count=4 if=/dev/urandom of=/boot/cryptlvm.key >>$LOG 2>&1
    # Add for every device encrypted a record in /etc/crypttab and Passphrase in cryptlvm.key
    for _encrypt in $_crypts; do
      CRYPT_UUID=$(blkid -s UUID -o value "${luks_devices[index]}") # Got UUID for _encrypt device
      echo "I founded encrypted $_encrypt from device ${luks_devices[index]} with UUID $CRYPT_UUID" >>$LOG
      awk 'BEGIN{print "'"$_encrypt"' UUID='"$CRYPT_UUID"' /boot/cryptlvm.key luks"}' >> $TARGETDIR/etc/crypttab
      echo "Add Passphrase for ${bold}${luks_devices[index]}${reset}" >>$LOG
      echo -n "$PASSPHRASE" | cryptsetup luksAddKey "${luks_devices[index]}" $TARGETDIR/boot/cryptlvm.key >>$LOG 2>&1
      _rd_luks_uuid+="rd.luks.uuid=$CRYPT_UUID "
      ((index++))  # Increment index
    done
    # Change permission to only root to rw for cryptlvm.key
    chroot $TARGETDIR chmod 0600 /boot/cryptlvm.key >>$LOG 2>&1
    # Create file 10-crypt.conf is a config for dracut
    chroot $TARGETDIR touch /etc/dracut.conf.d/10-crypt.conf >>$LOG 2>&1
    # Add in file 10-crypt.conf information necessary for dracut
    awk 'BEGIN{print "install_items+=\" /boot/cryptlvm.key /etc/crypttab \""}' >> $TARGETDIR/etc/dracut.conf.d/10-crypt.conf
    echo "Generate again initramfs because was created a key for open crypted device(s) ${bold}$ROOTFS${reset}" >>$LOG
    if [ "$(get_option SOURCE)" = "local" ]; then
      chroot $TARGETDIR dracut --no-hostonly --force >>$LOG 2>&1
    else # for source = net dracut call directly not work but work xbps-reconfigure
      chroot $TARGETDIR xbps-reconfigure -fa >>LOG 2>&1
    fi
    echo "Enable crypto disk option in grub config" >>$LOG
    chroot $TARGETDIR sed -i '$aGRUB_ENABLE_CRYPTODISK=y' /etc/default/grub >>$LOG 2>&1
  elif  [ "$bool" -eq 1 ] && [ "$_boot" -eq 1 ]; then # We choose full encrypted with specific mount point for /boot dev
    echo "Prepare /etc/crypttab and /etc/dracut.conf.d/10-crypt.conf for not full encrypted" >>$LOG
    for _encrypt in $_crypts; do
      CRYPT_UUID=$(blkid -s UUID -o value "${luks_devices[index]}") # Got UUID for _encrypt device
      echo "I founded encrypted $_encrypt from device ${luks_devices[index]} with UUID $CRYPT_UUID" >>$LOG
      awk 'BEGIN{print "'"$_encrypt"' UUID='"$CRYPT_UUID"' none luks"}' >> $TARGETDIR/etc/crypttab
      _rd_luks_uuid+="rd.luks.uuid=$CRYPT_UUID "
      ((index++))  # Increment index
    done
    # Create file 10-crypt.conf is a config for dracut
    chroot $TARGETDIR touch /etc/dracut.conf.d/10-crypt.conf >>$LOG 2>&1
    # Add in file 10-crypt.conf information necessary for dracut
    awk 'BEGIN{print "install_items+=\" /etc/crypttab \""}' >> $TARGETDIR/etc/dracut.conf.d/10-crypt.conf
    echo "Generate again initramfs because was created a config file on dracut for crypted device(s) ${bold}$ROOTFS${reset}" >>$LOG
    if [ "$(get_option SOURCE)" = "local" ]; then
      chroot $TARGETDIR dracut --no-hostonly --force >>$LOG 2>&1
    else # for source = net dracut call directly not work but work xbps-reconfigure
      chroot $TARGETDIR xbps-reconfigure -fa >>LOG 2>&1
    fi
  else
    echo "Type of installation is not encrypted"  >>$LOG
  fi
  # Install the Grub and if not have success inform the user with a message dialog
  echo "Running ${bold}grub-install $grub_args $dev${reset}..." >>$LOG
  chroot $TARGETDIR grub-install $grub_args $dev >>$LOG 2>&1
  if [ $? -ne 0 ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
    failed to install GRUB to ${BOLD}$dev${RESET}!\nCheck $LOG for errors." ${MSGBOXSIZE}
    DIE 1
  fi
  echo "Preparing the Logo and name in the grub menu ${bold}$TARGETDIR/etc/default/grub${reset}..." >>$LOG
  # Copy file splash.png on /boot/grub/background to can see by the grub when we install on encrypted rootfs
  chroot $TARGETDIR mkdir -p /boot/grub/background >> $LOG 2>&1
  chroot $TARGETDIR cp /usr/share/brgvos-artwork/splash.png /boot/grub/background/ >> $LOG 2>&1
  chroot $TARGETDIR sed -i 's+#GRUB_BACKGROUND=/usr/share/void-artwork/splash.png+GRUB_BACKGROUND=/boot/grub/background/splash.png+g' /etc/default/grub >>$LOG 2>&1
  chroot $TARGETDIR sed -i 's/GRUB_DISTRIBUTOR="Void"/GRUB_DISTRIBUTOR="BRGV-OS"/g' /etc/default/grub >>$LOG 2>&1
  if [ "$bool" -eq 1 ] && [ "$_boot" -eq 0 ]; then # For full encrypted installation
    echo "Prepare parameters on Grub for crypted device(s) ${bold}${luks_devices[*]}${reset}"  >>$LOG
    chroot $TARGETDIR sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=4\"/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=4 ${RD_MD_UUID} ${_rd_luks_uuid} cryptkey=rootfs:\/boot\/cryptlvm.key quiet splash\"/g" /etc/default/grub >>$LOG 2>&1
  else # For not full encrypted installation
    echo "Prepare parameters on Grub for device ${bold}$ROOTFS${reset}"  >>$LOG
    chroot $TARGETDIR sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=4\"/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=4 ${RD_MD_UUID} ${_rd_luks_uuid} quiet splash\"/g" /etc/default/grub >>$LOG 2>&1
  fi
  chroot $TARGETDIR sed -i '$aGRUB_DISABLE_OS_PROBER=false' /etc/default/grub >>$LOG 2>&1
  # Check if the user set to use AppArmor
  if [ -n "$_apparmor" ] && [ "$_apparmor" -eq 1 ]; then # If yes, enable AppArmor in kernel parameters to be loaded in Enforce mode
    echo "Security AppArmor was set to be loaded by kernel in Enforce mode..." >>$LOG
    {
      chroot $TARGETDIR sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 apparmor=1 security=apparmor lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/' /etc/default/grub
      chroot $TARGETDIR sed -i 's/APPARMOR=complain/APPARMOR=enforce/g' /etc/default/apparmor
    } >>$LOG 2>&1
  fi
  # Check if the user set to use Firewall Manager(vuurmuur)
  if [ -n "$_firewall" ] && [ "$_firewall" -eq 1 ]; then
    echo "Prepare Firewall Manager - vuurmuur ..." >>$LOG
    set_firewall
  fi
  # Check if the user set to use Audit
  if [ -n "$_audit" ] && [ "$_audit" -eq 1 ]; then
    echo "Create group audit, add the user to this group and change owner group to audit..." >>$LOG
    set_audit
    echo "Set audit=1 as parameters to be loaded by kernel at boot" >>$LOG
    chroot $TARGETDIR sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 audit=1"/' /etc/default/grub >>$LOG 2>&1
  fi
  # Check if the user set to use Hardening(sysctl)
  if [ -n "$_hardening" ] && [ "$_hardening" -eq 1 ]; then
    echo "Move file 99-myconfig.conf in /etc/sysctl.d ..." >>$LOG
    set_hardening
  fi
  echo "Running grub-mkconfig on ${bold}$TARGETDIR${reset}..." >>"$LOG"
  chroot $TARGETDIR grub-mkconfig -o /boot/grub/grub.cfg >>$LOG 2>&1
  # Build the Grub configure file and if not have success inform the user with a message dialog and exit from installer
  if [ $? -ne 0 ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR${RESET}: \
    failed to run grub-mkconfig!\nCheck $LOG for errors." ${MSGBOXSIZE}
    DIE 1
  fi
}

# Function to test network connection
test_network() {
  # Reset the global variable to ensure that network is accessible for this test.
  NETWORK_DONE=

  rm -f otime && \
    xbps-uhelper fetch https://repo-default.voidlinux.org/current/otime >>$LOG 2>&1
  local status=$?
  rm -f otime

  if [ "$status" -eq 0 ]; then
    DIALOG --msgbox "Network is working properly!" ${MSGBOXSIZE}
    NETWORK_DONE=1
    return 1
  fi
  if [ "$1" = "nm" ]; then
    DIALOG --msgbox "Network Manager is enabled but network is inaccessible, please set it up externally with nmcli, nmtui, or the Network Manager tray applet." ${MSGBOXSIZE}
  else
    DIALOG --msgbox "Network is inaccessible, please set it up properly." ${MSGBOXSIZE}
  fi
}

# Function to configure Wi-Fi network
configure_wifi() {
  local dev="$1" ssid enc pass _wpasupconf=/etc/wpa_supplicant/wpa_supplicant.conf

  DIALOG --form "Wireless configuration for ${dev}\n(encryption type: wep or wpa)" 0 0 0 \
    "SSID:" 1 1 "" 1 16 30 0 \
    "Encryption:" 2 1 "" 2 16 4 3 \
    "Password:" 3 1 "" 3 16 63 0 || return 1
  readarray -t values <<<$(cat $ANSWER)
  ssid="${values[0]}"; enc="${values[1]}"; pass="${values[2]}"

  if [ -z "$ssid" ]; then
    DIALOG --msgbox "Invalid SSID." ${MSGBOXSIZE}
    return 1
  elif [ -z "$enc" -o "$enc" != "wep" -a "$enc" != "wpa" ]; then
    DIALOG --msgbox "Invalid encryption type (possible values: wep or wpa)." ${MSGBOXSIZE}
    return 1
  elif [ -z "$pass" ]; then
    DIALOG --msgbox "Invalid AP password." ${MSGBOXSIZE}
  fi

  # reset the configuration to the default, if necessary
  # otherwise backup the configuration
  if [ -f ${_wpasupconf}.orig ]; then
    cp -f ${_wpasupconf}.orig ${_wpasupconf}
  else
    cp -f ${_wpasupconf} ${_wpasupconf}.orig
  fi
  if [ "$enc" = "wep" ]; then
    cat << EOF >> ${_wpasupconf}
network={
  ssid="$ssid"
  wep_key0="$pass"
  wep_tx_keyidx=0
  auth_alg=SHARED
}
EOF
  else
    wpa_passphrase "$ssid" "$pass" >> ${_wpasupconf}
  fi

  sv restart wpa_supplicant
  configure_net_dhcp $dev
  return $?
}

# Function to configure network
configure_net() {
  local dev="$1" rval

  DIALOG --yesno "Do you want to use DHCP for $dev?" ${YESNOSIZE}
  rval=$?
  if [ $rval -eq 0 ]; then
    configure_net_dhcp $dev
  elif [ $rval -eq 1 ]; then
    configure_net_static $dev
  fi
}

# Function return interface setup
iface_setup() {
  ip addr show dev $1 | grep -q -e 'inet ' -e 'inet6 '
  return $?
}

# Function configure interface for dhcpcd service
configure_net_dhcp() {
  local dev="$1"

  iface_setup $dev
  if [ $? -eq 1 ]; then
    sv restart dhcpcd 2>&1 | tee $LOG | \
      DIALOG --progressbox "Initializing $dev via DHCP..." ${WIDGET_SIZE}
    if [ $? -ne 0 ]; then
      DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} failed to run dhcpcd. See $LOG for details." ${MSGBOXSIZE}
      return 1
    fi
    export -f iface_setup
    timeout 10s bash -c "while true; do iface_setup $dev; sleep 0.25; done"
    if [ $? -eq 1 ]; then
      DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} DHCP request failed for $dev. Check $LOG for errors." ${MSGBOXSIZE}
      return 1
    fi
  fi
  test_network
  if [ $? -eq 1 ]; then
    set_option NETWORK "${dev} dhcp"
  fi
}

# Function configure interface network static
configure_net_static() {
  local ip gw dns1 dns2 dev=$1

  DIALOG --form "Static IP configuration for $dev:" 0 0 0 \
    "IP address:" 1 1 "192.168.0.2" 1 21 20 0 \
    "Gateway:" 2 1 "192.168.0.1" 2 21 20 0 \
    "DNS Primary" 3 1 "8.8.8.8" 3 21 20 0 \
    "DNS Secondary" 4 1 "8.8.4.4" 4 21 20 0 || return 1

  set -- $(cat $ANSWER)
  ip=$1; gw=$2; dns1=$3; dns2=$4
  echo "running: ip link set dev $dev up" >>$LOG
  ip link set dev $dev up >>$LOG 2>&1
  if [ $? -ne 0 ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} Failed to bring $dev interface." ${MSGBOXSIZE}
    return 1
  fi
  echo "running: ip addr add $ip dev $dev" >>$LOG
  ip addr add $ip dev $dev >>$LOG 2>&1
  if [ $? -ne 0 ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} Failed to set ip to the $dev interface." ${MSGBOXSIZE}
    return 1
  fi
  ip route add default via $gw >>$LOG 2>&1
  if [ $? -ne 0 ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} failed to setup your gateway." ${MSGBOXSIZE}
    return 1
  fi
  echo "nameserver $dns1" >/etc/resolv.conf
  echo "nameserver $dns2" >>/etc/resolv.conf
  test_network
  if [ $? -eq 1 ]; then
    set_option NETWORK "${dev} static $ip $gw $dns1 $dns2"
  fi
}

# Function for menu network to configure interface network
menu_network() {
  local dev addr f DEVICES

  if [ -e /var/service/NetworkManager ]; then
    test_network nm
    return
  fi

  for f in $(ls /sys/class/net); do
    [ "$f" = "lo" ] && continue
    addr=$(cat /sys/class/net/$f/address)
    DEVICES="$DEVICES $f $addr"
  done
  DIALOG --title " Select the network interface to configure " \
    --menu "$MENULABEL" ${MENUSIZE} ${DEVICES}
  if [ $? -eq 0 ]; then
    dev=$(cat $ANSWER)
    if $(echo $dev|egrep -q "^wl.*" 2>/dev/null); then
      configure_wifi $dev
    else
      configure_net $dev
    fi
  fi
}

# Function to validate user account
validate_useraccount() {
  # don't check that USERNAME has been set because it can be empty
  local USERLOGIN=$(get_option USERLOGIN)
  local USERPASSWORD=$(get_option USERPASSWORD)
  local USERGROUPS=$(get_option USERGROUPS)

  if [ -n "$USERLOGIN" ] && [ -n "$USERPASSWORD" ] && [ -n "$USERGROUPS" ]; then
    USERACCOUNT_DONE=1
  fi
}

# Function to validate user account
validate_filesystems() {
  local mnts dev size fstype mntpt mkfs rootfound fmt
  local usrfound efi_system_partition
  local bootdev=$(get_option BOOTLOADER)

  unset TARGETFS
  mnts=$(grep -E '^MOUNTPOINT .*' $CONF_FILE)
  set -- ${mnts}
  while [ $# -ne 0 ]; do
    fmt=""
    dev=$2; fstype=$3; size=$4; mntpt="$5"; mkfs=$6
    shift 6

    if [ "$mntpt" = "/" ]; then
      rootfound=1
    elif [ "$mntpt" = "/usr" ]; then
      usrfound=1
    elif [ "$fstype" = "vfat" -a "$mntpt" = "/boot/efi" ]; then
      efi_system_partition=1
    fi
    if [ "$mkfs" -eq 1 ]; then
      fmt="NEW FILESYSTEM: "
    fi
    if [ -z "$TARGETFS" ]; then
      TARGETFS="${fmt}$dev ($size) mounted on $mntpt as ${fstype}\n"
    else
      TARGETFS="${TARGETFS}${fmt}${dev} ($size) mounted on $mntpt as ${fstype}\n"
    fi
  done
  if [ -z "$rootfound" ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
the mount point for the root filesystem (/) has not yet been configured." ${MSGBOXSIZE}
    return 1
  elif [ -n "$usrfound" ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
/usr mount point has been configured but is not supported, please remove it to continue." ${MSGBOXSIZE}
    return 1
  elif [ -n "$EFI_SYSTEM" -a "$bootdev" != "none" -a -z "$efi_system_partition" ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
The EFI System Partition has not yet been configured, please create it\n
as FAT32, mountpoint /boot/efi and at least with 100MB of size." ${MSGBOXSIZE}
    return 1
  fi
  FILESYSTEMS_DONE=1
}

# Function to create filesystems
create_filesystems() {
  # Define some variables local
  local mnts dev mntpt fstype fspassno mkfs size rv uuid MKFS mem_total swap_need disk_name disk_type ROOT_UUID SWAP_UUID
  local _lvm _crypt _vgname _lvswap _lvrootfs _home _basename_mntpt _devcrypt _raid _dev
  # Initialize some local variables
  disk_type=0 # Default SSD used
  _lvm=$(get_option LVM)
  _crypt=$(get_option CRYPTO_LUKS)
  _devcrypt=$(get_option DEVCRYPT)
  _raid=$(get_option RAID)
  # Check if is defined mount device for /home
  [ -n "$(grep -E '/home .*' /tmp/.brgvos-installer.conf)" ] && _home=1 || _home=0
  # Output all defined MOUNTPOINT from configure file
  mnts=$(grep -E '^MOUNTPOINT .*' "$CONF_FILE" | sort -k 5)
  set -- ${mnts}
  while [ $# -ne 0 ]; do
    dev=$2; fstype=$3; mntpt="$5"; mkfs=$6
    shift 6
    # swap partitions
    if [ "$fstype" = "swap" ]; then
      swapoff "$dev" >/dev/null 2>&1
      if [ "$mkfs" -eq 1 ]; then # Check if was marked to be formated
        mkswap "$dev" >>"$LOG" 2>&1
        rv=$?
        if [ "$rv" -ne 0 ]; then
          DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
          failed to create swap on ${BOLD}${dev}${RESET}!\ncheck $LOG for errors." ${MSGBOXSIZE}
          DIE 1
        fi
      fi
      swapon "$dev" >>"$LOG" 2>&1 # activate swap
      rv=$?
      if [ "$rv" -ne 0 ]; then
        DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
        failed to activate swap on ${BOLD}$dev${RESET}!\ncheck $LOG for errors." ${MSGBOXSIZE}
        DIE 1
      fi
      # Add entry for target fstab
      uuid=$(blkid -o value -s UUID "$dev")
      echo "UUID=$uuid none swap defaults 0 0" >>"$TARGET_FSTAB"
      continue
    fi
    # Root partition
    if [ "$mkfs" -eq 1 ]; then # Check if was marked to be formated
      case "$fstype" in
      btrfs) MKFS="mkfs.btrfs -f"; modprobe btrfs >>"$LOG" 2>&1;;
      ext2) MKFS="mke2fs -F"; modprobe ext2 >>"$LOG" 2>&1;;
      ext3) MKFS="mke2fs -F -j"; modprobe ext3 >>"$LOG" 2>&1;;
      ext4) MKFS="mke2fs -F -t ext4"; modprobe ext4 >>"$LOG" 2>&1;;
      f2fs) MKFS="mkfs.f2fs -f"; modprobe f2fs >>"$LOG" 2>&1;;
      f2fs_c) MKFS="mkfs.f2fs -f -i -O extra_attr,inode_checksum,sb_checksum,compression"; modprobe f2fs >>"$LOG" 2>&1;;
      vfat) MKFS="mkfs.vfat -F32"; modprobe vfat >>"$LOG" 2>&1;;
      xfs) MKFS="mkfs.xfs -f -i sparse=0"; modprobe xfs >>"$LOG" 2>&1;;
      esac
      TITLE="Check $LOG for details ..."
      INFOBOX "Creating filesystem ${BOLD}$fstype${RESET} on ${BOLD}$dev${RESET} for ${BOLD}$mntpt${RESET} ..." 8 80
      echo "Running ${bold}$MKFS $dev${reset}..." >>"$LOG"
      $MKFS "$dev" >>"$LOG" 2>&1; rv=$?
      if [ "$rv" -ne 0 ]; then
        DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
        failed to create filesystem ${BOLD}$fstype${RESET} on ${BOLD}$dev${RESET}!\nCheck $LOG for errors." ${MSGBOXSIZE}
        DIE 1
      fi
    fi
    # Mount rootfs the first one.
    [ "$mntpt" != "/" ] && continue
    mkdir -p "$TARGETDIR"
      echo "Mounting ${bold}$dev${reset} on ${bold}$mntpt${reset} (${bold}$fstype${reset})..." >>"$LOG"
    if [ "$fstype" != "f2fs_c" ]; then
        mount -t "$fstype" "$dev" "$TARGETDIR" >>"$LOG" 2>&1
      else
        mount -t f2fs -o compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime "$dev" "$TARGETDIR" >>"$LOG" 2>&1
        echo "Run ${bold}chattr -R -V +c $TARGETDIR${reset}" >>"$LOG"
        chattr -R -V +c "$TARGETDIR"  >>"$LOG" 2>&1
    fi
    _devcrypt=$(echo "$_devcrypt"|awk '{$1=$1;print}') # delete last space
      if [ -n "${_devcrypt}" ]; then
          ROOTFS="${_devcrypt}"
          echo "For rootfs is used next encrypted device(s) ${bold}${ROOTFS}${reset}" >>"$LOG"
        else
          ROOTFS=$dev
          echo "For rootfs is used next device ${bold}$ROOTFS${reset}" >>"$LOG"
      fi
      rv=$?
      if [ "$rv" -ne 0 ]; then
        DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
failed to mount ${BOLD}$dev${RESET} on ${BOLD}${mntpt}${RESET}! check $LOG for errors." ${MSGBOXSIZE}
        DIE 1
      fi
    # Check if was mounted HDD or SSD
    # For LVM on RAID on LUKS
    if $(lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"; done | grep -q "$dev" &&
      lvdisplay -m $dev 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q md) &&
      $(cat /proc/mdstat | grep $(basename $(lvdisplay -m $dev | awk '/^    Physical volume/ {print $3}')) | grep -q dm); then
      # Get the name of RAID
      md=$(lvdisplay -m $dev | awk '/^    Physical volume/ {print $3}'| grep md)
      # Get encrypt devices from the RAID
      dm=$(mdadm --detail $md | awk '{print $8}' | grep /dev/dm)
      echo -e "For LVM+RAID+LUKS are used RAID: ${bold}$md${reset} with encrypted blocks:\n${bold}$dm${reset}" >>"$LOG"
      disk_name=$(lsblk -ndo pkname "$(for s in /sys/block/$(basename "$dm")/slaves/*; do
        echo "/dev/${s##*/}"
      done)")
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      mapfile -t _dm <<< "$dm"
      echo "Determine type of disk for ${bold}${_map[0]}${reset} used for block ${bold}${_dm[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM on LUKS on RAID
    elif lvdisplay -m $dev 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q crypt &&
        ls /sys/class/block/$(basename $(readlink -f  /dev/mapper/crypt_0))/slaves/ | grep -q md ; then
        md=$(
          for pv in $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}' | sort -u); do
            dm=$(basename "$(readlink -f "$pv")")
            for s in /sys/class/block/$dm/slaves/*; do
              echo "/dev/${s##*/}"
            done
          done
        )
        disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$md")")/slaves/*; do
          _dev=$(basename "$s")
          if echo $_dev | grep -q md; then
            for s in /sys/class/block/$_dev/slaves/*; do
              _dev=$(basename "$s")
              parent=$(lsblk -ndo pkname /dev/"$_dev")
              if [ -n "$parent" ]; then
                echo "$parent"
              fi
            done | sort -u
          else
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          fi
        done | sort -u)
        echo -e "For LVM+LUKS+RAID are used next disks:\n${bold}$disk_name${reset}" >>"$LOG"
        # Read every line from disk_name into matrices
        mapfile -t _map <<< "$disk_name"
        echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
        # Get first element from matrices
        # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
        disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM on LUKS
    elif lvdisplay -m $dev 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q crypt; then
      disk_name=$(lsblk -ndo pkname $(
        for pv in $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}' | sort -u); do
          dm=$(basename "$(readlink -f "$pv")")
          for s in /sys/class/block/$dm/slaves/*; do
            echo "/dev/${s##*/}"
          done
        done
      ) | sort -u)
      echo -e "For LVM+LUKS is/are used disk(s):\n ${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM on RAID
    elif lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"; done | grep -q "$dev" &&
      lvdisplay -m "$dev" 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q md; then
        md=$(
          for pv in $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}' | sort -u); do
            dm=$(basename "$(readlink -f "$pv")")
            for s in /sys/class/block/"$dm"/slaves/*; do
              echo "/dev/${s##*/}"
            done
          done
        )
        disk_name=$(for s in $md; do
                      parent=$(lsblk -ndo pkname "$s")
                        if [ -n "$parent" ]; then
                          echo "$parent"
                        fi
                   done)
      echo -e "For LVM+RAID are used next disks:\n${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For RAID on LUKS
    elif [ "$(cat /proc/mdstat | grep "$(basename "$dev")" | awk '{print $1}')" = "$(basename "$dev")" ] &&
      ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep -q crypt; then
        disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$dev")")/slaves/*; do
          _dev=$(basename "$s")
          if echo $_dev | grep -q dm; then
            for s in /sys/class/block/$_dev/slaves/*; do
              _dev=$(basename "$s")
              parent=$(lsblk -ndo pkname /dev/"$_dev")
              if [ -n "$parent" ]; then
                echo "$parent"
              fi
            done | sort -u
           else
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          fi
        done | sort -u)
      echo -e "For RAID+LUKS are used next disks:\n ${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LUKS on RAID
    elif ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep -q "$dev" && cat /proc/mdstat |
      grep -q $(for s in /sys/class/block/"$(basename "$(readlink -f "$dev")")"/slaves/*; do
          echo "${s##*/}"
        done) ; then
      md=$(for m in /sys/block/"$(basename $(readlink -f $(ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep "$dev")))"/slaves/*; do
        echo "/dev/${m##*/}"
        done)
      disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$md")")/slaves/*; do
        _dev=$(basename "$s")
        if echo $_dev | grep -q md; then
          for s in /sys/class/block/$_dev/slaves/*; do
            _dev=$(basename "$s")
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          done | sort -u
        else
          parent=$(lsblk -ndo pkname /dev/"$_dev")
          if [ -n "$parent" ]; then
            echo "$parent"
          fi
        fi
      done | sort -u)
      echo -e "For LUKS+RAID are used next disks:\n${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}""$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM
    elif lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"; done | grep -q "$dev"; then
      disk_name=$(lsblk -ndo pkname $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}') | sort -u)
      echo -e "For LVM is/are used disk(s):\n ${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LUKS
    elif ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep -q "$dev"; then
      disk_name=$(lsblk -ndo pkname "$(
        for s in /sys/class/block/"$(basename "$(readlink -f "$dev")")"/slaves/*; do
          echo "/dev/${s##*/}"
        done
      )")
      echo "For LUKS, to determine type of disk (SSD/HDD) is used ${bold}$disk_name${reset}" >>"$LOG"
      disk_type=$(cat /sys/block/"$disk_name"/queue/rotational)
    # For RAID
    elif [ "$(cat /proc/mdstat | grep "$(basename "$dev")" | awk '{print $1}')" = "$(basename "$dev")" ]; then
      disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$dev")")/slaves/*; do
        _dev=$(basename "$s")
        if echo $_dev | grep -q md; then
          for s in /sys/class/block/$_dev/slaves/*; do
            _dev=$(basename "$s")
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          done | sort -u
        else
          parent=$(lsblk -ndo pkname /dev/"$_dev")
          if [ -n "$parent" ]; then
            echo "$parent"
          fi
        fi
      done | sort -u)
      echo -e "For RAID are used next disks:\n${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For all over
    else
      disk_name=$(lsblk -ndo pkname "$dev")
      echo "Determine type of disk (SSD/HDD) is used ${bold}$disk_name${reset}" >>"$LOG"
      if [ -z "$disk_name" ]; then
        echo "I can't determine the disk_name, so I used defaults mount options for SSD" >>"$LOG"
        disk_type=0
      else
        disk_type=$(cat /sys/block/"$disk_name"/queue/rotational)
      fi
    fi
    # Prepare options for mount command for HDD or SSD, but first check if is HDD
    if [ "$disk_type" -eq 1 ]; then # So it's HDD
      if [ "$fstype" = "btrfs" ]; then
      options="compress=zstd,noatime,space_cache=v2"
      elif [ "$fstype" = "ext4" ] || [ "$fstype" = "ext3" ] || [ "$fstype" = "ext2" ]; then
        options="defaults,noatime,nodiratime"
      elif [ "$fstype" = "xfs" ]; then
        options="defaults,noatime,nodiratime,user_xattr"
      elif [ "$fstype" = "f2fs" ]; then
        options="defaults"
      elif [ "$fstype" = "f2fs_c" ]; then
        options="compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime"
        fstype="f2fs" # to be used on fstab
      fi
      echo "Options, for root filesystem ${bold}$fstype${reset}, used for mount and fstab
       ${bold}$options${reset} on ${bold}HDD${reset}" >>"$LOG"
    else # So it's SSD
      if [ "$fstype" = "btrfs" ]; then
        options="compress=zstd,noatime,space_cache=v2,discard=async,ssd"
      elif [ "$fstype" = "ext4" ] || [ "$fstype" = "ext3" ] || [ "$fstype" = "ext2" ]; then
        options="defaults,noatime,nodiratime,discard"
      elif [ "$fstype" = "xfs" ]; then
        options="defaults,noatime,nodiratime,discard,ssd,user_xattr"
      elif [ "$fstype" = "f2fs" ]; then
        options="defaults"
      elif [ "$fstype" = "f2fs_c" ]; then
        options="compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime"
        fstype="f2fs" # to be used on fstab
      fi
      echo "Options, for root filesystem ${bold}$fstype${reset}, used for mount and fstab
       ${bold}$options${reset} on ${bold}SSD${reset}" >>"$LOG"
    fi
    # Create subvolume @, @home, @var_log, @var_lib and @snapshots for lvbrgvos
    if [ "$fstype" = "btrfs" ]; then
      {
        btrfs subvolume create "$TARGETDIR"/@
        if [ "$_home" -eq 0 ]; then # If is not defined other mount point for /home, make subvolume @home on /
          btrfs subvolume create "$TARGETDIR"/@home
        fi
        btrfs subvolume create "$TARGETDIR"/@var_log
        btrfs subvolume create "$TARGETDIR"/@var_lib
        btrfs subvolume create "$TARGETDIR"/@snapshots
        umount "$TARGETDIR"
        mount -t "$fstype" -o "$options",subvol=@ "$dev" "$TARGETDIR"
        mkdir -p "$TARGETDIR"/{home,var/log,var/lib,.snapshots}
        if [ "$_home" -eq 0 ]; then # If is not defined other mount point for /home, mount subvolume @home /home now
          mount -t "$fstype" -o "$options",subvol=@home "$dev" "$TARGETDIR"/home
        fi
        mount -t "$fstype" -o "$options",nodev,noexec,nosuid,nodatacow,subvol=@snapshots "$dev" "$TARGETDIR"/.snapshots
        mount -t "$fstype" -o "$options",subvol=@var_log "$dev" "$TARGETDIR"/var/log
        mount -t "$fstype" -o "$options",subvol=@var_lib "$dev" "$TARGETDIR"/var/lib
      } >>"$LOG" 2>&1
    fi
    # Add entry to target on fstab for /
    uuid=$(blkid -o value -s UUID "$dev")
    if [ "$fstype" = "f2fs" ] || [ "$fstype" = "f2fs_c" ] || [ "$fstype" = "btrfs" ] || [ "$fstype" = "xfs" ]; then
      # Not fsck at boot for f2fs, btrfs and xfs these have their check utility
      fspassno=0
    else
      # Set to check fsck at boot first for this
      fspassno=1
    fi
    if [ "$fstype" = "btrfs" ]; then
      {
        echo "UUID=$uuid / $fstype $options,subvol=@ 0 $fspassno"
        if [ "$_home" -eq 0 ]; then # If is not defined other mount point for /home, add entry now in fstab
          echo "UUID=$uuid /home $fstype $options,subvol=@home 0 $fspassno"
        fi
        echo "UUID=$uuid /.snapshots $fstype $options,nodev,noexec,nosuid,nodatacow,subvol=@snapshots 0 $fspassno"
        echo "UUID=$uuid /var/log $fstype $options,subvol=@var_log 0 $fspassno"
        echo "UUID=$uuid /var/lib $fstype $options,subvol=@var_lib 0 $fspassno"
      } >>"$TARGET_FSTAB"
    else
      echo "UUID=$uuid $mntpt $fstype $options 0 $fspassno" >>"$TARGET_FSTAB"
    fi
  done
  # Mount all filesystems in target rootfs
  mnts=$(grep -E '^MOUNTPOINT .*' "$CONF_FILE" | sort -k 5)
  set -- ${mnts}
  while [ $# -ne 0 ]; do
    dev=$2; fstype=$3; mntpt="$5"
    shift 6
    [ "$mntpt" = "/" ] || [ "$fstype" = "swap" ] && continue
    mkdir -p ${TARGETDIR}${mntpt} >>"$LOG" 2>&1
    echo "Mounting ${bold}$dev${reset} on ${bold}$mntpt${reset} ($fstype)..." >>"$LOG"
    if [ "$fstype" != "f2fs_c" ]; then
         mount -t "$fstype" "$dev" ${TARGETDIR}${mntpt} >>"$LOG" 2>&1
      else
        mount -t f2fs -o compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime "$dev" ${TARGETDIR}${mntpt} >>"$LOG" 2>&1
        echo "Run ${bold}chattr -R -V +c $TARGETDIR${reset}" >>"$LOG"
        chattr -R -V +c ${TARGETDIR}${mntpt}  >>"$LOG" 2>&1
    fi
    rv=$?
    if [ "$rv" -ne 0 ]; then
      DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET} \
      failed to mount ${BOLD}$dev${RESET} on ${BOLD}$mntpt${RESET}! check $LOG for errors." ${MSGBOXSIZE}
      DIE
    fi
    # Check if was mounted HDD or SSD
    echo "For device ${bold}$dev${reset}" >>"$LOG"
    # For LVM on RAID on LUKS
    if $(lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"; done | grep -q "$dev" &&
      lvdisplay -m $dev 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q md) &&
      $(cat /proc/mdstat | grep $(basename $(lvdisplay -m $dev | awk '/^    Physical volume/ {print $3}')) | grep -q dm); then
      # Get the name of RAID
      md=$(lvdisplay -m $dev | awk '/^    Physical volume/ {print $3}'| grep md)
      # Get encrypt devices from the RAID
      dm=$(mdadm --detail $md | awk '{print $8}' | grep /dev/dm)
      echo -e "For LVM+RAID+LUKS are used RAID: ${bold}$md${reset} with encrypted blocks:\n${bold}$dm${reset}" >>"$LOG"
      disk_name=$(lsblk -ndo pkname "$(for s in /sys/block/$(basename "$dm")/slaves/*; do
        echo "/dev/${s##*/}"
          done)")
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      mapfile -t _dm <<< "$dm"
      echo "Determine type of disk for ${bold}${_map[0]}${reset} used for block ${bold}${_dm[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM on LUKS on RAID
    elif lvdisplay -m $dev 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q crypt &&
      ls /sys/class/block/$(basename $(readlink -f  /dev/mapper/crypt_0))/slaves/ | grep -q md ; then
      md=$(
        for pv in $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}' | sort -u); do
          dm=$(basename "$(readlink -f "$pv")")
          for s in /sys/class/block/$dm/slaves/*; do
            echo "/dev/${s##*/}"
          done
        done
      )
      disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$md")")/slaves/*; do
        _dev=$(basename "$s")
        if echo $_dev | grep -q md; then
          for s in /sys/class/block/$_dev/slaves/*; do
            _dev=$(basename "$s")
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          done | sort -u
        else
          parent=$(lsblk -ndo pkname /dev/"$_dev")
          if [ -n "$parent" ]; then
            echo "$parent"
          fi
        fi
      done | sort -u)
      echo -e "For LVM+LUKS+RAID are used next disks:\n${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM on LUKS
    elif lvdisplay -m $dev 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q crypt; then
      disk_name=$(lsblk -ndo pkname $(
        for pv in $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}' | sort -u); do
          dm=$(basename "$(readlink -f "$pv")")
          for s in /sys/class/block/$dm/slaves/*; do
            echo "/dev/${s##*/}"
          done
        done
      ) | sort -u)
      echo -e "For LVM+LUKS is/are used disk(s):\n ${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      # Get element from matrices
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
      echo "Determine type of disk (SSD/HDD) is used ${bold}${_map[0]}${reset}" >>"$LOG"
    # For LVM on RAID
    elif lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"; done | grep -q "$dev" &&
      lvdisplay -m "$dev" 2>/dev/null| awk '/^    Physical volume/ {print $3}'| grep -q md; then
        md=$(
          for pv in $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}' | sort -u); do
            dm=$(basename "$(readlink -f "$pv")")
            for s in /sys/class/block/"$dm"/slaves/*; do
              echo "/dev/${s##*/}"
            done
          done
        )
        disk_name=$(for s in $md; do
                      parent=$(lsblk -ndo pkname "$s")
                        if [ -n "$parent" ]; then
                          echo "$parent"
                        fi
                   done)
      echo -e "For LVM+RAID are used next disks:\n${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For RAID on LUKS
    elif [ "$(cat /proc/mdstat | grep "$(basename "$dev")" | awk '{print $1}')" = "$(basename "$dev")" ] &&
      ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep -q crypt; then
        disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$dev")")/slaves/*; do
          _dev=$(basename "$s")
          if echo $_dev | grep -q dm; then
            for s in /sys/class/block/$_dev/slaves/*; do
              _dev=$(basename "$s")
              parent=$(lsblk -ndo pkname /dev/"$_dev")
              if [ -n "$parent" ]; then
                echo "$parent"
              fi
            done | sort -u
           else
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          fi
        done | sort -u)
      echo -e "For RAID+LUKS are used disks:\n ${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk used (SSD/HDD) for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LUKS on RAID
    elif ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep -q "$dev" && cat /proc/mdstat |
      grep -q $(for s in /sys/class/block/"$(basename "$(readlink -f "$dev")")"/slaves/*; do
          echo "${s##*/}"
        done) ; then
      md=$(for m in /sys/block/"$(basename $(readlink -f $(ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep "$dev")))"/slaves/*; do
        echo "/dev/${m##*/}"
        done)
      disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$md")")/slaves/*; do
        _dev=$(basename "$s")
        if echo $_dev | grep -q md; then
          for s in /sys/class/block/$_dev/slaves/*; do
            _dev=$(basename "$s")
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          done | sort -u
        else
          parent=$(lsblk -ndo pkname /dev/"$_dev")
          if [ -n "$parent" ]; then
            echo "$parent"
          fi
        fi
      done | sort -u)
      echo -e "For LUKS+RAID are used next disks:\n${bold}$disk_name${reset}"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used for ${bold}${_map[0]}${reset}"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LVM
    elif lvs --noheadings|while read -r lvname vgname perms size; do
      echo "/dev/mapper/${vgname}-${lvname}"; done | grep -q "$dev"; then
      disk_name=$(lsblk -ndo pkname $(lvdisplay -m "$dev" | awk '/^    Physical volume/ {print $3}') | sort -u)
      echo "For LVM is used disk(s) ${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk (SSD/HDD) is used ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get element from matrices
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For LUKS
    elif ls -d /dev/mapper/crypt_* 2>/dev/null|grep '[0-9]'| grep -q "$dev"; then
      disk_name=$(lsblk -ndo pkname "$(
        for s in /sys/class/block/"$(basename "$(readlink -f "$dev")")"/slaves/*; do
          echo "/dev/${s##*/}"
        done
      )")
      echo -e "For LUKS, to determine type of disk (SSD/HDD) is used:\n${bold}$disk_name${reset}" >>"$LOG"
      disk_type=$(cat /sys/block/"$disk_name"/queue/rotational)
    # For RAID
    elif [ "$(cat /proc/mdstat | grep "$(basename "$dev")" | awk '{print $1}')" = "$(basename "$dev")" ]; then
      disk_name=$(for s in /sys/class/block/$(basename "$(readlink -f "$dev")")/slaves/*; do
        _dev=$(basename "$s")
        if echo $_dev | grep -q md; then
          for s in /sys/class/block/$_dev/slaves/*; do
            _dev=$(basename "$s")
            parent=$(lsblk -ndo pkname /dev/"$_dev")
            if [ -n "$parent" ]; then
              echo "$parent"
            fi
          done | sort -u
        else
          parent=$(lsblk -ndo pkname /dev/"$_dev")
          if [ -n "$parent" ]; then
            echo "$parent"
          fi
        fi
      done | sort -u)
      echo -e "For RAID are used disks:\n${bold}$disk_name${reset}" >>"$LOG"
      # Read every line from disk_name into matrices
      mapfile -t _map <<< "$disk_name"
      echo "Determine type of disk used (SSD/HDD) for ${bold}${_map[0]}${reset}" >>"$LOG"
      # Get first element from matrices
      # I take in consideration only first disk (consider all disk are the same type HDD or SSD)
      disk_type=$(cat /sys/block/"${_map[0]}"/queue/rotational)
    # For all over
    else
      disk_name=$(lsblk -ndo pkname "$dev")
      echo "Determine type of disk (SSD/HDD) is used for ${bold}$disk_name${reset}" >>"$LOG"
      if [ -z "$disk_name" ]; then
        echo "I can't determine the disk_name, so I used defaults mount options for SSD" >>"$LOG"
        disk_type=0
      else
        disk_type=$(cat /sys/block/"$disk_name"/queue/rotational)
      fi
    fi
    # Add entry to target fstab
    uuid=$(blkid -o value -s UUID "$dev")
    if [ "$fstype" = "f2fs" ] || [ "$fstype" = "f2fs_c" ] || [ "$fstype" = "btrfs" ] || [ "$fstype" = "xfs" ]; then
      fspassno=0 # Not use fsck at boot for f2fs, btrfs and xfs these have their check utility
    elif [ "$mntpt" = "/boot/efi" ]; then
      fspassno=1 # Set to check fsck at boot this device first (to be mounted /boot/efi)
    else
      fspassno=2 # Set to check fsck at boot after first device
    fi
    # Prepare options for mount command for HDD or SSD, but first check if is HDD
    if [ "$disk_type" -eq 1 ]; then # So it's HDD
      if [ "$fstype" = "btrfs" ]; then
        options="compress=zstd,noatime,space_cache=v2"
      elif [ "$fstype" = "ext4" ] || [ "$fstype" = "ext3" ] || [ "$fstype" = "ext2" ]; then
        options="defaults,noatime,nodiratime"
      elif [ "$fstype" = "xfs" ]; then
        options="defaults,noatime,nodiratime,user_xattr"
      elif [ "$fstype" = "f2fs" ]; then
        options="defaults"
      elif [ "$fstype" = "f2fs_c" ]; then
        options="compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime"
        fstype="f2fs" # to be used on fstab
      elif [ "$fstype" = "vfat" ]; then
        if [ -n "$_raid" ] && [ "$mntpt" = "/boot/efi" ]; then # Check if was selected RAID and set noauto for /boot/efi for RAID
          options="defaults,noauto"
          fspassno=0 # Set do not check fsck at boot because is not auto-mounted
        else
          options="defaults"
        fi
      fi
      echo "Options, for filesystem ${bold}$fstype${reset}, used for mount ${bold}$mntpt${reset} in fstab
       is ${bold}$options${reset} on ${bold}HDD${reset}" >>"$LOG"
    else # So it's SSD
      if [ "$fstype" = "btrfs" ]; then
        options="compress=zstd,noatime,space_cache=v2,discard=async,ssd"
      elif [ "$fstype" = "ext4" ] || [ "$fstype" = "ext3" ] || [ "$fstype" = "ext2" ]; then
        options="defaults,noatime,nodiratime,discard"
      elif [ "$fstype" = "xfs" ]; then
        options="defaults,noatime,nodiratime,discard,ssd,user_xattr"
      elif [ "$fstype" = "f2fs" ]; then
        options="defaults"
      elif [ "$fstype" = "f2fs_c" ]; then
        options="compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime"
        fstype="f2fs" # to be used on fstab
      elif [ "$fstype" = "vfat" ]; then
        if [ -n "$_raid" ] && [ "$mntpt" = "/boot/efi" ]; then # Check if was selected RAID and set noauto for /boot/efi for RAID
          options="defaults,noauto"
          fspassno=0 # Set do not check fsck at boot because is not auto-mounted
        else
          options="defaults"
        fi
      fi
      echo "Options, for filesystem ${bold}$fstype${reset}, used for mount ${bold}$mntpt${reset} in fstab
       is ${bold}$options${reset} on ${bold}SSD${reset}" >>"$LOG"
    fi
    _basename_mntpt=$(basename "$mntpt")
    # Create subvolume @home and mount in /home
    if [ "$fstype" = "btrfs" ] && [ "$mntpt" = "/home" ]; then
      {
        echo "Running ${bold}btrfs subvolume create ${TARGETDIR}${mntpt}/@home${reset}"
        btrfs subvolume create ${TARGETDIR}${mntpt}/@home
        echo "Unmounting ${bold}$dev${reset} from ${bold}$mntpt${reset} ($fstype)..."
        umount ${TARGETDIR}${mntpt}
        echo "Mounting ${bold}$dev${reset} on ${bold}$mntpt${reset} add to option ${bold}subvol=@home${reset} ..."
        mount -t "$fstype" -o "$options",subvol=@home "$dev" ${TARGETDIR}${mntpt}
      } >>"$LOG" 2>&1
    elif [ "$fstype" = "btrfs" ] && [ "$mntpt" != "/home" ]; then  # Create subvolume @$mntpt and mount for overs
      {
        echo "Running ${bold}btrfs subvolume create ${TARGETDIR}${mntpt}/@$_basename_mntpt${reset}"
        btrfs subvolume create ${TARGETDIR}${mntpt}/@$_basename_mntpt
        echo "Unmounting ${bold}$dev${reset} from ${bold}$mntpt${reset} ($fstype)..."
        umount ${TARGETDIR}${mntpt}
        echo "Mounting ${bold}$dev${reset} on ${bold}$mntpt${reset} add to option ${bold}subvol=@$_basename_mntpt${reset} ..."
        mount -t "$fstype" -o "$options",nodev,nosuid,nodatacow,subvol=@$_basename_mntpt "$dev" ${TARGETDIR}${mntpt}
      } >>"$LOG" 2>&1
    fi
    # Add entry on fstab
    if [ "$fstype" = "btrfs" ] && [ "$mntpt" = "/home" ]; then
      echo "UUID=$uuid $mntpt $fstype $options,subvol=@home 0 $fspassno" >>"$TARGET_FSTAB"
    elif [ "$fstype" = "btrfs" ] && [ "$mntpt" != "/home" ]; then
      echo "UUID=$uuid $mntpt $fstype $options,nodev,nosuid,nodatacow,subvol=@$_basename_mntpt 0 $fspassno" >>"$TARGET_FSTAB"
    else
      echo "UUID=$uuid $mntpt $fstype $options 0 $fspassno" >>"$TARGET_FSTAB"
    fi
  done
}

# Function to mount filesystems
mount_filesystems() {
  for f in sys proc dev; do
    [ ! -d "$TARGETDIR"/"$f" ] && mkdir "$TARGETDIR"/"$f"
    echo "Mounting $TARGETDIR/$f..." >>"$LOG"
    mount --rbind /"$f" "$TARGETDIR"/"$f" >>"$LOG" 2>&1
  done
}

# Function to umount filesystems
umount_filesystems() {
  # Define some variables local
  local mnts
  mnts="$(grep -E '^MOUNTPOINT .* swap .*$' "$CONF_FILE" | sort -r -k 5)"
  set -- ${mnts}
  while [ $# -ne 0 ]; do
    local dev=$2; local fstype=$3
    shift 6
    if [ "$fstype" = "swap" ]; then
      echo "Disabling swap space on $dev..." >>"$LOG"
      swapoff "$dev" >>"$LOG" 2>&1
      continue
    fi
  done
  echo "Unmounting $TARGETDIR..." >>"$LOG"
  umount -R "$TARGETDIR" >>"$LOG" 2>&1
}

# Function to count progress copy files
log_and_count() {
  local progress whole tenth
  while read line; do
    echo "$line" >>$LOG
    copy_count=$((copy_count + 1))
    progress=$((100 * copy_count / copy_total))
    if [ "$progress" != "$copy_progress" ]; then
      copy_progress=$progress
      echo $progress | \
      GAUGE "Copying live image to target rootfs.\n\n    Total files: ${copy_total}\n  Written files: ${copy_count}" 10 80
    fi
  done
}

# Function for copy rootfs
copy_rootfs() {
  local tar_in="--create --one-file-system --xattrs"
  TITLE="Check $LOG for details ..."
  INFOBOX "Counting files, please be patient ..." 4 80
  copy_total=$(tar ${tar_in} -v -f /dev/null / 2>/dev/null | wc -l)
  export copy_total copy_count=0 copy_progress=
  clear
  tar ${tar_in} -f - / 2>/dev/null | \
    tar --extract --xattrs --xattrs-include='*' --preserve-permissions -v -f - -C $TARGETDIR | \
    log_and_count
  if [ $? -ne 0 ]; then
    DIE 1
  fi
  unset copy_total copy_count copy_percent
}

# Function for install packages
install_packages() {
  # Define some local variables
  local _grub _syspkg _extrapkg _kernel _dracut _apparmor _audit _firewall
  # Initialise variables
  _grub=
  _syspkg=
  _extrapkg=
  _kernel=
  _dracut=
  _apparmor=$(get_option APPARMOR)
  _audit=$(get_option AUDIT)
  _firewall=$(get_option FIREWALL)

  if [ "$(get_option BOOTLOADER)" != none ]; then
    if [ -n "$EFI_SYSTEM" ]; then
      if [ $EFI_FW_BITS -eq 32 ]; then
        _grub="grub-i386-efi"
      else
        _grub="grub-x86_64-efi"
      fi
    else
      _grub="grub"
    fi
  fi

  _syspkg="base-system"
  _extrapkg="lvm2 cryptsetup nano bash-completion cronie"
  _kernel="linux6.18"
  _dracut="dracut"

  # Add the package 'apparmor' if the user select this option
  if [ -n "$_apparmor" ] && [ "$_apparmor" -eq 1 ]; then
    _extrapkg+=" apparmor"
  fi
  # Add the package 'audit' if the user select this option
  if [ -n "$_audit" ] && [ "$_audit" -eq 1 ]; then
    _extrapkg+=" audit"
  fi

  # Add the package 'vuurmuur' if the user select this option
  if [ -n "$_firewall" ] && [ "$_firewall" -eq 1 ]; then
    _extrapkg+=" vuurmuur"
  fi

  mkdir -p $TARGETDIR/var/db/xbps/keys $TARGETDIR/usr/share
  cp -a /usr/share/xbps.d $TARGETDIR/usr/share/
  cp /var/db/xbps/keys/*.plist $TARGETDIR/var/db/xbps/keys
  if [ -n "$MIRROR_DONE" ]; then
    mkdir -p $TARGETDIR/etc
    cp -a /etc/xbps.d $TARGETDIR/etc
  fi
  mkdir -p $TARGETDIR/boot/grub

  _arch=$(xbps-uhelper arch)

  stdbuf -oL env XBPS_ARCH=${_arch} \
    xbps-install  -r $TARGETDIR -SyU ${_syspkg} ${_grub} ${_kernel} ${_dracut} ${_extrapkg} 2>&1 | \
    DIALOG --title "Installing base system packages..." \
      --programbox 24 80
  if [ $? -ne 0 ]; then
    DIE 1
  fi
  xbps-reconfigure -r $TARGETDIR -f base-files >/dev/null 2>&1
  stdbuf -oL chroot $TARGETDIR xbps-reconfigure -a 2>&1 | \
    DIALOG --title "Configuring base system packages..." --programbox 24 80
  if [ $? -ne 0 ]; then
    DIE 1
  fi
}

# Function with menu for choose services to start at boot
menu_services() {
  local sv _status _checklist=""
  # filter out services that probably shouldn't be messed with
  local sv_ignore='^(agetty-(tty[1-9]|generic|serial|console)|udevd|sulogin)$'
  find $TARGETDIR/etc/runit/runsvdir/default -mindepth 1 -maxdepth 1 -xtype d -printf '%f\n' | \
    grep -Ev "$sv_ignore" | sort -u > "$TARGET_SERVICES"
  while true; do
    while read -r sv; do
      if [ -n "$sv" ]; then
        if grep -qx "$sv" "$TARGET_SERVICES" 2>/dev/null; then
          _status=on
        else
          _status=off
        fi
        _checklist+=" ${sv} ${sv} ${_status}"
      fi
    done < <(find $TARGETDIR/etc/sv -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | grep -Ev "$sv_ignore" | sort -u)
    DIALOG --no-tags --checklist "Select services to enable:" 20 60 18 ${_checklist}
    if [ $? -eq 0 ]; then
      comm -13 "$TARGET_SERVICES" <(cat "$ANSWER" | tr ' ' '\n') | while read -r sv; do
        enable_service "$sv"
      done
      comm -23 "$TARGET_SERVICES" <(cat "$ANSWER" | tr ' ' '\n') | while read -r sv; do
        disable_service "$sv"
      done
      break
    else
      return
    fi
  done
}

# Function to enable services for selected services on menu_services
enable_service() {
  ln -sf "/etc/sv/$1" "$TARGETDIR/etc/runit/runsvdir/default/$1"
}

# Function to disable services for unselected services on menu_services
disable_service() {
  rm -f "$TARGETDIR/etc/runit/runsvdir/default/$1"
}

# Function for menu install
menu_install() {
  # Define some local variables
  local _apparmor _audit
  # Load variables
  _apparmor=$(get_option APPARMOR)
  _audit=$(get_option AUDIT)
  ROOTPASSWORD_DONE="$(get_option ROOTPASSWORD)"
  BOOTLOADER_DONE="$(get_option BOOTLOADER)"

  if [ -z "$ROOTPASSWORD_DONE" ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET}${BOLD}The root password has not been configured, \
please do so before starting the installation.${RESET}" ${MSGBOXSIZE}
    return 1
  elif [ -z "$BOOTLOADER_DONE" ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET}${BOLD}The disk to install the bootloader has not been \
configured, please do so before starting the installation.${RESET}" ${MSGBOXSIZE}
    return 1
  fi

  # Validate filesystems after making sure bootloader is done,
  # so that specific checks can be made based on the selection
  validate_filesystems || return 1

  if [ -z "$FILESYSTEMS_DONE" ]; then
    DIALOG --msgbox "${BOLD}${RED}ERROR:${RESET}${BOLD}Required filesystems were not configured, \
please do so before starting the installation.${RESET}" ${MSGBOXSIZE}
    return 1
  fi

  # Validate useraccount. All parameters must be set (name, password, login name, groups).
  validate_useraccount

  if [ -z "$USERACCOUNT_DONE" ]; then
    DIALOG --yesno "${BOLD}The user account is not set up properly.${RESET}\n\n
${BOLD}${RED}WARNING: no user will be created. You will only be able to login \
with the root user in your new system.${RESET}\n\n
${BOLD}Do you want to continue?${RESET}" 10 60 || return
  fi

  DIALOG --yesno "${BOLD}The following operations will be executed:${RESET}\n\n
${BOLD}${TARGETFS}${RESET}\n
${BOLD}${RED}WARNING: data on partitions will be COMPLETELY DESTROYED for NEW \
FILESYSTEMS.${RESET}\n\n
${BOLD}Do you want to continue?${RESET}" 20 80 || return
  unset TARGETFS

  # Create and mount filesystems
  create_filesystems

  SOURCE_DONE="$(get_option SOURCE)"
  # If source not set use defaults.
  if [ "$(get_option SOURCE)" = "local" -o -z "$SOURCE_DONE" ]; then
    copy_rootfs
    . /etc/default/live.conf
    rm -f $TARGETDIR/etc/motd
    rm -f $TARGETDIR/etc/issue
    rm -f $TARGETDIR/usr/sbin/brgvos-installer
    rm -f $TARGETDIR/usr/local/share/applications/install.desktop
    # Remove modified sddm.conf to let sddm use the defaults.
    rm -f $TARGETDIR/etc/sddm.conf
    # Remove live user.
    echo "Removing $USERNAME live user from targetdir ..." >>$LOG
    chroot $TARGETDIR userdel -r $USERNAME >>$LOG 2>&1
    rm -f $TARGETDIR/etc/sudoers.d/99-void-live
    sed -i "s,GETTY_ARGS=\"--noclear -a $USERNAME\",GETTY_ARGS=\"--noclear\",g" $TARGETDIR/etc/sv/agetty-tty1/conf
    TITLE="Check $LOG for details ..."
    INFOBOX "Rebuilding initramfs for target ..." 4 80
    echo "Rebuilding initramfs for target ..." >>$LOG
    # mount required fs
    mount_filesystems
    chroot $TARGETDIR dracut --no-hostonly --add-drivers "ahci" --force >>$LOG 2>&1
    INFOBOX "Removing temporary packages from target ..." 4 80
    echo "Removing temporary packages from target ..." >>$LOG
    TO_REMOVE="xmirror"
    # only remove espeakup and brltty if it wasn't enabled in the live environment
    if ! [ -e "/var/service/espeakup" ]; then
      TO_REMOVE+=" espeakup"
    fi
    # Remove apparmour package if not was selected by the user in Hardening menu
    if [ -z "$_audit" ] || [ ! "$_apparmor" -eq 1 ]; then
      TO_REMOVE+=" apparmor"
      chroot $TARGETDIR rm -r -f /etc/apparmor.d/ >>$LOG 2>&1
    fi
    # Remove audit package and group if not was selected by user in Hardening menu
    if [ -z "$_audit" ] || [ ! "$_audit" -eq 1 ]; then
      TO_REMOVE+=" audit"
      chroot $TARGETDIR groupdel audit >>$LOG 2>&1
    fi
    # For Gnome have dependencies Orca and this have dependencies brltty
    #if ! [ -e "/var/service/brltty" ]; then
    #    TO_REMOVE+=" python3-brlapi brltty"
    #fi
    if [ "$(get_option BOOTLOADER)" = none ]; then
      TO_REMOVE+=" grub-x86_64-efi grub-i386-efi grub"
    fi
    # uninstall separately to minimise errors
    for pkg in $TO_REMOVE; do
      xbps-remove -r $TARGETDIR -Ry "$pkg" >>$LOG 2>&1
    done
    # Remove /etc/apparmour.d directory if not was selected by the user in Hardening menu
    if [ -z "$_audit" ] || [ ! "$_apparmor" -eq 1 ]; then
      chroot $TARGETDIR rm -r -f /etc/apparmor.d/ >>$LOG 2>&1
    fi
    # Remove /etc/audit directory if not was selected by user in Hardening menu
    if [ -z "$_audit" ] || [ ! "$_audit" -eq 1 ]; then
      chroot $TARGETDIR rm -r -f /etc/audit >>$LOG 2>&1
    fi
    rmdir $TARGETDIR/mnt/target
  else
    # mount required fs
    mount_filesystems
    # network install, use packages.
    install_packages
  fi

  INFOBOX "Applying installer settings..." 4 80

  # copy target fstab.
  install -Dm644 $TARGET_FSTAB $TARGETDIR/etc/fstab
  # Mount /tmp as tmpfs.
  echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" >> $TARGETDIR/etc/fstab


  # set up keymap, locale, timezone, hostname, root passwd and user account.
  set_keymap
  set_locale
  set_timezone
  set_hostname
  set_rootpassword
  set_useraccount

  # Copy /etc/skel files for root.
  cp $TARGETDIR/etc/skel/.[bix]* $TARGETDIR/root

  NETWORK_DONE="$(get_option NETWORK)"
  # network settings for target
  if [ -n "$NETWORK_DONE" ]; then
    local net="$(get_option NETWORK)"
    set -- ${net}
    local _dev="$1" _type="$2" _ip="$3" _gw="$4" _dns1="$5" _dns2="$6"
    if [ -z "$_type" ]; then
      # network type empty??!!!
      :
    elif [ "$_type" = "dhcp" ]; then
      if $(echo $_dev|egrep -q "^wl.*" 2>/dev/null); then
        cp /etc/wpa_supplicant/wpa_supplicant.conf $TARGETDIR/etc/wpa_supplicant
        enable_service wpa_supplicant
      fi
      enable_service dhcpcd
    elif [ -n "$_dev" -a "$_type" = "static" ]; then
      # static IP through dhcpcd.
      mv $TARGETDIR/etc/dhcpcd.conf $TARGETDIR/etc/dhcpcd.conf.orig
      echo "# Static IP configuration set by the void-installer for $_dev." \
        >$TARGETDIR/etc/dhcpcd.conf
      echo "interface $_dev" >>$TARGETDIR/etc/dhcpcd.conf
      echo "static ip_address=$_ip" >>$TARGETDIR/etc/dhcpcd.conf
      echo "static routers=$_gw" >>$TARGETDIR/etc/dhcpcd.conf
      echo "static domain_name_servers=$_dns1 $_dns2" >>$TARGETDIR/etc/dhcpcd.conf
      enable_service dhcpcd
    fi
  fi

  if [ -d $TARGETDIR/etc/sudoers.d ]; then
    USERLOGIN="$(get_option USERLOGIN)"
    if [ -z "$(echo $(get_option USERGROUPS) | grep -w wheel)" -a -n "$USERLOGIN" ]; then
      # enable sudo for primary user USERLOGIN who is not member of wheel
      echo "# Enable sudo for login '$USERLOGIN'" > "$TARGETDIR/etc/sudoers.d/$USERLOGIN"
      echo "$USERLOGIN ALL=(ALL:ALL) ALL" >> "$TARGETDIR/etc/sudoers.d/$USERLOGIN"
    else
      # enable the sudoers entry for members of group wheel
      echo "%wheel ALL=(ALL:ALL) ALL" > "$TARGETDIR/etc/sudoers.d/wheel"
    fi
    unset USERLOGIN
  fi

  # clean up polkit rule - it's only useful in live systems
  rm -f $TARGETDIR/etc/polkit-1/rules.d/void-live.rules

  # enable text console for grub if chosen
  if [ "$(get_option TEXTCONSOLE)" = "1" ]; then
    sed -i $TARGETDIR/etc/default/grub \
      -e 's|#\(GRUB_TERMINAL_INPUT\).*|\1=console|' \
      -e 's|#\(GRUB_TERMINAL_OUTPUT\).*|\1=console|'
  fi

  # install bootloader.
  set_bootloader

  # menu for enabling services
  menu_services

  sync && sync && sync

  # unmount all filesystems.
  umount_filesystems

  # installed successfully.
  DIALOG --yesno "${BOLD}${GREEN}BRGV-OS Linux has been installed successfully!${RESET}\n
Do you want to reboot the system?" ${YESNOSIZE}
  if [ $? -eq 0 ]; then
    shutdown -r now
  else
    return
  fi
}

# Function for menu Source
menu_source() {
  local src
  src=

  DIALOG --title " Select installation source " \
    --menu "$MENULABEL" 8 80 0 \
    "Local" "Packages from ISO image" \
    "Network" "Base system with kernel downloaded from official repository"
  case "$(cat $ANSWER)" in
  "Local") src="local";;
  "Network") src="net";
    if [ -z "$NETWORK_DONE" ]; then
      if test_network; then
        menu_network
      fi
    fi;;
  *) return 1;;
  esac
  SOURCE_DONE=1
  set_option SOURCE $src
}

# Function for menu Mirror
menu_mirror() {
  xmirror 2>>$LOG && MIRROR_DONE=1
}

# Function for main Menu
menu() {
  local AFTER_HOSTNAME
  if [ -z "$DEFITEM" ]; then
    DEFITEM="Keyboard"
  fi

  if xbps-uhelper arch | grep -qe '-musl$'; then
    AFTER_HOSTNAME="Timezone"
    DIALOG --default-item $DEFITEM \
      --extra-button --extra-label "Settings" \
      --title " BRGV-OS Linux installation menu " \
      --menu "$MENULABEL" 10 80 0 \
      "Keyboard" "Set system keyboard" \
      "Network" "Set up the network" \
      "Source" "Set source installation" \
      "Mirror" "Select XBPS mirror" \
      "Hostname" "Set system hostname" \
      "Timezone" "Set system time zone" \
      "RootPassword" "Set system root password" \
      "Hardening" "Hardening settings" \
      "UserAccount" "Set primary user name and password" \
      "BootLoader" "Set disk to install bootloader" \
      "Partition" "Partition disk(s)" \
      "LVM&LUKS" "Set LVM and crypto LUKS" \
      "Raid" "Raid software" \
      "Filesystems" "Configure filesystems and mount points" \
      "Install" "Start installation with saved settings" \
      "Exit" "Exit installation"
  else
    AFTER_HOSTNAME="Locale"
    DIALOG --default-item $DEFITEM \
      --extra-button --extra-label "Settings" \
      --title " BRGV-OS Linux installation menu " \
      --menu "$MENULABEL" 10 80 0 \
      "Keyboard" "Set system keyboard" \
      "Network" "Set up the network" \
      "Source" "Set source installation" \
      "Mirror" "Select XBPS mirror" \
      "Hostname" "Set system hostname" \
      "Locale" "Set system locale" \
      "Timezone" "Set system time zone" \
      "RootPassword" "Set system root password" \
      "Hardening" "Hardening settings" \
      "UserAccount" "Set primary user name and password" \
      "BootLoader" "Set disk to install bootloader" \
      "Partition" "Partition disk(s)" \
      "LVM&LUKS" "Set LVM and crypto LUKS" \
      "Raid" "Raid software" \
      "Filesystems" "Configure filesystems and mount points" \
      "Install" "Start installation with saved settings" \
      "Exit" "Exit installation"
  fi

  if [ $? -eq 3 ]; then
    # Show settings
    cp $CONF_FILE /tmp/conf_hidden.$$;
    sed -i "s/^ROOTPASSWORD .*/ROOTPASSWORD <-hidden->/" /tmp/conf_hidden.$$
    sed -i "s/^USERPASSWORD .*/USERPASSWORD <-hidden->/" /tmp/conf_hidden.$$
    DIALOG --title "Saved settings for installation" --textbox /tmp/conf_hidden.$$ 14 70
    rm /tmp/conf_hidden.$$
    return
  fi

  case $(cat $ANSWER) in
  "Keyboard") menu_keymap && [ -n "$KEYBOARD_DONE" ] && DEFITEM="Network";;
  "Network") menu_network && [ -n "$NETWORK_DONE" ] && DEFITEM="Source";;
  "Source") menu_source && [ -n "$SOURCE_DONE" ] && DEFITEM="Mirror";;
  "Mirror") menu_mirror && [ -n "$MIRROR_DONE" ] && DEFITEM="Hostname";;
  "Hostname") menu_hostname && [ -n "$HOSTNAME_DONE" ] && DEFITEM="$AFTER_HOSTNAME";;
  "Locale") menu_locale && [ -n "$LOCALE_DONE" ] && DEFITEM="Timezone";;
  "Timezone") menu_timezone && [ -n "$TIMEZONE_DONE" ] && DEFITEM="RootPassword";;
  "RootPassword") menu_rootpassword && [ -n "$ROOTPASSWORD_DONE" ] && DEFITEM="Hardening";;
  "Hardening") menu_hardening "$@" && [ -n "$HARDENING_DONE" ] && DEFITEM="UserAccount";;
  "UserAccount") menu_useraccount && [ -n "$USERLOGIN_DONE" ] && [ -n "$USERPASSWORD_DONE" ] && DEFITEM="BootLoader";;
  "BootLoader") menu_bootloader && [ -n "$BOOTLOADER_DONE" ] && DEFITEM="Partition";;
  "Partition") menu_partitions && [ -n "$PARTITIONS_DONE" ] && DEFITEM="LVM&LUKS";;
  "LVM&LUKS") menu_lvm_luks && [ -n "$LVMLUKS_DONE" ] && DEFITEM="Raid";;
  "Raid") menu_raid && [ -n "$RAID_DONE" ] && DEFITEM="Filesystems";;
  "Filesystems") menu_filesystems && [ -n "$FILESYSTEMS_DONE" ] && DEFITEM="Install";;
  "Install") menu_install;;
  "Exit") DIE;;
  *) DIALOG --yesno "${RED}Abort Installation?${RESET}" ${YESNOSIZE} && DIE
  esac
}

if ! command -v dialog >/dev/null; then
  echo "ERROR: missing dialog command, exiting..."
  exit 1
fi

if [ "$(id -u)" != "0" ]; then
  echo "brgvos-installer must run as root" 1>&2
  exit 1
fi

#
# main()
#
DIALOG --title "${BOLD}${RED} Enter ... ${RESET}" --msgbox "\n
Welcome to the ${BOLD}${MAGENTA}'BRGV-OS'${RESET} Linux installation. A simple and minimal Linux spin distribution based on \
${BOLD}${MAGENTA}'Void'${RESET}, made from scratch and built from the source package tree available for XBPS, a new \
alternative binary package system.\n
\n
The installation should be pretty straightforward. If you are in trouble please ask at \
${BOLD}${YELLOW}https://github.com/florintanasa/brgvos-void/discussions${RESET} or join to:\n
- ${BOLD}${YELLOW}https://voidforums.com${RESET} \n
- ${BOLD}${YELLOW}#voidlinux${RESET} on ${BOLD}${YELLOW}irc.libera.chat${RESET} \n
because BRGV-OS is Void spin and technically are not differences.\n
\n
More info at:\n
${BOLD}${YELLOW}https://github.com/florintanasa/brgvos-void${RESET}\n
${BOLD}${YELLOW}https://www.voidlinux.org${RESET}\n" 20 80

while true; do
  menu "$@" # Argument can be a file for menu_hardening function, but work also without argument
done

exit 0
# vim: set ts=4 sw=4 et:
