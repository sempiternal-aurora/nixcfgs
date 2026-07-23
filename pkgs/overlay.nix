final: prev: {
  afp = final.callPackage ./afp/package.nix { };
  autocorres = final.callPackage ./autocorres/package.nix { };
  petro_bot = final.callPackage ./petro_bot/package.nix { };
}
