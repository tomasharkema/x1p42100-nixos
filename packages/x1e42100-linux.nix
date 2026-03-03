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
    rev = "jg/ubuntu-qcom-x1e-6.19";
    hash = "sha256-BNQksysGZ4+K2nM/nQKS9L1ON06UvHmDWs58tzJRcuw=";
  };
})
