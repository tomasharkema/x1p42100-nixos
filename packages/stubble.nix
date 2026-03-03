{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
}: let
  py = python3.withPackages (ps:
    with ps; [
      elfdeps
    ]);
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "stubble";
    version = "unstable";

    src = fetchFromGitHub {
      owner = "ubuntu";
      repo = "stubble";
      rev = "cfbb9c32a6bf97a000dd17e996cd1537ad8923dc";
      hash = "sha256-Sis6i6+2K/+/9zMtHICsiMFkXFUK19BzdAcyMxHZKMk=";
    };

    makeFlags = ["PREFIX=${placeholder "out"}"];
    postPatch = ''
      substituteInPlace ./elf2efi.py --replace-fail "/usr/bin/env python3" "${py}/bin/python3"
    '';
    nativeBuildInputs = [python3];
  })
