(self: super: {
	st = super.st.overrideAttrs (oldAttrs: {
		src = self.pkgs.fetchFromGitHub {
			owner = "illustris";
			repo = "st";
			rev = "fa363487355fe0b27d82e7247577802ac66e4b0f";
			hash = "sha256-KLh4yGSq7pf6F+mWZvH6slN+Qa1/LkjWbhFTxQ2vYng=";
		};
	});
})
