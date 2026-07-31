{
  lib,
  pkgsHostTarget,
  stdenvNoCC,
  isabelle,
  fetchFromGitLab,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "AFP";
  version = "2025-2-unstable-2026-07-21";

  src = fetchFromGitLab {
    domain = "foss.heptapod.net";
    owner = "isa-afp";
    repo = "afp-2025-2";
    rev = "12aae4b0ed0d842d92ea7edafdb03e4cf0aa8911";
    hash = "sha256-88c5ZCUcMn0ne9xnQt8lzjtfT2xQggKxVLpVDCDVA/Y=";
  };

  postPatch = ''
    substituteInPlace thys/AutoCorres2/c-parser/isar_install.ML \
      --replace-fail '/usr/bin/cpp' '${lib.getExe' pkgsHostTarget.clang "cpp"}' \
      --replace-fail '/usr/bin/clang' '${lib.getExe' pkgsHostTarget.clang "clang"}'

    substituteInPlace thys/AutoCorres2/c-parser/CTranslationSetup.thy \
      --replace-fail 'mllex "StrictC.lex"' "" \
      --replace-fail 'mlyacc "StrictC.grm"' ""
  '';

  nativeBuildInputs = [ isabelle ];

  installPhase = ''
    runHook preInstall

    dir=$out/Isabelle${isabelle.version}/contrib/${finalAttrs.pname}-${finalAttrs.version}
    mkdir -p $dir
    cp -r thys/* $dir/

    runHook postInstall
  '';

  meta = {
    description = "Archive of Formal Proofs";
    homepage = "https://isa-afp.org";
    platforms = isabelle.meta.platforms;
  };
})
