{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  ccacheStdenv,
  fetchpatch,
  ...
}:
linuxPackagesFor (
  (buildLinux {
    version = "6.19.14";

linuxPackagesFor (buildLinux {

  src = fetchFromGitHub {
    owner = "jglathe";
    repo = "linux_ms_dev_kit";
    rev = "jg/ubuntu-qcom-x1e-6.18.7-jg-0";
    hash = "sha256-UMWBbby3BtA61NfwSfluXAXQpFCDmnYnID7IrjzIv6A=";
  };
  version = "6.18.7";

})
