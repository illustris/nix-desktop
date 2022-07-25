{
	description = "A very basic flake";

	inputs.nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

	outputs = { self, nixpkgs }: {
		nixosConfigurations = {
			desktop = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./configuration.nix ];
			};
		};
	};
}
