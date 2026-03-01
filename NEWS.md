# What is news?
## 26022026
The installer has reached version 0.31 with new options for hardening:
* AppArmor;
* Audit;
* Hardening(sysctl)

Also, English or Romanian version have now support for the next language, in alphabetic order:

* Chinese (Taiwanese), script `set_zh_TW.UTF-8_gnome.sh`;
* French, script `set_fr_FR.UTF-8_gnome.sh`;
* German, script `set_de_DE.UTF-8_gnome.sh`;
* Italian, script `set_it_IT.UTF-8_gnome.sh`;
* Portuguese (Brasilian), script `set_pt_BR.UTF-8_gnome.sh`;
* Portuguese (Portugal), script `set_pt_PT.UTF-8_gnome.sh`;
* Romanian, script `set_ro_RO.UTF-8_gnome.sh`;
* Russian, script `set_ru_RU.UTF-8_gnome.sh`;
* Spanish, script `set_es_ES.UTF-8_gnome.sh`;
  
These scripts add support for the languager for the user or/and for the system, set translate menus, and set the keyboard. Also, can switch between languages but through `English`, for example, to switch from `Russian` to `French` do the next steps: firstly, switch to `English` and then to `French`, using script `set_ru_RU.UTF-8_gnome.sh`.

Now flatpak have 3 repos:  

* flathub, https://dl.flathub.org/repo/flathub.flatpakrepo
* flathub-beta, https://flathub.org/beta-repo/flathub-beta.flatpakrepo
* gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo

## 20122025
The installer has reached version 0.30.  
The major change is that, installations can now be performed on partitions encrypted with LUKS and/or organized by LVM or/and into RAID array.  
**BRGV-OS** can now be installed on:
* Clasical, on partitions;
* LUKS - Full Encrypt mode, where all partitions are encrypted;
* LUKS - Not Full Encrypt mode, where the /boot partition is not encrypted;
* LVM, where partitions is organized on volumes group and logical volumes;
* RAID, where partitions is organized on an array RAID 0, 1, 4, 5, 6 or 10;
* multi-RAID, where partitions is organized on an arrays multi-RAID ( example RAID 1 for / and RAID 0 for /home);
* nested RAID, where partitions is organized on an RAID 50 or RAID 60 (example 2 x RAID 5 with RAID 0);
* LVM on RAID;
* LVM on LUKS - Full Encrypt mode;
* LVM on LUKS - Not Full Encrypt mode;
* LVM on LUKS on RAID - Full Encrypt mode;
* LVM on LUKS on RAID - Not Full Encrypt mode;
* LVM on RAID on LUKS - Full Encrypt mode;
* LVM on RAID on LUKS - Not Full Encrypt mode;
* LUKS on RAID - Full Encrypt mode;
* LUKS on RAID - Not Full Encrypt mode;
* RAID on LUKS - Full Encrypt mode;
* RAID on LUKS - Not Full Encrypt mode;

Linux partitions can be formatted as btrfs with compression option and created automatically subvolume (@, @home, @var_log, @var_lib and @snapshots), ext4/3/2, xfs, f2fs or f2fs with compress and lazytime options (f2fs is usefully for NAND memory devices like SSD, eMMC, USB etc.)  

Also brgvos-installer now detect better the disks used for partitions are SSD or HDD and prepare options for fstab.

## 08112025
The installer has reached version 0.29; brgvos-installer have now new options and installations can now be performed on partitions encrypted with LUKS and/or organized by LVM.  
Linux partitions can be formatted as btrfs with compression option and created automatically subvolume (@, @home, @var_log, @var_lib and @snapshots), ext4/3/2, xfs OR f2fs.

## 28092025
The installer has version 0.28 and brgvos-installer have new color theme.
Linux partitions can be formatted as btrfs with compression option and was added two new options: btrfs_lvm and btrfs_lvm_luks, also for theese created automatically subvolume (@, @home, @var_log, @var_lib and @snapshots)

## 08092025
The installer has version 0.27.
Linux partitions can be formatted as btrfs with compression option and created automatically subvolume (@, @home, @var_log, @var_lib and @snapshots)