{ ... }:
{
	networking = {
		firewall.enable = false;
		hostName = "desktop";
		networkmanager.enable = true;
	};
	services.zerotierone.enable = true;
}
