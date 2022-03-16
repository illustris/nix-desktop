{ config, pkgs, ... }:
{
	imports = [
		./chromium
		./openvpn
	];
}