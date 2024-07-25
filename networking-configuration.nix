{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		netbird-ui
		iftop
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
