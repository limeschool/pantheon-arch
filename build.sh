#!/bin/bash
export HOME=~
export PROFILE=${HOME}/elementary-profile
export LOCAL_REPO=${HOME}/local-repo
set +h
umask 0022 # Correct file permissions
systemd-machine-id-setup # Prevents errors when building AUR packages

pacman -Syu archiso git base-devel jq expac diffstat pacutils wget devtools libxslt cmake \
intltool gtk-doc gobject-introspection gnome-common polkit dbus-glib libhandy \
meson plank vala gnome-settings-daemon --noconfirm --noprogressbar # Install packages we'll need to build

# Allow us to use a standard user account w/ password-less sudo privilege (for building AUR packages later)
tee -a /etc/sudoers > /dev/null <<EOT
nobody    ALL=(ALL) NOPASSWD:ALL
EOT

# Install aurutils to build our local repository from AUR packages
git clone https://aur.archlinux.org/aurutils.git
chmod 777 aurutils
cd aurutils
su -s /bin/sh nobody -c "makepkg -si --noconfirm --noprogressbar" # Make aurutils as a regular user
cd ../

# Begin setting up our profile
cp -r /usr/share/archiso/configs/releng/ ${PROFILE}
cp -rf ./elementary/. ${PROFILE}
mkdir ${LOCAL_REPO}
repo-add ${LOCAL_REPO}/custom.db.tar.xz
chmod -R 777 ${LOCAL_REPO}
sed -i -e "s?~/local-repo?${LOCAL_REPO}?" ${PROFILE}/pacman.conf

# Add packages to our local repository (shared between host and profile)
cp -f ${PROFILE}/pacman.conf /etc
mkdir //.cache && chmod 777 //.cache # Since we can't run 'aur sync' as sudo, we have to make the cache directory manually
pacman -Rdd gsettings-desktop-schemas
su -s /bin/sh nobody -c "aur sync -d custom --root ${LOCAL_REPO} --no-confirm --noview \
ttf-raleway \
gnome-doc-utils \
libhandy1 \
pantheon-screencast \
pantheon-system-monitor-git \
yay \
ttf-twemoji-color \
elementary-icon-theme-git \
elementary-wallpapers-git \
pantheon-applications-menu-git \
gtk-theme-elementary-git \
pantheon-default-settings-git \
pantheon-session-git \
switchboard-plug-elementary-tweaks-git \
pantheon-calculator-git \
pantheon-calendar-git \
pantheon-camera-git \
pantheon-files-git \
pantheon-music-git \
pantheon-photos-git \
pantheon-screenshot-git \
pantheon-shortcut-overlay-git \
pantheon-terminal-git \
pantheon-videos-git \
switchboard-git \
switchboard-plug-a11y-git \
switchboard-plug-about-git \
switchboard-plug-applications-git \
switchboard-plug-bluetooth-git \
switchboard-plug-datetime-git \
switchboard-plug-desktop-git \
switchboard-plug-display-git \
switchboard-plug-keyboard-git \
switchboard-plug-locale-git \
switchboard-plug-mouse-touchpad-git \
switchboard-plug-network-git \
switchboard-plug-notifications-git \
switchboard-plug-online-accounts-git \
switchboard-plug-parental-controls-git \
switchboard-plug-power-git \
switchboard-plug-printers-git \
switchboard-plug-security-privacy-git \
switchboard-plug-sharing-git \
switchboard-plug-sound-git \
switchboard-plug-user-accounts-git \
wingpanel-indicator-bluetooth-git \
wingpanel-indicator-datetime-git \
wingpanel-indicator-keyboard-git \
wingpanel-indicator-network-git \
wingpanel-indicator-nightlight-git \
wingpanel-indicator-notifications-git \
wingpanel-indicator-power-git \
wingpanel-indicator-session-git \
wingpanel-indicator-sound-git \
pantheon-mail-git"

echo -e "LOCAL_REPO:\n---"
ls ${LOCAL_REPO}
echo "---"

# Add packages from Arch's repositories to our profile
tee -a ${PROFILE}/packages.x86_64 > /dev/null <<EOT
archlinux-appstream-data
capnet-assist
contractor
cups
cups-pk-helper
elementary-icon-theme-git
elementary-wallpapers-git
epiphany
file-roller
flatpak
gala
gdm
#geary
glfw-wayland
gnome-control-center
gnome-disk-utility
gnome-keyring
gnome-shell
gnome-software
gnome-software-packagekit-plugin
gnome-user-share
gnu-free-fonts
gtk-engine-murrine
gtk-theme-elementary-git
gtkspell3
gvfs
gvfs-afc
gvfs-gphoto2
gvfs-mtp
gvfs-nfs
gvfs-smb
intel-tbb
intel-ucode
libva
libva-mesa-driver
mesa
mutter
networkmanager
noto-fonts
noto-fonts-emoji
nvidia-dkms
orca
pacman-contrib
pantheon-applications-menu-git
pantheon-calculator-git
pantheon-calendar-git
pantheon-camera-git
pantheon-code
pantheon-default-settings-git
pantheon-dpms-helper
pantheon-files-git
pantheon-geoclue2-agent
pantheon-mail-git
pantheon-music-git
pantheon-photos-git
pantheon-polkit-agent
pantheon-print
pantheon-screencast
pantheon-screenshot-git
pantheon-session-git
pantheon-shortcut-overlay-git
pantheon-system-monitor-git
pantheon-terminal-git
pantheon-videos-git
plank
pulseaudio-bluetooth
qt5-svg
qt5-translations
qt5-wayland
rygel
sound-theme-elementary
switchboard-git
switchboard-plug-a11y-git
switchboard-plug-about-git
switchboard-plug-applications-git
switchboard-plug-bluetooth-git
switchboard-plug-datetime-git
switchboard-plug-desktop-git
switchboard-plug-display-git
switchboard-plug-elementary-tweaks-git
switchboard-plug-keyboard-git
switchboard-plug-locale-git
switchboard-plug-mouse-touchpad-git
switchboard-plug-network-git
switchboard-plug-notifications-git
switchboard-plug-online-accounts-git
switchboard-plug-parental-controls-git
switchboard-plug-power-git
switchboard-plug-printers-git
switchboard-plug-security-privacy-git
switchboard-plug-sharing-git
switchboard-plug-sound-git
switchboard-plug-user-accounts-git
tracker
tracker-miners
tracker3
tracker3-miners
ttf-dejavu
ttf-droid
ttf-hack
ttf-liberation
ttf-opensans
ttf-raleway
ttf-roboto-mono
ttf-twemoji-color
vala
vulkan-radeon
wayland
wayland-protocols
wingpanel
wingpanel-indicator-bluetooth-git
wingpanel-indicator-datetime-git
wingpanel-indicator-keyboard-git
wingpanel-indicator-network-git
wingpanel-indicator-nightlight-git
wingpanel-indicator-notifications-git
wingpanel-indicator-power-git
wingpanel-indicator-session-git
wingpanel-indicator-sound-git
wlc
xdg-user-dirs-gtk
xf86-input-libinput
xorg
xorg-drivers
xorg-server
xorg-server-xwayland
xorg-twm
xorg-xclock
xorg-xinit
xterm
yay

## VirtualBox
virtualbox-guest-utils
EOT

rm -f ${PROFILE}/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf # Remove autologin

# Enable our daemons
mkdir -p ${PROFILE}/airootfs/etc/systemd/system/multi-user.target.wants
mkdir -p ${PROFILE}/airootfs/etc/systemd/system/sockets.target.wants
mkdir -p ${PROFILE}/airootfs/etc/systemd/system/bluetooth.target.wants
mkdir -p ${PROFILE}/airootfs/etc/modules-load.d
ln -s /lib/systemd/system/gdm.service ${PROFILE}/airootfs/etc/systemd/system/display-manager.service
ln -s /lib/systemd/system/NetworkManager.service ${PROFILE}/airootfs/etc/systemd/system/multi-user.target.wants
ln -s /lib/systemd/system/cups.socket ${PROFILE}/airootfs/etc/systemd/system/sockets.target.wants
ln -s /lib/systemd/system/avahi-daemon.socket ${PROFILE}/airootfs/etc/systemd/system/sockets.target.wants
ln -s /lib/systemd/system/bluetooth.service ${PROFILE}/airootfs/etc/systemd/system/bluetooth.target.wants
ln -s /lib/modules-load.d/virtualbox-guest-dkms.conf ${PROFILE}/airootfs/etc/modules-load.d

# Set up Pantheon environment
mkdir -p ${PROFILE}/airootfs/usr/share/backgrounds
mkdir -p ${PROFILE}/airootfs/etc/xdg/autostart
ln -s '/usr/share/backgrounds/Sunset by the Pier.jpg' ${PROFILE}/airootfs/usr/share/backgrounds/elementaryos-default # Set default background
ln -s /usr/share/applications/plank.desktop ${PROFILE}/airootfs/etc/xdg/autostart/plank.desktop # Set Plank to start automatically

# Build & bundle the disk image
mkdir ./out
mkdir /tmp/archiso-tmp
mkarchiso -v -w /tmp/archiso-tmp ${PROFILE}
mv ./out/elementaryOS-*.*.*-x86_64.iso ~
