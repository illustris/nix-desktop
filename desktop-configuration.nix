{ config, pkgs, lib, ... }:
{
	environment.systemPackages = with pkgs; [
		arandr
		# blender
		dmenu
		dunst
		# firefox
		# flutter
		gimp
		gnome.gnome-screenshot
		guake
		insomnia
		# kcachegrind
		# kicad # 8GB
		kitty
		libnotify
		mpv
		obs-studio
		okular
		# openhmd
		pavucontrol
		perl536Packages.AppClusterSSH
		qsynth
		remmina
		signal-desktop
		scrot
		st
		(sunshine.override {
			cudaSupport = true;
			cudaPackages = cudaPackages_12;
		})
		# surf
		sxiv
		tidal-hifi
		virt-manager
		vlc
		wireshark
		x11vnc
		# zoom-us
	];
	
	fonts.packages = with pkgs; [
		(nerdfonts.override { fonts = [ "DroidSansMono" ]; })
	];

	hardware.pulseaudio = {
		daemon.config.default-sample-channels = 6;
		enable = false;
		# extraConfig = ''
		# 	load-module module-simple-protocol-tcp rate=48000 format=s16le channels=2 source=alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor record=true port=8888
		# '';
		package = pkgs.pulseaudioFull;
		# tcp = {
		# 	enable = true;
		# };
	};

	networking.firewall = {
		enable = false;
		allowedTCPPorts = [ 4713 8888 ];
	};

	programs = {
		hyprland = {
			enable = true;
			xwayland.enable = true;
		};
		waybar.enable = true;
		steam = {
			enable = true;
			gamescopeSession.enable = true;
		};
	};

	security.rtkit.enable = true;

	services = {
		displayManager.sddm.enable = lib.mkForce false;
		# blueman.enable = true;
		picom = {
			backend = "glx";
			# backend = "xr_glx_hybrid";
			enable = true;
			vSync = true;
		};
		xserver = {
			# defaultDepth = 30;
			# displayManager.defaultSession = "none+dwm";
			# desktopManager.plasma5.enable = true;
			dpi = 100;
			# enable = true;
			videoDrivers = [
				# "displaylink"
				"nvidia"
			];
			wacom.enable = true;
			windowManager.dwm.enable = true;
			displayManager.lightdm.enable = true;
		};
		pipewire = {
			alsa = {
				enable = true;
				support32Bit = true;
			};
			enable = true;
			jack.enable = true;
			pulse.enable = true;
			socketActivation = true;
		};
	};

	systemd.user.services.sunshine = {
		path = [ pkgs.sunshine ];
		script = "sunshine";
	};
}
