final: prev: {
  afp = final.callPackage ./afp/package.nix { };
  avd-fw = final.callPackage ./avd-fw/package.nix { };
  petro_bot = final.callPackage ./petro_bot/package.nix { };
}
