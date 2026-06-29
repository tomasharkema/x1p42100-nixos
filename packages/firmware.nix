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
  version = "200.0.32.1";
  commit = "30e823d85c1fb4e410a4afdf9cd2285914ee712d";

  sp12 = fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "main";
    sha256 = "sha256-CAIzd3BB8stc1AYXBnvpIi1+oHx7Gl1XxzaQ3BQkOn8=";
  };

  ath12 = fetchzip {
    url = "https://git.codelinaro.org/clo/ath-firmware/ath12k-firmware/-/archive/main/ath12k-firmware-main.tar.gz";
    sha256 = "sha256-DGyEp4+UGGuJ0qiM+jaHl6xOd02hCk92j28fIlGSoK4=";
  };

  board-2 = "${linux-firmware}/lib/firmware/ath12k/WCN7850/hw2.0/board-2.bin";
  # "${finalAttrs.ath12}/WCN7850/hw2.0/board-2.bin";

  bdencoder = fetchurl {
    url = "https://raw.githubusercontent.com/qca/qca-swiss-army-knife/f2164085920540f4ecbfa0b12959918c601724b6/tools/scripts/ath12k/ath12k-bdencoder";
    sha256 = "sha256-hzn/GVo7nZmuBpuBsEZUcf928w03cgANq+kaUlGmeYA=";
  };

  nativeBuildInputs = [
    cabextract
    # rsync
    python3
  ];

  # install -m600 "${finalAttrs.qcvss8380}" $out/lib/firmware/qcom/x1p42100/qcvss8380.mbn

  buildCommand = ''
    mkdir -p $out/lib/firmware/qcom
    cp -va ${finalAttrs.sp12}/lib/firmware/qcom $out/lib/firmware/

    #mkdir -p $out/share
    #cp -vr ${finalAttrs.sp12}/usr/share/alsa $out/share

    mkdir -p $out/lib/firmware/ath12k/WCN7850/hw2.0

    #cp -av ${finalAttrs.ath12}/. $out/lib/firmware/ath12k
    #ls -lah $out/lib/firmware/ath12k

    python3 ${finalAttrs.bdencoder} --extract ${finalAttrs.board-2}

    # cat board-2.json
    mv "bus=pci,vendor=17cb,device=1107,subsystem-vendor=17cb,subsystem-device=3378,qmi-chip-id=2,qmi-board-id=255.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/board.bin

    find "$out" -exec touch --date=2000-01-01 {} +
  '';
})
