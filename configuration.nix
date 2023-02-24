{ config, pkgs, lib, ... }:
{
	imports = [
		./desktop-configuration.nix
		./hardware-configuration.nix
		./networking-configuration.nix
		./modules
	];

	# Support ARM builds
	boot = {
		binfmt.emulatedSystems = [
			"aarch64-linux"
			"riscv64-linux"
		];

		kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 4;
			};
			efi.canTouchEfiVariables = true;
		};

		supportedFilesystems = [ "zfs" "ntfs" ];
		zfs.devNodes = "/dev/disk/by-partuuid";
	};

	environment = {
		etc.nixpkgs.source = pkgs.path;
		systemPackages = with pkgs; [
			asciinema
			bind binutils-unwrapped bmon
			cmatrix # More useful than you might think
			cscope
			ethtool expect
			fatrace file
			gdb git gnumake
			htop
			iotop iperf
			jq
			killall
			latencytop linuxPackages.perf lsof
			mosh
			ncdu neofetch nethogs networkmanager nfs-utils
			nix-du nix-top nix-prefetch-git nix-tree
			nnn
			openvpn
			p7zip pciutils powertop pv
			python3 python3Packages.percol
			ranger
			screen sshfs surf sysstat
			tmate tmux tree
			unzip usbutils
			valgrind
			wget
			youtube-dl
			(pass.withExtensions (exts: [ exts.pass-otp ]))
			((pkgs.callPackage ./packages/passcol) { })
			(writeScriptBin "vpnpass" (builtins.readFile ./scripts/vpnpass))
		];
	};

	# for ZFS
	networking.hostId = "f86b2fa7";

	nix = {
		nixPath = [ "nixpkgs=${pkgs.path}" ];
		settings = {
			auto-optimise-store = true;
			experimental-features = [ "nix-command" "flakes" ];
			trusted-users = [ "root" "illustris" ];
		};
	};

	# TODO: make a mergable option
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"nvidia-persistenced" "nvidia-settings" "nvidia-x11"
		"steam" "steam-original" "steam-run"
		"zerotierone"
	];

	programs = {
		adb.enable = true;
		bash = {
			interactiveShellInit = ''
				export HISTSIZE=-1 HISTFILESIZE=-1 HISTCONTROL=ignoreboth:erasedups
				shopt -s histappend
				export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
			'';
			shellAliases = {
				genpass = "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 2";
				nt = "sudo nixos-rebuild test --flake /etc/nixos#";
				ns = "sudo nixos-rebuild switch --flake /etc/nixos#";
				grep = "grep --color";
			};
			promptInit = ''
				if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
					PROMPT_COLOR="1;31m"
					let $UID && PROMPT_COLOR="1;36m"
					PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
				fi
			'';
		};

		# for virt-manager
		dconf.enable = true;

		gnupg.agent = {
			enable = true;
			pinentryFlavor = "curses";
		};

		mosh.enable = true;
		mtr.enable = true;
		ssh.startAgent = true;
	};

	security.sudo.wheelNeedsPassword = false;

	services = {
		flatpak.enable = true;
		gnome.gnome-keyring.enable = true;
		ntp.enable = true;
		openssh = {
			enable = true;
			settings.X11Forwarding = true;
		};
		qemuGuest.enable = true;
		resolved.enable = true;
		udev = {
			# TODO: check if still needed
			extraRules = ''
				SUBSYSTEM=="virtio-ports", ATTR{name}=="org.qemu.guest_agent.0", TAG+="systemd" ENV{SYSTEMD_WANTS}="qemu-guest-agent.service"
			'';
			packages = [ (pkgs.callPackage (import ./packages/xr-hardware/default.nix) {}) ];
		};
		zfs.autoScrub.enable = true;
	};

	time.timeZone = "Asia/Kolkata";

	users.users = let
		ghKeys = pkgs.fetchurl {
			hash = "sha256-Ue0orizAxflXASj3C4+UJ6mcJUmzeSiipls+7D2CKqE=";
			url = "https://github.com/illustris.keys";
		};
	in {
		illustris = {
			extraGroups = [ "adb" "docker" "libvirtd" "tty" "wheel" ];
			isNormalUser = true;
			openssh.authorizedKeys.keyFiles = [ ghKeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ghKeys ];
	};

	virtualisation = {
		docker = {
			enable = true;
			enableNvidia = true;
			# extraOptions = "--storage-opt dm.basesize=20G";
			storageDriver = "zfs";
		};
		libvirtd.enable = true;
	};

	xdg.portal.enable = true;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "21.05"; # Did you read the comment?

}

