# BRGV-OS

BRGV-OS is a custom [Void Linux](https://voidlinux.org/) based distribution that aims to facilitate developers and users to transitioning from Windows to Linux by maintaining familiar operational habits and workflows.

## How to build

It is suggested to use Void Linux or other based by this distribution.  
To build the iso image is necessary to use a Void Linux distribution where we run next commands:  

> [!IMPORTANT]  
> In this moment the build is for romanian language only, but with few modifications can be buildid for antohers.

```bash
git clone https://github.com/florintanasa/brgvos-void.git
cd brgvos-void
sudo ./build_brgvos.sh
```  

After that, if everythink works, we find the iso image is in directory `void-mklive`

ISO file can be downloaded from [here](https://sourceforge.net/projects/brgv-os/files/brgv-os-2025/) 

Test ISO file result in virtual machine.
Next video is a example...  

[<img src="https://img.youtube.com/vi/QVdH_dGIyOQ/maxresdefault.jpg" width="400" height="280"
/>](https://www.youtube.com/embed/QVdH_dGIyOQ)

## How to install applications

Using `xbs` packages manager:

```bash
sudo xbps-install -S <name_package>
```

Using `nix` packages manager:
```bash
# install nix packages manager
sudo xbps-install -S nix
# enable the nix service
sudo ln -s /etc/sv/nix-daemon /var/service/
# start the nix service
sudo sv up nix-daemon
# check the states of the services
sudo vsv
# load the profile without logout-login
source /etc/profile
# add the channels
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
# update the chanels
nix-channel --update
# check the list with channels 
nix-channel --list
# create soft link to applications to be loaded on menu
ln -s "$HOME/.nix-profile/share/applications" "$HOME/.local/share/applications/nix-env"
# example to install - pgmodeler
nix-env -iA nixpkgs.pgmodeler
# start the application
pgmodeler
```

Using `flatpak`:
We can search the applications on https://flathub.org/ and then we can install manualy:

```bash
flatpak install flathub org.gnome.gitlab.somas.Apostrophe
```

or we can use `gnome-software` Application Gui.

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

## Warning 

The open-source software included in **BRGV-OS** is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**.

The work is progress..

<!-- https://github.com/scopatz/nanorc -->
