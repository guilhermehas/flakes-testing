{ config, lib, pkgs, disko, ... }:

{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes recursive-nix
      system-features = benchmark big-parallel kvm nixos-test recursive-nix
    '';
  };
  services.xserver.layout = "us,br";

  environment.systemPackages = with pkgs; [
    wget cachix zsh emacs git disko
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
}
