(self: super: {
	st = super.st.overrideAttrs (oldAttrs: {
		src = self.pkgs.fetchFromGitHub {
			owner = "illustris";
			repo = "st";
			rev = "e81a0418d6333127e7b8b7c3690ea18fc3278f73";
			hash = "sha256-hyvR0AeyuHoT0ijLFYDpcVAGGUrw1rk2CBAeUwuZ8IA=";
		};
	});
})
