{ config, pkgs, lib, ... }:
{
	imports = [
		./desktop-configuration.nix
		./hardware-configuration.nix
		./modules
		./networking-configuration.nix
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
		enableDebugInfo = true;
		etc.nixpkgs.source = pkgs.path;
		systemPackages = with pkgs; [
			asciinema
			bcc
			bind binutils-unwrapped bmon
			cmatrix # More useful than you might think
			cscope
			ethtool expect
			fatrace file fzf
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
		] ++ (with illustris; [
			fzpass
			vpnpass
		]);
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
		"cudatoolkit"
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
			enableSSHSupport = true;
		};

		mosh.enable = true;
		mtr.enable = true;
		nix-ld.enable = true;
	};

	security.pam.services = {
		login.u2fAuth = true;
		sudo.u2fAuth = true;
	};

	services = {
		flatpak.enable = true;
		fprintd.enable = true;
		fwupd.enable = true;
		gnome.gnome-keyring.enable = true;
		ntp.enable = true;
		openssh = {
			enable = true;
			settings.X11Forwarding = true;
		};
		prometheus = {
			enable = true;
			exporters = {
				node = {
					enable = true;
					enabledCollectors = [ "systemd" ];
				};
			};
			scrapeConfigs = [
				{
					job_name = "node_exporter";
					scrape_interval = "10s";
					static_configs = [
						{
							targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
						}
					];
				}
			];
		};
		qemuGuest.enable = true;
		udev = {
			# TODO: check if still needed
			extraRules = pkgs.lib.indent ''
				SUBSYSTEM=="virtio-ports", ATTR{name}=="org.qemu.guest_agent.0", TAG+="systemd" ENV{SYSTEMD_WANTS}="qemu-guest-agent.service"
				ACTION=="bind", SUBSYSTEM=="usb", ATTRS{idVendor}=="2d1f", ATTRS{idProduct}=="524c", RUN+="${pkgs.writeScript "thinkvision" (pkgs.lib.indent ''
					#!${pkgs.bash}/bin/bash
					export DISPLAY=:0
					export XAUTHORITY=/var/run/lightdm/root/:0
					xsetwacom list devices | grep -oP 'id:\s+\K[0-9]+' | xargs -I{} xsetwacom --set {} MapToOutput HEAD-1
				'')}"
			'';
			packages = [ (pkgs.callPackage (import ./packages/xr-hardware/default.nix) {}) ];
			path = with pkgs; [ xf86_input_wacom findutils ];
		};
		zfs.autoScrub.enable = true;
	};
	# systemd = {
	# 	# Disable autostart
	# 	services.grafana = {
	# 		wantedBy = lib.mkForce [];
	# 		serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
	# 	};
	# 	services.docker.wantedBy = lib.mkForce [];
	# };

	time.timeZone = "Asia/Kolkata";

	users.users = let
		ghKeys = pkgs.fetchurl {
			hash = "sha256-Ue0orizAxflXASj3C4+UJ6mcJUmzeSiipls+7D2CKqE=";
			url = "https://github.com/illustris.keys";
		};
	in {
		illustris = {
			extraGroups = [
				"adb" "dialout" "libvirtd" "plugdev" "tty" "wheel"
			] ++ lib.optionals config.virtualisation.docker.enable [ "docker" ];
			isNormalUser = true;
			openssh.authorizedKeys.keyFiles = [ ghKeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ghKeys ];
	};

	virtualisation = {
		docker = {
			enable = false;
			enableNvidia = true;
			# extraOptions = "--storage-opt dm.basesize=20G";
			storageDriver = "overlay2";
			daemon.settings.bip = "192.168.9.0/22";
		};
		libvirtd.enable = false;
		podman = {
			enable = true;
			enableNvidia = true;
		};
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

