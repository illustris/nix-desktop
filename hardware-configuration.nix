# Do not modify this file! It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations. Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/profiles/qemu-guest.nix")
	];

	boot = {
		initrd = {
			availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk" "nvme" ];
			kernelModules = [ ];
		};
		kernelModules = [ "v4l2loopback" ];
		extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
	};

	fileSystems = {
		"/" = {
			device = "desktop-nvme/rootfs";
			fsType = "zfs";
		};

		"/home" = {
			device = "desktop-nvme/home";
			fsType = "zfs";
		};

		"/nix" = {
			device = "desktop-nvme/nix";
			fsType = "zfs";
		};

		"/root" = {
			device = "desktop-nvme/home/root";
			fsType = "zfs";
		};

		"/tmp" = {
			device = "desktop-nvme/tmp";
			fsType = "zfs";
		};

		"/var" = {
			device = "desktop-nvme/var";
			fsType = "zfs";
		};

		"/var/lib" = {
			device = "desktop-nvme/var/lib";
			fsType = "zfs";
		};

		"/var/log" = {
			device = "desktop-nvme/var/log";
			fsType = "zfs";
		};

		"/boot" = {
			device = "/dev/disk/by-uuid/9807-6F26";
			fsType = "vfat";
		};
	};

	swapDevices = [ ];
	zramSwap = {
		enable = true;
	};

	hardware = {
		firmware = with pkgs; [ linux-firmware ];
		bluetooth.enable = true;
	};
}
