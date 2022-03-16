{ pkgs, ... }:

{
	environment = {
		systemPackages = with pkgs; [openvpn];
		etc.openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";
	};
}