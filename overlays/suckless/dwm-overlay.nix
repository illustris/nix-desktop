(self: super: {
	dwm = super.dwm.overrideAttrs (oldAttrs: {
		src = self.pkgs.fetchFromGitHub {
			owner = "illustris";
			repo = "dwm";
			rev = "7df55abebad6a70236a6d6fc62fd475476fd77f6";
			hash = "sha256-Cfdv+r271etL5nYkd4U2nRE/zCW7PaHkDC11eeGqLy4=";
		};
	});
})
