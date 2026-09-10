{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "apmc";
  version = "0-unstable-2026-04-13";

  src = fetchFromGitHub {
    owner = "0ax1";
    repo = "apmc";
    rev = "9cff99a9df2ae055f1e3065c64f633e38bb6beec";
    hash = "sha256-wxaAq+PWpn7HvaW9pgqCV7RMHSSYZ54z9HyNMZ2R3Ls=";
  };

  cargoHash = "sha256-idYuXmyS4Qyrlfb0KMwbfMxO0BOKqcDWLSWTq2ChAh4=";
}
