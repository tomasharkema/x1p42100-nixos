{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  ccacheStdenv,
  ...
}:
# linuxPackagesFor (buildLinux {
#   version = "6.19";
#   src = fetchFromGitHub {
#     owner = "jglathe";
#     repo = "linux_ms_dev_kit";
#     rev = "jg/ubuntu-qcom-x1e-6.19.0-jg-0";
#     hash = "sha256-PLQaIKZ6Kcwf56CgxNQg45EilTOi6xnjgPjP6BsTcgM=";
#   };
# })
# linuxPackagesFor ((buildLinux {
#   version = "6.19";
#   src = fetchFromGitHub {
#     owner = "jglathe";
#     repo = "linux_ms_dev_kit";
#     rev = "jg/ubuntu-qcom-x1e-6.19.y";
#     hash = "sha256-CTbrI+lX6LrhB7lJ3av7e48jGpD4OLd7gIE1+4pCzco=";
#   };
# })
linuxPackagesFor (
  (buildLinux {
    version = "6.19";
    src = fetchFromGitHub {
      owner = "jglathe";
      repo = "linux_ms_dev_kit";
      rev = "jg/sp12_dt";
      hash = "sha256-dcS5AHP40Saz21ZilNFYX4WtgYf404z+setpywvsopw=";
    };
  })
   .override {stdenv = ccacheStdenv;}
)
