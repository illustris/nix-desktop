{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		iftop
		netbird-ui
		wireguard-tools
	];
	networking = {
		firewall.enable = false;
		hostName = "desktop";
		networkmanager.enable = true;
	};
	services = {
		netbird.enable = true;
		resolved = {
			enable = true;
			# git.sr.ht fails to resolve with dnssec
			dnssec = "false";
		};
		# zerotierone.enable = true;
	};
}
