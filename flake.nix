{
	description = "A very basic flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		illustris = {
			url = "github:illustris/flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixfs = {
			url = "github:illustris/nixfs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, illustris, nixfs, ... }: {
		nixosConfigurations = {
			desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./configuration.nix
					home-manager.nixosModule
					{nix.registry.np.flake = nixpkgs;}
					{environment.etc.flake.source = self;}
					{nixpkgs.overlays = [
						illustris.overlays.default
						(self: super: {
							lib = super.lib // illustris.lib;
						})
					];}
					nixfs.nixosModules.nixfs
					{services.nixfs.enable = true;}
				];
			};
		};
	};
}
