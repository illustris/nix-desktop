{ config, pkgs, ... }:

let
	ghKeys = builtins.fetchurl {
		sha256 = "sha256:189ah8yyqgjvlsi2hydk94jrra97jj7hpxr805bzkif05jp2ivai";
		url = "https://github.com/illustris.keys";
	};
in
{

	nixpkgs.overlays = [
	];

	imports = [
		./hardware-configuration.nix
		./desktop-configuration.nix
		./modules
	];

	# Support ARM builds
	boot = {
		binfmt.emulatedSystems = [ "aarch64-linux" ];

		kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 4;
			};
			efi.canTouchEfiVariables = true;
		};

		supportedFilesystems = [ "zfs" ];
		zfs.devNodes = "/dev/disk/by-partuuid";
	};

	time.timeZone = "Asia/Kolkata";

	networking = {
		hostId = "f86b2fa7";

		hostName = "desktop";
		networkmanager.enable = true;
	};

	security.sudo.wheelNeedsPassword = false;

	users.users = {
		illustris = {
			isNormalUser = true;
			extraGroups = [ "wheel" "docker" "tty" "adb" "libvirtd" ];
			openssh.authorizedKeys.keyFiles = [ ghKeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ghKeys ];
	};

	environment = {
		systemPackages = with pkgs; [
			asciinema
			bind
			binutils-unwrapped
			bmon
			cmatrix # More useful than you might think
			#ec2_api_tools
			ethtool
			expect
			fatrace
			file
			gdb
			git
			gnumake
			#graphviz
			htop
			#imagemagick
			iotop
			iperf
			jq
			killall
			latencytop
			linuxPackages.perf
			lsof
			mosh
			ncdu
			neofetch
			nethogs
			networkmanager
			nfs-utils
			nix-du
			nix-top
			nix-prefetch-git
			nix-tree
			nnn
			p7zip
			pciutils
			powertop
			pv
			python3
			pythonPackages.percol
			ranger
			screen
			sshfs
			surf
			sysstat
			tmate
			tmux
			tree
			unzip
			usbutils
			valgrind
			#virt-manager
			wget
			youtube-dl
			(cscope.override{emacsSupport = false;})
			#(emacs.override{withGTK3 = false; withX = false;})
			(pass.withExtensions (exts: [ exts.pass-otp ]))
			((pkgs.callPackage ./packages/passcol) { })
			(writeScriptBin "vpnpass" (builtins.readFile ./scripts/vpnpass))
		];
		etc = {
			nixpkgs.source = pkgs.path;
		};
	};

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

	services = {
		zfs.autoScrub.enable = true;
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
		flatpak.enable = true;
		gnome.gnome-keyring.enable = true;
		qemuGuest.enable = true;
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

	networking.firewall.enable = false;

	nix = {
		extraOptions = ''
			experimental-features = nix-command flakes
		'';
		nixPath = [ "nixpkgs=${pkgs.path}" ];
		settings = {
			trusted-users = [ "root" "illustris" ];
			auto-optimise-store = true;
		};
	};

	xdg.portal.enable = true;

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
	system.stateVersion = "21.05"; # Did you read the comment?

}

