{ config, pkgs, ... }:

{

	nixpkgs.overlays = [
	];

	# Use nixpkgs from niv
	#nixpkgs.pkgs = let
	#	sources = import ./nix/sources.nix;
	#in import sources.nixpkgs {
	#	config = config.nixpkgs.config // {
	#		allowUnfree = true;
	#	};
	#};

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
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};

		supportedFilesystems = [ "zfs" ];
		zfs.devNodes = "/dev/disk/by-partuuid";
	};

	time.timeZone = "Asia/Kolkata";

	networking = {
		hostId = "f86b2fa7";

		hostName = "desktop";
		useDHCP = false;
		interfaces = {
			enp6s18.useDHCP = true;
			enp11s0.useDHCP = true;
		};
		#hosts = {
		#};
	};

	security.sudo.wheelNeedsPassword = false;

	users.users = {
		illustris = {
			isNormalUser = true;
			extraGroups = [ "wheel" "docker" "tty" "adb" "libvirtd" ];
			openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
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
			nixpkgs.source = let sources = import ./nix/sources.nix; in sources.nixpkgs;
		};
	};

	#programs.bash = {
	#	interactiveShellInit = ''
	#		export HISTSIZE=-1 HISTFILESIZE=-1 HISTCONTROL=ignoreboth:erasedups;
	#	'';
	#	shellAliases = {
	#		genpass = "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 2";
	#	};
	#	promptInit = ''
	#		if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
	#			PROMPT_COLOR="1;31m"
	#			let $UID && PROMPT_COLOR="1;36m"
	#			PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
	#		fi
	#	'';
	#};


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
				nt = "sudo nix-shell /etc/nixos/shell.nix --run \"nixos-rebuild test\"";
				ns = "sudo nix-shell /etc/nixos/shell.nix --run \"nixos-rebuild switch\"";
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
		docker.enable = true;
		libvirtd.enable = true;
	};

	networking.firewall.enable = false;

	nix = {
		extraOptions = ''
			experimental-features = nix-command flakes
		'';
		nixPath = [
			"nixpkgs=${pkgs.path}"
			"nixos-config=/etc/nixos/configuration.nix"
		];
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

