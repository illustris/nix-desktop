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
			inputs = {
				nixpkgs.follows = "nixpkgs";
				firefox-addons.follows = "firefox-addons";
				home-manager.follows = "home-manager";
			};
		};
		nixfs = {
			url = "github:illustris/nixfs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		firefox-addons = {
			url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, illustris, nixfs, ... }@inputs: {
		nixosConfigurations = {
			desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./configuration.nix
					{
						environment.etc.flake.source = self;
						nix.registry.nixpkgs.flake = nixpkgs;
						nixpkgs.overlays = with illustris.overlays; [
							lib
							pkgs
							suckless
						];
					}
					home-manager.nixosModule
					{
						home-manager = {
							useGlobalPkgs = true;
							users.illustris = import (
								illustris + "/homeConfigurations/profiles/dailyDriver/home.nix"
							) inputs;
						};
					}
					nixfs.nixosModules.nixfs
					{services.nixfs.enable = true;}
					illustris.nixosModules.plasmonad
				];
			};
		};
	};
}
