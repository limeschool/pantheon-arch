#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="elementaryOS"
iso_label="elementary_$(date +%Y%m)"
iso_publisher="elementaryOS"
iso_application="elementaryOS Live Environment"
iso_version="$(date +%Y.%m.%d)"
install_dir="elementary"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
