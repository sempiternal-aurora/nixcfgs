{
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:

stdenv.mkDerivation {
  pname = "avd-fw";
  version = "0-unstable-2026-07-26";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "avd-fw";
    rev = "5e34aca83906f12ef3c2bfacb6712797de4bb7d5";
    hash = "sha256-cq/gOgmbCg5IX0GSiS7Z5lBhpursB1Num8LSANw5fpI=";
  };

  nativeBuildInputs = [
    ninja
    meson
  ];

  mesonFlags = [
    "--cross-file=arm-none-eabi-gcc.ini"
    "--buildtype"
    "release"
  ];
}
