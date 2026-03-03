{
  runCommand,
  fetchFromGitHub,
  lib,
  ...
}: let
  #slim5x = ../firmware;
  slim5x = fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "4010ca49e14b4b1964e306c51fb9428c2ef79a7c";
    hash = "sha256-+dO+/iEABRq1lmtJmln/X7B/s7AlDkMwEUlzzXhQYO4=";
  };
in
  runCommand "qcom-laptops-firmware" {} ''
    mkdir -p $out/lib/firmware
    cp -vr ${slim5x}/lib/firmware/qcom $out/lib/firmware/
    ls -la $out/lib/firmware/qcom
  ''
