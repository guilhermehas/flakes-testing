{
  inputs.nixpkgs.url = github:NixOS/nixpkgs;
  inputs.disko.url = github:nix-community/disko;
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, disko, flake-utils, flake-compat, ... }@attrs:
  let config = import ./configuration.nix;
      system = "x86_64-linux";
      nixConf = name: nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = attrs // { inherit (disko.packages.${system}) disko; };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-${name}.nix"
          config
        ];
      };
  in
  {
    nixosConfigurations = {
      fnord = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [
          config
          disko.nixosModules.disko
          {
            disko.devices = import ./disk-config.nix {};
            boot.loader.grub = {
              devices = [ "/dev/sda" ];
              efiSupport = true;
              efiInstallAsRemovable = true;
            };
          }
        ];
      };
      iso = nixConf "graphical-plasma5";
      isoMinimal = nixConf "minimal";
    };
    diskoConfigurations.fnord = import ./disk-config.nix;
  } // flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; };
        disko-pkgs = disko.packages.${system};
    in {
      packages = with pkgs; {
        inherit (disko-pkgs) disko;
        default = disko-pkgs.disko;
      };
    });
}
