{ config, pkgs, ... }:
{

	nixpkgs.overlays = [
		(import ./overlays/suckless/st-overlay.nix)
		#(import ./overlays/suckless/surf-overlay.nix)
		(import ./overlays/suckless/dwm-overlay.nix)
	];

	fonts.fonts = with pkgs; [
		(nerdfonts.override { fonts = [ "DroidSansMono" ]; })
	];

	services = {
		xserver = {
			enable = true;
			displayManager.defaultSession = "none+dwm";
			windowManager.dwm.enable = true;
			videoDrivers = [ "nvidia" ];
			dpi = 100;
			#defaultDepth = 30;
		};
		picom = {
			enable = true;
			vSync = true;
			refreshRate = 60;
			#backend = "xr_glx_hybrid";
			backend = "glx";
		};
	};

	nixpkgs.config.allowUnfree = true;
	programs.steam.enable = true;
	programs.chromium = {
		enable = true;
		extraOpts = {
			"PasswordManagerEnabled" = false;
			"ClearSiteDataOnExit" = false;
		};
		extensions = [
			"gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
			"cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
			"iipjdmnoigaobkamfhnojmglcdbnfaaf" # Clutter Free
			"bdakmnplckeopfghnlpocafcepegjeap" # RescueTime
			"gppongmhjkpfnbhagpmjfkannfbllamg" # wappalyzer
			"lcbjdhceifofjlpecfpeimnnphbcjgnc" # xBrowserSync
			"chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
		];
		homepageLocation = "https://duckduckgo.com/";
		defaultSearchProviderSuggestURL = "https://duckduckgo.com/?q={searchTerms}&kp=-1&kac=1";
		defaultSearchProviderSearchURL = "https://duckduckgo.com/?q=search&kp=-1";
	};
	environment.systemPackages = with pkgs; [
		st
		dmenu
		mpv
		pavucontrol
		sublime3
		perlPackages.AppClusterSSH
		x11vnc
		kcachegrind
		remmina
		insomnia
		vlc
		openhmd
		gimp
		firefox
		#obs-studio
		signal-desktop
		sxiv
		scrot
		(libsForQt5.callPackage (import ./packages/rescuetime/default.nix) {})
		surf
		gnome3.gnome-screenshot
		blender
		wireshark
		flutter
		obs-studio
		dunst
		libnotify
		ungoogled-chromium
		zoom-us
	];

	hardware.pulseaudio = {
		enable = true;
		daemon.config.default-sample-channels = 6;
		package = pkgs.pulseaudioFull;
		#extraConfig = ''
		#	load-module module-simple-protocol-tcp rate=48000 format=s16le channels=2 source=alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor record=true port=8888
		#'';
		#tcp = {
		#	enable = true;
		#};
	};

	networking.firewall.allowedTCPPorts = [ 4713 8888 ];
}
