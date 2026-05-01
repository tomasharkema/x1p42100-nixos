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
    rev = "main";
    hash = "sha256-JNRtDfnpj6LX+auUPUjv4EmpC01c+WPMb70Xm5u9oRA=";
  };
in
  runCommand "qcom-laptops-firmware" {} ''
    mkdir -p $out/lib/firmware
    cp -vr ${slim5x}/lib/firmware/qcom $out/lib/firmware/

    mkdir -p $out/share
    cp -vr ${slim5x}/usr/share/alsa $out/share
  ''
