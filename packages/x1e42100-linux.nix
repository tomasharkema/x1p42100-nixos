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
    rev = "jg/ubuntu-qcom-x1e-6.19.0-jg-0";
    hash = "sha256-PLQaIKZ6Kcwf56CgxNQg45EilTOi6xnjgPjP6BsTcgM=";
  };
})
