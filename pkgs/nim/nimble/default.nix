{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  # deps
  openssl,
  nim,
  makeWrapper,

}:
buildNimPackage (finalAttrs: {
  pname = "nimble";
  version = "0.16.4-unstable";
  src = fetchFromGitHub {
    owner = "nim-lang";
    repo = "nimble";
    rev = "30e7014c8ea865f3b9fc051824fe6dbc6b1d917c";
    # rev = "v${finalAttrs.version}";
    hash = "sha256-ASodRov4rO/IhjQRRdqVnLWMG1voXWM9F6R6VJd9qkM=";
    fetchSubmodules = true;
  };
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ openssl ];

    nimFlags = [ "--define:git_revision_override=${finalAttrs.src.rev}" ];

    doCheck = false; # it works on their machine

    postInstall = ''
      wrapProgram $out/bin/nimble \
        --suffix PATH : ${lib.makeBinPath [ nim ]}
    '';

    meta = {
      description = "Package manager for the Nim programming language";
      homepage = "https://github.com/nim-lang/nimble";
      license = lib.licenses.bsd3;
      mainProgram = "nimble";
    };
  }
)
