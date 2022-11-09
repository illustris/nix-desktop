#!/bin/sh
set -e
set -x
sudo zpool import desktop-nvme
sudo mount -t zfs desktop-nvme/rootfs /mnt/
sudo mount "/dev/disk/by-uuid/9807-6F26" /mnt/boot
sudo mount -t zfs desktop-nvme/nix /mnt/nix
sudo mount -t zfs desktop-nvme/home/root /mnt/root
sudo mount -t zfs desktop-nvme/home /mnt/home
sudo mount -t zfs desktop-nvme/var /mnt/var
sudo mount -t zfs desktop-nvme/var/lib /mnt/var/lib
sudo mount -t zfs desktop-nvme/var/log /mnt/var/log

