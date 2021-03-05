{ config, pkgs, ... }:

{

	nixpkgs.overlays = [
		#(import ./qemu.nix)
	];

	imports = [
		./hardware-configuration.nix
		./desktop-configuration.nix
	];

	boot.kernelPackages = pkgs.linuxPackages_latest;

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	boot.supportedFilesystems = [ "zfs" ];
	boot.zfs.devNodes = "/dev/disk/by-partuuid";
	networking.hostId = "f86b2fa7";

	time.timeZone = "Asia/Kolkata";

	networking.hostName = "desktop"; # Define your hostname.
	networking.useDHCP = false;
	networking.interfaces.enp6s18.useDHCP = true;
	#networking.interfaces.enp11s0.useDHCP = true;
	
	

	security.sudo.wheelNeedsPassword = false;

	users.users = {
		illustris = {
			isNormalUser = true;
			extraGroups = [ "wheel" "docker" "tty" ]; # Enable ‘sudo’ for the user.
			openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
	};

	environment.systemPackages = with pkgs; [
		git
		tmux
		htop
		nfs-utils
		bmon
		sysstat
		(pass.withExtensions (exts: [ exts.pass-otp ]))
		nnn
		mosh
		ncdu
		(writeScriptBin "vpnpass" (builtins.readFile ./scripts/vpnpass))
		wget
		expect
		openvpn
		#signal-cli
		tcpdump
		killall
		file
		tree
		ntfs3g
		p7zip
		ranger
		cscope
		python
		bind # for nslookup
		ethtool
		unzip
		pciutils
		sshfs
		jq
		#arduino
		#python27Packages.pyserial
	];

	programs.gnupg.agent = {
		enable = true;
	};

	services = {
		openssh = {
			enable = true;
			forwardX11 = true;
		};
		udev.packages = [ (pkgs.callPackage (import ./packages/xr-hardware/default.nix) {}) ];
	};
	environment.etc.openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";

	virtualisation.docker.enable = true;

	# Temporary fix for qemu-ga till #112886 gets merged
	services.udev.extraRules = ''
		SUBSYSTEM=="virtio-ports", ATTR{name}=="org.qemu.guest_agent.0", TAG+="systemd" ENV{SYSTEMD_WANTS}="qemu-guest-agent.service"
	'';
	systemd.services.qemu-guest-agent = {
		description = "Run the QEMU Guest Agent";
		serviceConfig = {
			ExecStart = "${pkgs.qemu}/bin/qemu-ga --statedir /var/run";
			Restart = "always";
			RestartSec = 0;
		};
	};
	networking.hosts = {
		"192.168.1.8" = ["git.illustris.tech"];
		"192.168.1.10" = ["kube-master"];
	};

	# In case of emergency, bash glass
	#systemd.tmpfiles.rules = [
	#	"L /bin/bash - - - - /run/current-system/sw/bin/bash"
	#];

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "21.03"; # Did you read the comment?

}

