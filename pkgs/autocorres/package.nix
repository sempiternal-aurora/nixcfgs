{
  stdenvNoCC,
  isabelle,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "autocorres";
  version = "1.12";

  src = fetchurl {
    url = "https://github.com/sel4/l4v/releases/download/autocorres-${finalAttrs.version}/autocorres-${finalAttrs.version}.tar.gz";
    hash = "sha256-5wjigoqGCtNxldeqYlPLIu97/++AG/ciuKJHv9qE4Vo=";
  };

  postPatch = ''
    substituteInPlace lib/Word_Lib/More_Divides.thy \
      --replace-fail 'using power_gt1 [of 2 n] by (auto intro: mod_pos_pos_trivial)' 'by (simp add: power_gt1_lemma)'
  '';

  installPhase = ''
    runHook preInstall

    dir="$out/Isabelle${isabelle.version}/contrib/${finalAttrs.pname}-${finalAttrs.version}"
    mkdir -p $dir
    cp -r lib autocorres c-parser ROOTS $dir

    runHook postInstall
  '';

  meta = {
    description = "AutoCorres and C-Parser for Isabelle";
    homepage = "https://github.com/seL4/l4v";
  };
})
