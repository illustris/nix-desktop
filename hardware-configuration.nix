# Do not modify this file! It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations. Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/profiles/qemu-guest.nix")
	];

	boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "v4l2loopback" ];
	boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

	fileSystems = {
		"/" = {
			device = "ssd/rootfs";
			fsType = "zfs";
		};

		"/home" = {
			device = "ssd/home";
			fsType = "zfs";
		};

		"/nix" = {
			device = "ssd/nix";
			fsType = "zfs";
		};

		"/root" = {
			device = "ssd/home/root";
			fsType = "zfs";
		};

		"/tmp" = {
			device = "ssd/tmp";
			fsType = "zfs";
		};

		"/var" = {
			device = "ssd/var";
			fsType = "zfs";
		};

		"/var/lib" = {
			device = "ssd/var/lib";
			fsType = "zfs";
		};

		"/var/log" = {
			device = "ssd/var/log";
			fsType = "zfs";
		};

		"/boot" = {
			device = "/dev/disk/by-uuid/453B-D3CD";
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
