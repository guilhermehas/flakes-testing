{
  inputs.nixpkgs.url = github:NixOS/nixpkgs;
  inputs.disko.url = github:nix-community/disko;
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, disko, flake-utils, flake-compat, ... }@attrs: {
    nixosConfigurations.fnord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
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
