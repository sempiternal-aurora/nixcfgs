{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "petro_bot";
  version = "0-unstable-2026-07-15";

  src = fetchFromGitHub {
    owner = "PETR0-4LT";
    repo = "petro_bot";
    rev = "5f01212ac19859c344dd229faa8a33809c466dbe";
    hash = "sha256-SNct8JxArExmv8AMmFoAFngB8zblwBmtzznreVZVg98=";
  };

  cargoHash = "sha256-yByRIC2EZFgkQrEvuu7tf9QhEk91YxgQN95ZXveNdtY=";
}
