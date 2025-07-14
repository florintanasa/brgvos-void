#!/usr/bin/env bash

# set the date and time
data=$(date +'%d%m%Y_%H%M%S')

# change the owner for includedir
chown root:root -R includedir

# change working directory
cd void-mklive

# flag used for build the iso
arch=$(cat ../arch)
variant=$(cat ../variant)
keymap=$(cat ../keymap)
locale=$(cat ../locale)
root_shell=$(cat ../root_shell)
linux_version=$(cat ../linux_version)
title=$(cat ../title)
kernel_arg=$(cat ../kernel_arg)
other_pkg=$(cat ../other_pkg)

# run void linux script to build iso file image with our distribution
sudo ./mkiso.sh \
-a $arch \
-b $variant \
-- -k $keymap \
-B $variant \
-l $locale \
-e $root_shell \
-v $linux_version \
-T $title \
-C "$kernel_arg" \
-p "$other_pkg" \
-o $title'_'$variant'_'$locale'_'$arch'_'$data.iso \
-I ../includedir

#create hash file
HASH=`sha256sum $title'_'$variant'_'$locale'_'$arch'_'$data.iso`
echo $HASH > $title'_'$variant'_'$locale'_'$arch'_'$data.sha256

# change back the owner for includedir
cd ..
chown florin:florin -R includedir

sync
