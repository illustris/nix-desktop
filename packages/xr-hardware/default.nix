{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
	pname = "xr-hardware";
	version = "0.3.0";
	src = fetchgit {
		url = "https://gitlab.freedesktop.org/monado/utilities/xr-hardware.git";
		rev = "34f51326403c076c820942f855f8532dd90860e4";
		sha256 = "1729z53lc0g9cwv05pqi4x31syi9mhfm9s99fm5azsr5f51cy3wq";
	};

	installPhase = ''
		DESTDIR=$out make install
	'';

	meta = {
		description = "Udev rules for user access to XR (VR and AR)hardware devices";
		platforms = with lib.platforms; all;
		license = lib.licenses.boost;
	};
}
