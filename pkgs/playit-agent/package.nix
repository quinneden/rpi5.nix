{ fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "playit-agent";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "playit-cloud";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-kT7NLUcgGM/hxwK4PUDZ71PtYJqjR8i4yj/LhbXX1i0=";
  };

  cargoHash = "sha256-NcRND1lBbRs8/byiAQx0kGgc5Yw5PxhXxo+9FX9lbv0=";

  doCheck = false;

  meta.mainProgram = "playit-cli";
})
