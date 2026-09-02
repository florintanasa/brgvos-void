#!/usr/bin/env bash

. ./void-mklive/lib.sh

# Check for root permissions.
if [ "$(id -u)" -ne 0 ]; then
    die "Must be run as root, exiting..."
fi

# set the date and time
data=$(date +'%d%m%Y_%H%M%S')

# get user name
username=$(logname)

# get evo parameter
EVO=$1

# change the owner for includedir
info_msg "Change the owner to root for 'includedir' directory"
chown root:root -R includedir

# change working directory
info_msg "Change working directory to 'void-mklive'" 
cd void-mklive

# Read the flags used for build the iso
if [ "$EVO" = evo ]; then
    info_msg "Read the flags used for build the iso for Slimbook EVO"
    arch=$(cat ../arch)
    variant=$(cat ../variant)
    keymap=$(cat ../keymap)
    locale=$(cat ../locale)
    root_shell=$(cat ../root_shell)
    linux_version=$(cat ../linux_version_evo)
    title=$(cat ../title)
    service=$(cat ../services_evo)
    main_repo=$(cat ../main-repo)
    brgvos_repo=$(cat ../brgvos-current-repo)
    brgvos_test_repo=$(cat ../brgvos-test-repo)
    name_file="${title}_${variant}_${locale}_Slimbook_EVO_${arch}_${data}.iso"
else 
    info_msg "Read the flags used for build the iso"
    arch=$(cat ../arch)
    variant=$(cat ../variant)
    keymap=$(cat ../keymap)
    locale=$(cat ../locale)
    root_shell=$(cat ../root_shell)
    linux_version=$(cat ../linux_version)
    title=$(cat ../title)
    service=$(cat ../services)
    main_repo=$(cat ../main-repo)
    brgvos_repo=$(cat ../brgvos-current-repo)
    brgvos_test_repo=$(cat ../brgvos-test-repo)
    name_file="${title}_${variant}_${locale}_${arch}_${data}.iso"
fi

# Prepare variables for Romanian language
if [ "$locale" = ro_RO.UTF-8 ]; then
    info_msg "Prepare variables for Romanian language"
    #other_pkg=$(cat ../other_pkg)
    other_pkg=$(cat ../other_pkg_apps_media)
    other_pkg+=$(cat ../other_pkg_compatibility)
    other_pkg+=$(cat ../other_pkg_dev_build)
    other_pkg+=$(cat ../other_pkg_networking_security)
    other_pkg+=$(cat ../other_pkg_office)
    other_pkg+=$(cat ../other_pkg_printing_scanning)
    other_pkg+=$(cat ../other_pkg_sys_core)
    other_pkg+=$(cat ../other_pkg_utils)
    other_pkg+=$(cat ../brgvos-desktop-themes-pkg)
    other_pkg+=$(cat ../brgvos-gnome-extensions-pkg)
    other_pkg+=$(cat ../brgvos-includedir-pkg)
    other_pkg+=$(cat ../other_pkg_ro)
    [ "$EVO" = evo ] &&  other_pkg+=$(cat ../other_pkg_evo)
    [ "$EVO" = evo ] &&  kernel_arg=$(cat ../kernel_arg_ro_evo) || kernel_arg=$(cat ../kernel_arg_ro)
fi

# Prepare variables and change the name of menu for English USA language
if [ "$locale" = en_US.UTF-8 ]; then
    # Change the name of menus in Gnome
    info_msg "Change the name of menus in Gnome"
    sed -i "s/name='Setări teme'/name='Themes settings'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Birou'/name='Office'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Grafică'/name='Graphics'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Programare'/name='Programming'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Accesorii'/name='Accessories'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/'name': 'Programare'/'name': 'Programming'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Sistem'/'name': 'System'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Birou'/'name': 'Office'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Grafică'/'name': 'Graphics'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Accesorii'/'name': 'Accessories'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Setări teme'/'name': 'Themes settings'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    # Change the default keyboard in Gnome from 'ro' to 'us' 
    info_msg "Change the default keyboard in Gnome from 'ro' to 'us'"
    sed -i "s/sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/sources=[('xkb', 'us')]/g"  ../includedir/etc/dconf/db/local.d/01-input-sources
    sed -i "s/mru-sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/mru-sources=[('xkb', 'us')]/g"  ../includedir/etc/dconf/db/local.d/01-input-sources 
    # Prepare variables for English USA language
    info_msg "Prepare variables for English USA language"
    #other_pkg=$(cat ../other_pkg)
    other_pkg=$(cat ../other_pkg_apps_media)
    other_pkg+=$(cat ../other_pkg_compatibility)
    other_pkg+=$(cat ../other_pkg_dev_build)
    other_pkg+=$(cat ../other_pkg_networking_security)
    other_pkg+=$(cat ../other_pkg_office)
    other_pkg+=$(cat ../other_pkg_printing_scanning)
    other_pkg+=$(cat ../other_pkg_sys_core)
    other_pkg+=$(cat ../other_pkg_utils)
    other_pkg+=$(cat ../brgvos-desktop-themes-pkg)
    other_pkg+=$(cat ../brgvos-gnome-extensions-pkg)
    other_pkg+=$(cat ../brgvos-includedir-pkg)
    other_pkg+=$(cat ../other_pkg_en_US)
    [ "$EVO" = evo ] &&  other_pkg+=$(cat ../other_pkg_evo)
    [ "$EVO" = evo ] &&  kernel_arg=$(cat ../kernel_arg_en_US_evo) || kernel_arg=$(cat ../kernel_arg_en_US)
fi

# Run void linux script to build iso file image
info_msg "Now I run 'mkiso.sh' with the flags prepared before"
sudo ./mkiso.sh \
-a $arch \
-b $variant \
-L $locale \
-r $main_repo \
-r $brgvos_repo \
-r $brgvos_test_repo \
-- -k $keymap \
-B $variant \
-l $locale \
-e $root_shell \
-v $linux_version \
-T $title \
-C "$kernel_arg" \
-p "$other_pkg" \
-S "$service" \
-o "$name_file" \
-I ../includedir

# Create hash file and move the files to iso directory
if [ -e $title'_'$variant'_'$locale'_'$arch'_'$data.iso ]
    then
        info_msg "Create hash file and move the files to '../iso_build' directory"
        HASH=`sha256sum $title'_'$variant'_'$locale'_'$arch'_'$data.iso`
        echo $HASH > $title'_'$variant'_'$locale'_'$arch'_'$data.sha256
        # Run sync to be sure the file was finished to written
        info_msg "Run sync to be sure the file was finished to written"
        sync
        # Move the files to '../iso_build' directory
        info_msg "Move the files to '../iso_build' directory"
        mv $title'_'$variant'_'$locale'_'$arch'_'$data.iso ../iso_build
        mv $title'_'$variant'_'$locale'_'$arch'_'$data.sha256 ../iso_build
elif [ -e ${title}_${variant}_${locale}_Slimbook_EVO_${arch}_${data}.iso ]
    then
        info_msg "Create hash file and move the files to '../iso_build' directory"
        HASH=`sha256sum $title'_'$variant'_'$locale'_'Slimbook_EVO_$arch'_'$data.iso`
        echo $HASH > $title'_'$variant'_'$locale'_'Slimbook_EVO_$arch'_'$data.sha256
        # Run sync to be sure the file was finished to written
        info_msg "Run sync to be sure the file was finished to written"
        sync
        # Move the files to '../iso_build' directory
        info_msg "Move the files to '../iso_build' directory"
        mv $title'_'$variant'_'$locale'_'Slimbook_EVO_$arch'_'$data.iso ../iso_build
        mv $title'_'$variant'_'$locale'_'Slimbook_EVO_$arch'_'$data.sha256 ../iso_build
    else
        echo "File $title'_'$variant'_'$locale'_'$arch'_'$data.iso not exist, so not create the sha256 file for this"
fi

# Revert to the default Romania language
if [ "$locale" = en_US.UTF-8 ]; then
    info_msg "Revert to the default Romania language"
    sed -i "s/name='Themes settings'/name='Setări teme'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Office'/name='Birou'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Graphics'/name='Grafică'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Programming'/name='Programare'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Accessories'/name='Accesorii'/g" ../includedir/etc/dconf/db/local.d/27-app-folders
    sed -i "s/'name': 'Programming'/'name': 'Programare'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'System'/'name': 'Sistem'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Office'/'name': 'Birou'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Graphics'/'name': 'Grafică'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Accessories'/'name': 'Accesorii'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Themes settings'/'name': 'Setări teme'/g" ../includedir/etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/sources=\[('xkb', 'us')]\s*/sources=[('xkb', 'ro'), ('xkb', 'us')]/g"  ../includedir/etc/dconf/db/local.d/01-input-sources
    sed -i "s/mru-sources=[('xkb', 'us')]\s*/mru-sources=\[('xkb', 'ro'), ('xkb', 'us')]/g"  ../includedir/etc/dconf/db/local.d/01-input-sources 
fi

# Change back the owner for includedir and iso directories
info_msg "Change back the owner for 'includedir' and 'iso_build' directories"
cd ..
chown $username:$username -R includedir
chown $username:$username -R iso_build

# Run sync to be sure the file was finished to written
info_msg "Run sync to be sure the file was finished to written"
sync

# Final message
printf "Next files exist in './iso_build' directory:\n$(ls ./iso_build)\n"