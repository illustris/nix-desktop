{ config, pkgs, lib, ... }:
{

	nixpkgs.overlays = [
		(import ./overlays/suckless/st-overlay.nix)
		# (import ./overlays/suckless/surf-overlay.nix)
		(import ./overlays/suckless/dwm-overlay.nix)
	];

	environment.systemPackages = with pkgs; [
		arandr
		# blender
		dmenu
		dunst
		firefox
		flutter
		gimp
		gnome.gnome-screenshot
		guake
		insomnia
		# kcachegrind
		kicad
		libnotify
		mpv
		obs-studio
		okular
		# openhmd
		pavucontrol
		perlPackages.AppClusterSSH
		qsynth
		remmina
		signal-desktop
		scrot
		st
		sunshine
		# surf
		sxiv
		tidal-hifi
		virt-manager
		vlc
		wireshark
		x11vnc
		# zoom-us
	];
	
	fonts.fonts = with pkgs; [
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

	networking.firewall.allowedTCPPorts = [ 4713 8888 ];

	programs.steam.enable = true;

	security.rtkit.enable = true;

	services = {
		blueman.enable = true;
		picom = {
			backend = "glx";
			# backend = "xr_glx_hybrid";
			enable = true;
			vSync = true;
		};
		xserver = {
			# defaultDepth = 30;
			displayManager.defaultSession = "none+dwm";
			dpi = 100;
			enable = true;
			videoDrivers = [ "nvidia" ];
			windowManager.dwm.enable = true;
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
