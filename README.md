# $\textcolor{cyan}{\texttt{ {BRGV-OS}}}$ [<img src="https://img.shields.io/sourceforge/dt/brgv-os.svg" />](https://sourceforge.net/projects/brgv-os/files/brgv-os-2025/) [<img src="./screenshots/bandage_sourceforge_dark.png" width="106" height="106" />](https://sourceforge.net/projects/brgv-os/) ![Rank on https://distrowatch.com](https://img.shields.io/badge/Rank_374_Last_6_months-0?style=flat&label=Distrowatch)



**BRGV-OS** is a custom [Void Linux](https://voidlinux.org/) based distribution that aims to facilitate developers, researchers and users to transitioning from Windows&#174; or macOS&#174; to Linux&#174; by maintaining familiar operational habits and workflows.  
This work was do it for our job needs at Gene Bank research institute from Suceava, Romania, but anyone can use or modify for their needs.  
The name **BRGV** is an acronym from Romanian "**B**anca de **R**esurse **G**enetice **V**egetale" (shortly in English Gene Bank), and **OS** mean, of course, **O**perating **S**ystem.  
  
|                     Theme Light                                     |                         Theme Dark                               |
|:-------------------------------------------------------------------:|:----------------------------------------------------------------:|
|![BRGV-OS Light](./screenshots/screeshot_1.png "BRGV-OS Light Theme")|![BRGV-OS Dark](./screenshots/screenshot_1_dark.png "BRGV-OS Dark Theme")|

|                                                        |                                                        |
|:------------------------------------------------------:|:------------------------------------------------------:|
|![BRGV-OS 1](./screenshots/screenshot_2.png "BRGV-OS 1")|![BRGV-OS 2](./screenshots/screenshot_3.png "BRGV-OS 2")|

**BRGV-OS** have now 10 themes, 2 for users what prefers classical style and 8 for the users what prefers Unix&#174; style, look at next movie:  
    

[<img src="https://img.youtube.com/vi/EDnMTKS-B8k/maxresdefault.jpg" width="960" height="510"/>](https://www.youtube.com/embed/EDnMTKS-B8k?autoplay=1&mute=1)

For theme management I wrote the following extensions, scripts and menus:

* [Accent gtk theme](https://extensions.gnome.org/extension/8497/accent-gtk-theme/), it is a `Gnome™` extension that changes the gtk app theme, based on the accent color chosen by the user in `Gnome Settings`, `Appearance screen` and by preferred `color schema`, `Light` or `Dark`, source code [here](https://github.com/florintanasa/accent-gtk-theme);
* [Accent icons theme](https://extensions.gnome.org/extension/8499/accent-icons-theme/), it is a `Gnome™` extension that changes the icons themes, based on the `accent color` chosen by the user in `Gnome Settings` (gnome-control-center), `Appearance` screen and by preferred `color schema`, `Light` or `Dark`, source code [here](https://github.com/florintanasa/accent-icons-theme);
* [Accent user theme](https://extensions.gnome.org/extension/8498/accent-user-theme/), it is a `Gnome™` extension that changes the user's theme based on the accent color chosen by the user in `Gnome Settings`, `Appearance` screen and by preferred `color schema`, `Light` or `Dark`, source code [here](https://github.com/florintanasa/accent-user-theme);
* [Light/Dark cursor theme](https://extensions.gnome.org/extension/8496/lightdark-cursor-theme/), it is a `Gnome™` extension that changes the cursor themes, based on the preferred `color schema`, `Light` or `Dark`, source code [here](https://github.com/florintanasa/light-dark-cursor-theme);
* And 10 [scripts](https://github.com/florintanasa/brgvos-void/tree/main/includedir/usr/local/bin), these are called by 10 [menus](https://github.com/florintanasa/brgvos-void/tree/main/includedir/usr/local/share/applications).
  
Also **BRGV-OS** have another extension [Set Notification Banner Position](https://extensions.gnome.org/extension/8495/set-notification-banner-position/), it is a `Gnome™` extension that changes the position of the banner notification on the sreen, source code [here](https://github.com/florintanasa/set-notification-position).

## $\textcolor{teal}{\texttt{How to build}}$

It is suggested to use **Void Linux** or an others based on this distribution, also **BRGV-OS** work :)  
Default start the build for Romanian language, if you wish to build for international English USA language edit file `locale` and change from `ro_RO.UTF-8` to `en_US.UTF-8` and also edit file `keymap` and change from `ro` to `us`.  
That's it.  
If you wish to build for your language, take a look at file `build_brgvos.sh` how I do it from English USA language and Romanian language.
To build the iso image, it is necessary to use a based **Void Linux** distribution or **BRGV-OS** (is a spin **Void Linux**) where we run next commands:  

```bash
git clone --recurse-submodules https://github.com/florintanasa/brgvos-void.git
cd brgvos-void
sudo ./build_brgvos.sh
```  
  
After that, if everything works ok, we find the iso image is in directory `iso build`.
  
> [!IMPORTANT]  
> In this moment the build is for ro_RO (Romanian language) and en_US (English USA language) , but with few modifications can be buildid for anothers.  
> Exist iso images files for: ro_RO.UTF-8 and en_US.UTF-8.  
> ISO files can be downloaded from:  
> here [![Download BRGV-OS iso ro_RO version](https://img.shields.io/sourceforge/dm/brgv-os.svg)](https://sourceforge.net/projects/brgv-os/files/brgv-os-2025/ro_RO/BRGV-OS_gnome_ro_RO.UTF-8_x86_64_20122025_110755.iso/download) for **ro_RO** versions   
> or  
> here [![Download BRGV-OS iso en_US version](https://img.shields.io/sourceforge/dm/brgv-os.svg)](https://sourceforge.net/projects/brgv-os/files/brgv-os-2025/en_US/BRGV-OS_gnome_en_US.UTF-8_x86_64_20122025_112057.iso/download) for **en_US** version   
> and  
> SHA256 files can be downloaded from:  
> here [![Download BRGV-OS sha256 ro_RO version](https://img.shields.io/sourceforge/dm/brgv-os.svg)](https://sourceforge.net/projects/brgv-os/files/brgv-os-2025/ro_RO/BRGV-OS_gnome_ro_RO.UTF-8_x86_64_20122025_110755.sha256/download) for **ro_RO** versions  
> or  
> here [![Download BRGV-OS sha256 en_US version](https://img.shields.io/sourceforge/dm/brgv-os.svg)](https://sourceforge.net/projects/brgv-os/files/brgv-os-2025/en_US/BRGV-OS_gnome_en_US.UTF-8_x86_64_20122025_112057.sha256/download) for **en_US** version 
    
> [!NOTE]  
> The installer has reached version 0.30.  
> The major change is that, installations can now be performed on partitions encrypted with LUKS and/or organized by LVM or/and into RAID array.  
>**BRGV-OS** can now be installed on:
> * Clasical, on partitions;
> * LUKS - Full Encrypt mode, where all partitions are encrypted;
> * LUKS - Not Full Encrypt mode, where the /boot partition is not encrypted;
> * LVM, where partitions is organized on volumes group and logical volumes;
> * RAID, where partitions is organized on a array RAID 0, 1, 4, 5, 6 or 10;
> * multi RAID, where partitions is organized on a arrays multi RAID ( expl. RAID 1 for / and RAID 0 for /home);
> * nested RAID, where partitions is organized on a RAID 50 or RAID 60 (expl 2xRAID 5 with RAID 0);
> * LVM on RAID;
> * LVM on LUKS - Full Encrypt mode;
> * LVM on LUKS - Not Full Encrypt mode;
> * LVM on LUKS on RAID - Full Encrypt mode;
> * LVM on LUKS on RAID - Not Full Encrypt mode;
> * LVM on RAID on LUKS - Full Encrypt mode;
> * LVM on RAID on LUKS - Not Full Encrypt mode;
> * LUKS on RAID - Full Encrypt mode;
> * LUKS on RAID - Not Full Encrypt mode;
> * RAID on LUKS - Full Encrypt mode;
> * RAID on LUKS - Not Full Encrypt mode;
>   
>Linux partitions can be formatted as btrfs with compression option and careated automatically subvolume (@, @home, @var_log, @var_lib and @snapshots), ext4/3/2, xfs, f2fs or f2fs with compress and lazytime options (f2fs is usefully for NAND memory devices like SSD, eMMC, USB etc.)
>  
>Also brgvos-installer detect the disks used for partitions are SSD or HDD and prepare options for fstab.
>
>Space need to install BRGV-OS on disk depend by file systems used if is compressed or not, less need btrfs because is used compress option and more needs f2fs with compression, approximate 32GB (Compress in f2fs file system is not the same compression we are know from btrfs, for example, read more on the [article_1](https://wiki.archlinux.org/title/F2FS), [article_2](https://docs.kernel.org/filesystems/f2fs.html#compression-implementation)) 
>
>Since the installer is a separate project, I decided to start a new repository at https://github.com/florintanasa/brgvos-installer where you can find more information about it and the installation modes. 
  
> [!TIP]  
>Next videos are demos with the last BRGV-OS release (brgvos-installer v.0.30):
>
>|<sub>BRGV-OS on f2fs for /boot<br> and f2fs with compression for /</sub>|<sub>BRGV-OS on ext4 partition</sub>|<sub>BRGV-OS on LUKS<br> full encrypted</sub>|
>|:-----:|:-----:|:-----:|
>|[<img src="https://img.youtube.com/vi/MVFGRUu0l4U/default.jpg" width="250" height="150"/>](https://youtu.be/MVFGRUu0l4U?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/lqNkJYiVOdg/default.jpg" width="250" height="150"/>](https://youtu.be/lqNkJYiVOdg?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/eGeGn1PlMaE/default.jpg" width="250" height="150"/>](https://youtu.be/eGeGn1PlMaE?autoplay=1&mute=1)|
>
>|<sub>BRGV-OS on LVM</sub>|<sub>BRGV-OS on LUKS<br>not full encrypted</sub>|<sub>BRGV-OS on multi RAID<br> (1 for / and 0 for /home)</sub>|
>|:-----:|:-----:|:-----:|
>|[<img src="https://img.youtube.com/vi/BxnWNKCkgm4/default.jpg" width="250" height="150"/>](https://youtu.be/BxnWNKCkgm4?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/t75vSd_-8rU/default.jpg" width="250" height="150"/>](https://youtu.be/t75vSd_-8rU?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/Ij_Wz8dlawI/default.jpg" width="250" height="150"/>](https://youtu.be/Ij_Wz8dlawI?autoplay=1&mute=1)|
>  
>|<sub>BRGV-OS on LVM on LUKS<br>full encrypted mode</sub>|<sub>BRGV-OS on LVM on LUKS<br>not full encrypt</sub>|<sub>BRGV-OS on RAID 10</sub>|
>|:-----:|:-----:|:-----:|
>|[<img src="https://img.youtube.com/vi/6r3plQUnhfI/default.jpg" width="250" height="150"/>](https://youtu.be/6r3plQUnhfI?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/d5X1L_dO-LY/default.jpg" width="250" height="150"/>](https://youtu.be/d5X1L_dO-LY?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/D9DJDQDAAEc/default.jpg" width="250" height="150"/>](https://youtu.be/D9DJDQDAAEc?autoplay=1&mute=1)|
>
>|<sub>BRGV-OS on nested RAID 50 on LUKS<br>full encrypt mode</sub>|<sub>BRGV-OS on nested RAID 60 on LUKS<br>not full encrypt mode</sub>|<sub>BRGV-OS on LVM on RAID 10 on LUKS<br>not full encrypt</sub>|
>|:-----:|:-----:|:-----:|
>|[<img src="https://img.youtube.com/vi/_qtYV_B-U98/default.jpg" width="250" height="150"/>](https://youtu.be/_qtYV_B-U98?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/Be90tRTai8U/default.jpg" width="250" height="150"/>](https://youtu.be/Be90tRTai8U?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/iWlfl5GbRr0/default.jpg" width="250" height="150"/>](https://youtu.be/iWlfl5GbRr0?autoplay=1&mute=1)|
>
>|<sub>BRGV-OS on LVM on LUKS on RAID 10<br>not full encrypt mode</sub>|<sub>BRGV-OS on LVM  on RAID 10 on LUKS<br>full encrypt mode</sub>|<sub>BRGV-OS on LVM on LUKS on RAID 10<br>full encrypt mode</sub>|
>|:-----:|:-----:|:-----:|
>|[<img src="https://img.youtube.com/vi/xmN5mtRYpws/default.jpg" width="250" height="150"/>](https://youtu.be/xmN5mtRYpws?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/b3wHBfKkYb4/default.jpg" width="250" height="150"/>](https://youtu.be/b3wHBfKkYb4?autoplay=1&mute=1)|[<img src="https://img.youtube.com/vi/x6ykRLSbM9I/default.jpg" width="250" height="150"/>](https://youtu.be/x6ykRLSbM9I?autoplay=1&mute=1)|
>
>|<sub>BRGV-OS on LUKS on RAID 10<br>not full encrypt mode</sub>|
>|:-----:|
>|[<img src="https://img.youtube.com/vi/8YguTnGS8J8/default.jpg" width="250" height="150"/>](https://youtu.be/8YguTnGS8J8?autoplay=1&mute=1)|
  
> [!TIP]  
>Next videos are demos for the old BRGV-OS release, but are usefully:
>|<sub>vg0</br>`sda3`+`sdb1`</syb>|<sub>vg1</br>`sdc1`</sub>|<sub>BRGV-OS installed on</br>not full encrypted mode with LVM</sub>|
>|:---:|:---:|:---:|
>|<sub>LVM&LUKS: `LVM`+`LUKS`</br>LVSWAP (GB): `8`</br>LVROTFS (%): `20`</br>LVHOME (%): `60`</br>LVEXTRA-1 (%): `0`</br>LVEXTRA-2 (%): `20`</sub>|<sub>LVM&LUKS: `LVM`+`LUKS`</br>LVSWAP (GB): `0`</br>LVROTFS (%): `0`</br>LVHOME (%): `0`</br>LVEXTRA-1 (%): `100`</br>LVEXTRA-2 (%): `0`</sub>|[<img src="https://img.youtube.com/vi/i-pM3y-Hem0/maxresdefault.jpg" width="250" height="150"/>](https://www.youtube.com/embed/i-pM3y-Hem0?autoplay=1&mute=1)|
> 
>|<sub>vg0</br>`sda2`+`sda3`+`sdb1`</syb>|<sub>vg1</br>`sdc1`</sub>|<sub>BRGV-OS installed on</br>full encryption mode with LVM</sub>|
>|:---:|:---:|:---:|
>|<sub>LVM&LUKS: `LVM`+`LUKS`</br>LVSWAP (GB): `8`</br>LVROTFS (%): `20`</br>LVHOME (%): `60`</br>LVEXTRA-1 (%): `0`</br>LVEXTRA-2 (%): `20`</sub>|<sub>LVM&LUKS: `LVM`+`LUKS`</br>LVSWAP (GB): `0`</br>LVROTFS (%): `0`</br>LVHOME (%): `0`</br>LVEXTRA-1 (%): `100`</br>LVEXTRA-2 (%): `0`</sub>|[<img src="https://img.youtube.com/vi/9Tf47WQGJrQ/maxresdefault.jpg" width="250" height="150"/>](https://www.youtube.com/embed/9Tf47WQGJrQ?autoplay=1&mute=1)|
>
>|<sub>unencrypt:</br>`sda2-swap`</sub>|<sub>BRGV-OS installed on</br>not full encryption mode 1</sub>|
>|:---:|:---:|
>|<sub>LVM&LUKS: `LUKS`</br>sda3->crypt_0</br>sdb1->crypt_1</br>sdc1->crypt_2</br>FS: btrfs</sub>|[<img src="https://img.youtube.com/vi/VYUWoElShNQ/default.jpg" width="250" height="150"/>](https://www.youtube.com/embed/VYUWoElShNQ?autoplay=1&mute=1)|
>
>|<sub>unencrypt:</br>`sda2-swap`+`sda3-/boot`</sub>|<sub>BRGV-OS installed on</br>not full encryption mode 2</sub>|
>|:---:|:---:|
>|<sub>LVM&LUKS: `LUKS`</br>sda4->crypt_0</br>sdb1->crypt_1</br>sdc1->crypt_2</br>FS: ext4</sub>|[<img src="https://img.youtube.com/vi/ggxpwnq2wsw/default.jpg" width="250" height="150"/>](https://www.youtube.com/embed/ggxpwnq2wsw?autoplay=1&mute=1)|
>
>|<sub></sub>|<sub>BRGV-OS installed on</br>"clasical" mode</sub>|
>|:---:|:---:|
>|<sub>LVM&LUKS: `-`</br>sda2->`swap`</br>sda3->/</br>sdb1->/home</br>sdc1->/var/lib/libvirt</br>FS: ext4</sub>|[<img src="https://img.youtube.com/vi/tp_MaYa66VQ/default.jpg" width="250" height="150"/>](https://www.youtube.com/embed/tp_MaYa66VQ?autoplay=1&mute=1)|
>
>
> ### $\textcolor{green}{\texttt{For passphrase is used user password}}$  
>
>
> ### $\textcolor{orange}{\texttt{For how to install, configure and use the BRGV-OS read on}}$ [Wiki](https://github.com/florintanasa/brgvos-void/wiki) 
  
>[!NOTE]  
> Is not in plan to create an iso for each language, because, in my opinion, it is a waste of energy, human and physical (bandwidth consumption, electricity, etc.), to manage a multitude of iso images.  
> The next approach will be to use scripts for each language and which:
> * will add support for the respective language to the system;
> * will modify the menu with the appropriate translation;
> * will add the corresponding keyboard;
> * will apply the changes to the entire system;
> * will apply the changes to the user only;
> * will apply the changes to the entire system and the user.
>
> Will ensure the transition from one language to another through English.
>
> If you wish to contribuite look at next [link](https://github.com/florintanasa/utils/tree/main/patch)  
> In the following link is a [video demonstration](https://youtu.be/pN8bdZ6Hw88).

## $\textcolor{teal}{\texttt{License}}$

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

## $\textcolor{red}{\texttt{Warning}}$ 

The open-source software included in **BRGV-OS** is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**.  
  
## $\textcolor{teal}{\texttt{The following "ingredients" are also included in BRGV-OS}}$
  
https://github.com/vinceliuice/Fluent-gtk-theme  
https://github.com/vinceliuice/Fluent-icon-theme  
https://github.com/vinceliuice/WhiteSur-gtk-theme  
https://github.com/vinceliuice/WhiteSur-icon-theme  
https://github.com/vinceliuice/MacTahoe-gtk-theme  
https://github.com/vinceliuice/MacTahoe-icon-theme  
https://github.com/ohmybash/oh-my-bash  
https://github.com/scopatz/nanorc  
https://github.com/CarterLi/maple-font  
https://github.com/ryanoasis/nerd-fonts  
https://github.com/Anduin2017/AnduinOS/tree/1.4/src/mods/20-deskmon-mod  
https://github.com/voidlinux-br/void-installer  
https://4kwallpapers.com/windows-11-stock-wallpapers/  
https://4kwallpapers.com/ios-26-carplay-wallpapers/  
https://4kwallpapers.com/macos-tahoe-26-stock-wallpapers/  

[List with packages](installed_packages_ro_RO.txt) installed on BRGV-OS version ro_RO (in English is not installed localised packages for Romanian language).

---
  
The work is in progress..



