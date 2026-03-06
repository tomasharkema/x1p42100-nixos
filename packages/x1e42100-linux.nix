{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  ...
}:
linuxPackagesFor (buildLinux {
  version = "6.19";
  src = fetchFromGitHub {
    owner = "jglathe";
    repo = "linux_ms_dev_kit";
    rev = "jg/sp12_dt";
    hash = "sha256-T7Tx66R3qZBD/+iIlNWnqkuZ1rYETa7dyFJn38JRS90=";
  };
})
