{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "apmc";
  version = "0-unstable-2026-04-13";

  src = fetchFromGitHub {
    owner = "sempiternal-aurora";
    repo = "apmc";
    rev = "810a731ec01760e478b382ca6a81782a03dbfe0d";
    hash = "sha256-SIXQB83Jk8g8kJt87LVH3FMIbgIjIXMvcpiFo7fpuks=";
  };

  cargoHash = "sha256-idYuXmyS4Qyrlfb0KMwbfMxO0BOKqcDWLSWTq2ChAh4=";
}
