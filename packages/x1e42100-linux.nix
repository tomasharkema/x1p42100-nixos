{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  ccacheStdenv,
  fetchpatch,
  ...
}:
# linuxPackagesFor ( (buildLinux {
#   version = "6.19";
#   src = fetchFromGitHub {
#     owner = "jglathe";
#     repo = "linux_ms_dev_kit";
#     rev = "jg/ubuntu-qcom-x1e-6.19.0-jg-0";
#     hash = "sha256-PLQaIKZ6Kcwf56CgxNQg45EilTOi6xnjgPjP6BsTcgM=";
#   };
# })
linuxPackagesFor (
  (buildLinux {
    version = "6.19.12";
    src = fetchFromGitHub {
      owner = "jglathe";
      repo = "linux_ms_dev_kit";
      rev = "jg/ubuntu-qcom-x1e-6.19.y";
      hash = "sha256-a5SywS0uGiIkXIORZTte84GJxU1qx6uv14IxqtdxWGQ=";
    };

    kernelPatches = [
      {
        name = "gamma";
        patch = fetchpatch {
          url = "https://patchwork.kernel.org/project/linux-arm-msm/patch/20251018-dpu-add-dspp-gc-driver-v1-1-ed0369214252@izzo.pro/mbox/";
          sha256 = "sha256-ez9nsrfhKGiP/YB9LsyRISYPDK1l9G8aqjnacCltQDE=";
        };
      }
      {
        name = "mac-address";
        patch = ./mac-address.patch;
      }
    ];
  })
# linuxPackagesFor (
#   (buildLinux {
#     version = "6.19";
#     src = fetchFromGitHub {
#       owner = "jglathe";
#       repo = "linux_ms_dev_kit";
#       rev = "jg/sp12_dt";
#       hash = "sha256-dcS5AHP40Saz21ZilNFYX4WtgYf404z+setpywvsopw=";
#     };
#     kernelPatches = [
#       {
#         name = "gamma";
#         patch = fetchpatch {
#           url = "https://patchwork.kernel.org/project/linux-arm-msm/patch/20251018-dpu-add-dspp-gc-driver-v1-1-ed0369214252@izzo.pro/mbox/";
#           sha256 = "sha256-ez9nsrfhKGiP/YB9LsyRISYPDK1l9G8aqjnacCltQDE=";
#         };
#       }
#       {
#         name = "mac-address";
#         patch = ./mac-address.patch;
#       }
#     ];
#   })
# linuxPackagesFor (
#   (buildLinux {
#     version = "6.19.6";
#     src = fetchFromGitHub {
#       owner = "jglathe";
#       repo = "linux_ms_dev_kit";
#       rev = "jg/gpio-mux";
#       hash = "sha256-RxizCZrnyMsSJUwA1f1YikK1xFNBmkR0kJ3oggHcpl0=";
#     };

#     kernelPatches = [
#       {
#         name = "gamma";
#         patch = fetchpatch {
#           url = "https://patchwork.kernel.org/project/linux-arm-msm/patch/20251018-dpu-add-dspp-gc-driver-v1-1-ed0369214252@izzo.pro/mbox/";
#           sha256 = "sha256-ez9nsrfhKGiP/YB9LsyRISYPDK1l9G8aqjnacCltQDE=";
#         };
#       }
#     ];
#   })
   .override {stdenv = ccacheStdenv;}
)
