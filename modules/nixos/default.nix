{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-apple-silicon.nixosModules.default
    ./asahi.nix
    ./admin-user.nix
    ./network.nix
    ./containers.nix
    ./local-user.nix
    ./audio.nix
    ./console.nix
    ./system.nix
    ./games.nix
    ./keyboard.nix
    ./wayland.nix
    ./media.nix
    ./printing.nix
    ./documentation.nix
    ./udev.nix
  ];
}
