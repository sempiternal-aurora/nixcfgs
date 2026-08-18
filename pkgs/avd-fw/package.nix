{
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "avd-fw";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "avd-fw";
    tag = "v${finalAttrs.version}";
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
})
