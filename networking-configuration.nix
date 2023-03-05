{ ... }:
{
	networking = {
		firewall.enable = false;
		hostName = "desktop";
		networkmanager.enable = true;
	};
	services = {
		resolved = {
			enable = true;
			# git.sr.ht fails to resolve with dnssec
			dnssec = "false";
		};
		zerotierone.enable = true;
	};
}
