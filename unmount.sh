set -x
set -e
sudo umount -R /mnt
sudo zpool export desktop-nvme
