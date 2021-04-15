{
	config,
	pkgs,
	...
}:

{

	nixpkgs.overlays = [
	];

	# Use nixpkgs from niv
	nixpkgs.pkgs = let
		sources = import ./nix/sources.nix;
	in import sources.nixpkgs {
		config = config.nixpkgs.config // {
			allowUnfree = true;
		};
	};

	imports = [
		./hardware-configuration.nix
		./desktop-configuration.nix
	];

	# Support ARM builds
	boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

	boot.kernelPackages = pkgs.linuxPackages_latest;

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	boot.supportedFilesystems = [ "zfs" ];
	boot.zfs.devNodes = "/dev/disk/by-partuuid";
	networking.hostId = "f86b2fa7";

	time.timeZone = "Asia/Kolkata";

	networking.hostName = "desktop"; # Define your hostname.
	networking.useDHCP = false;
	#networking.interfaces.enp6s18.useDHCP = true;
	networking.interfaces.enp6s18.useDHCP = true;
	
	

	security.sudo.wheelNeedsPassword = false;

	users.users = {
		illustris = {
			isNormalUser = true;
			extraGroups = [ "wheel" "docker" "tty" "adb" ];
			openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
	};

	programs.adb.enable = true;

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
		nixpkgs-review
		(pkgs.callPackage /home/illustris/src/percol/percol {})
		niv
		(
			rofi.override { plugins = [
				rofi-calc
				rofi-pass
				rofi-systemd
			]; }
		)
		nmap
		fping
	];

	programs.gnupg.agent = {
		enable = true;
	};

	programs.bash = {
		interactiveShellInit = ''
			export HISTSIZE=-1 HISTFILESIZE=-1 HISTCONTROL=ignoreboth:erasedups;
		'';
		shellAliases = {
			genpass = "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 2";
		};
		promptInit = ''
			if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
				PROMPT_COLOR="1;31m"
				let $UID && PROMPT_COLOR="1;36m"
				PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
			fi
		'';
	};

	services = {
		openssh = {
			enable = true;
			forwardX11 = true;
		};
		udev = {
			packages = [ (pkgs.callPackage (import ./packages/xr-hardware/default.nix) {}) ];
			extraRules = ''
				SUBSYSTEM=="virtio-ports", ATTR{name}=="org.qemu.guest_agent.0", TAG+="systemd" ENV{SYSTEMD_WANTS}="qemu-guest-agent.service"
			'';
		};
		ntp.enable = true;
		zerotierone.enable = true;
	};
	environment.etc.openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";

	virtualisation.docker.enable = true;

	# Temporary fix for qemu-ga till #112886 gets merged
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

	networking.firewall.enable = false;

	nix.trustedUsers = [ "root" "illustris" ];

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

