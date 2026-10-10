{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "petro_bot";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "PETR0-4LT";
    repo = "petro_bot";
    rev = "73dca727ec274f5b34f1b023b87f8d2418c3ef91";
    hash = "sha256-BMkVsU/RbVphp9+s1/6j+XZC6GL7rP/FpsTGWZJj0mE=";
  };

  cargoHash = "sha256-9DiUBvxLksWkxaE+gFkbQ1xmKjNeyuwQGPwhPmF2Adw=";
}
