#!/usr/bin/env bash

# change working directory
cd void-mklive
# flas used for build the iso
arch=$(cat ../arch)
variant=$(cat ../variant)
keymap=$(cat ../keymap)
locale=$(cat ../locale)
root_shell=$(cat ../root_shell)
linux_version=$(cat ../linux_version)
title=$(cat ../title)
kernel_arg=$(cat ../kernel_arg)
# run void linux script to build iso iamge with our distribution
sudo ./mkiso.sh \
-a $arch \
-b $variant \
-- -k $keymap \
-l $locale \
-e $root_shell \
-v $linux_version \
-T $title \
-C $kernel_arg 

