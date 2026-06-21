{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  pname = "clearviewhwy";
  version = "2026-05-27";

  src = fetchzip {
    url = "https://font.download/dl/font/clearviewhwy.zip";
    sha256 = "sha256-oGzp1qvYoxFwDgOzGwFsED/Duioy/QLA4eZFp84MhT8=";
    stripRoot = false;
  };

  postInstall = ''
    install -D ./ClearviewHwy1B.ttf $out/share/fonts/ttf/ClearviewHwy1B.ttf
    cp -v ./*.ttf $out/share/fonts/ttf/
  '';
}
