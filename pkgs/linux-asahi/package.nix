{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [ ],
}@args:

let
  extraArgs = lib.removeAttrs args [
    "lib"
    "callPackage"
    "linuxPackagesFor"
    "_kernelPatches"
  ];

  linux-asahi-pkg =
    {
      stdenv,
      lib,
      fetchFromGitHub,
      buildLinux,
      ...
    }:
    buildLinux (
      lib.recursiveUpdate rec {
        inherit stdenv lib;

        pname = "linux-asahi";
        version = "7.2.11";
        modDirVersion = version;
        extraMeta.branch = "7.2";

        src = fetchFromGitHub {
          owner = "AsahiLinux";
          repo = "linux";
          rev = "e09c62843a8e43b4454a4f59866ba3f902887c8b";
          hash = "sha256-1cgtwFRxn+LUcnfsNMjyLiJawvoTbS+u90hGc7T82dA=";
        };

        kernelPatches = [
          {
            name = "Asahi config";
            patch = ./m3_fix_vgic_v3.patch;
            structuredExtraConfig = with lib.kernel; {
              # Needed for GPU
              ARM64_16K_PAGES = yes;

              ARM64_MEMORY_MODEL_CONTROL = yes;
              ARM64_ACTLR_STATE = yes;

              # Might lead to the machine rebooting if not loaded soon enough
              APPLE_WATCHDOG = yes;

              # Can not be built as a module, defaults to no
              APPLE_M1_CPU_PMU = yes;

              # Defaults to 'y', but we want to allow the user to set options in modprobe.d
              HID_APPLE = module;

              APPLE_PMGR_MISC = yes;
              APPLE_PMGR_PWRSTATE = yes;

              # Defaults to 'n', but needed to prevent bluetooth stuttering
              BT_BRCMEXT = yes;
            };
            features.rust = true;
          }
        ]
        ++ _kernelPatches;
      } extraArgs
    );

  linux-asahi = callPackage linux-asahi-pkg { };
in
lib.recurseIntoAttrs (linuxPackagesFor linux-asahi)
