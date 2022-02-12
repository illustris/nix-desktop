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
		pipewire = {
			enable = true;
			alsa = {
				enable = true;
				support32Bit = true;
			};
			pulse.enable = true;
			jack.enable = true;
			socketActivation = true;
			config.pipewire = {
				#"context.properties" = {
				#	"link.max-buffers" = 16;
				#	"log.level" = 2;
				#	"default.clock.rate" = 48000;
				#	"default.clock.quantum" = 32;
				#	"default.clock.min-quantum" = 32;
				#	"default.clock.max-quantum" = 32;
				#	"core.daemon" = true;
				#	"core.name" = "pipewire-0";
				#};
				#"context.modules" = [
				#	{
				#		name = "libpipewire-module-rtkit";
				#		args = {
				#			"nice.level" = -15;
				#			"rt.prio" = 88;
				#			"rt.time.soft" = 200000;
				#			"rt.time.hard" = 200000;
				#		};
				#		flags = [ "ifexists" "nofail" ];
				#	}
				#	{ name = "libpipewire-module-protocol-native"; }
				#	{ name = "libpipewire-module-profiler"; }
				#	{ name = "libpipewire-module-metadata"; }
				#	{ name = "libpipewire-module-spa-device-factory"; }
				#	{ name = "libpipewire-module-spa-node-factory"; }
				#	{ name = "libpipewire-module-client-node"; }
				#	{ name = "libpipewire-module-client-device"; }
				#	{
				#		name = "libpipewire-module-portal";
				#		flags = [ "ifexists" "nofail" ];
				#	}
				#	{
				#	name = "libpipewire-module-access";
				#	args = {};
				#	}
				#	{ name = "libpipewire-module-adapter"; }
				#	{ name = "libpipewire-module-link-factory"; }
				#	{ name = "libpipewire-module-session-manager"; }
				#];
			};

		};
	};

	nixpkgs.config.allowUnfree = true;
	programs.steam.enable = true;
	programs.chromium = {
		enable = true;
		extensions = [
			"gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
			"cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
			"iipjdmnoigaobkamfhnojmglcdbnfaaf" # Clutter Free
			"bdakmnplckeopfghnlpocafcepegjeap" # RescueTime
			"gppongmhjkpfnbhagpmjfkannfbllamg" # wappalyzer
			"lcbjdhceifofjlpecfpeimnnphbcjgnc" # xBrowserSync
			"chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
			"aghfnjkcakhmadgdomlmlhhaocbkloab" # just black
			"fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
		];
		homepageLocation = "https://sx.illustris.tech/";
		defaultSearchProviderSuggestURL = "https://sx.illustris.tech/autocompleter?q={searchTerms}";
		defaultSearchProviderSearchURL = "https://sx.illustris.tech/search?q={searchTerms}";
		extraOpts = {
			DefaultSearchProviderEnabled = true;
			DefaultSearchProviderName = "Sx";
			DefaultCookiesSetting = 1;
		};
	};
	environment.systemPackages = with pkgs; [
		st
		dmenu
		mpv
		pavucontrol
		sublime3
		perlPackages.AppClusterSSH
		x11vnc
		#kcachegrind
		#remmina
		insomnia
		vlc
		openhmd
		gimp
		firefox
		#obs-studio
		signal-desktop
		sxiv
		scrot
		#(libsForQt5.callPackage (import ./packages/rescuetime/default.nix) {})
		#surf
		gnome3.gnome-screenshot
		blender
		wireshark
		flutter
		obs-studio
		dunst
		libnotify
		ungoogled-chromium
		zoom-us
		guake
	];

	security.rtkit.enable = true;

	hardware.pulseaudio = {
		enable = false;
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
