final: prev: {
  afp = final.callPackage ./afp/package.nix { };
  apmc = final.callPackage ./apmc/package.nix { };
  petro_bot = final.callPackage ./petro_bot/package.nix { };
}
