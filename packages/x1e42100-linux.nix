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

    src = fetchFromGitHub {
      owner = "jglathe";
      repo = "linux_ms_dev_kit";
      rev = "jg/ubuntu-qcom-x1e-6.19.y";
      sha256 = "sha256-g2AGoH36ayHn853yuiiiQRikN41c0I4Rgnto55IrTlE=";
    };

    kernelPatches = [
      {
        name = "dpu-add-dspp-gc-driver-v1-1-ed0369214252-add-gamma";
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
   .override {stdenv = ccacheStdenv;}
)
