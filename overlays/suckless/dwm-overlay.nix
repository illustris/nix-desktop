(self: super: {
	dwm = super.dwm.overrideAttrs (oldAttrs: {
		src = /home/illustris/src/dwm;
	});
})
