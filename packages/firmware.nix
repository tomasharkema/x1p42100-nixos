{
  python3,
  stdenv,
  cabextract,
  rsync,
  fetchurl,
  fetchzip,
  fetchFromGitHub,
  linux-firmware,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "surface-firmware";
  version = "200.0.32.0";
  commit = "30e823d85c1fb4e410a4afdf9cd2285914ee712d";

  sp12 = fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "4010ca49e14b4b1964e306c51fb9428c2ef79a7c";
    hash = "sha256-+dO+/iEABRq1lmtJmln/X7B/s7AlDkMwEUlzzXhQYO4=";
  };

  ath12 = fetchzip {
    url = "https://git.codelinaro.org/clo/ath-firmware/ath12k-firmware/-/archive/main/ath12k-firmware-main.tar.gz";
    sha256 = "sha256-DGyEp4+UGGuJ0qiM+jaHl6xOd02hCk92j28fIlGSoK4=";
  };

  board-2 =
    #"${linux-firmware}/lib/firmware/ath12k/WCN7850/hw2.0/board-2.bin";
    "${finalAttrs.ath12}/WCN7850/hw2.0/board-2.bin";

  bdencoder = fetchurl {
    url = "https://raw.githubusercontent.com/qca/qca-swiss-army-knife/f2164085920540f4ecbfa0b12959918c601724b6/tools/scripts/ath12k/ath12k-bdencoder";
    hash = "sha256-hzn/GVo7nZmuBpuBsEZUcf928w03cgANq+kaUlGmeYA=";
  };

  qcvss8380 = fetchurl {
    url = "https://drive.google.com/uc?id=13FgedOLcmZYvrWvnT1jfTIe6sAq2z-Wz&export=download";
    hash = "sha256-o8pdmwCua7QHQ2a829toHDWSgBcrWeGJdHcFY5z8YKA=";
  };

  nativeBuildInputs = [
    cabextract
    rsync
    python3
  ];

  buildCommand = ''
    mkdir -p $out/lib/firmware
    cp -vr ${finalAttrs.sp12}/lib/firmware/qcom $out/lib/firmware/
    ls -la $out/lib/firmware/qcom/
    ls -la $out/lib/firmware/qcom/x1p42100/

    install -m600 "${finalAttrs.qcvss8380}" $out/lib/firmware/qcom/x1p42100/qcvss8380.mbn

    mkdir -p $out/share
    cp -vr ${finalAttrs.sp12}/usr/share/alsa $out/share


    mkdir -p $out/lib/firmware/ath12k/WCN7850/hw2.0

    #cp -av ${finalAttrs.ath12}/. $out/lib/firmware/ath12k
    #ls -lah $out/lib/firmware/ath12k

    python3 ${finalAttrs.bdencoder} --extract ${finalAttrs.board-2}
    ls -la
    cat board-2.json
    mv "bus=pci,vendor=17cb,device=1107,subsystem-vendor=17cb,subsystem-device=3378,qmi-chip-id=2,qmi-board-id=255.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/board.bin

    find "$out" -exec touch --date=2000-01-01 {} +
  '';
})
