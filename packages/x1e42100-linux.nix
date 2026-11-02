{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  ccacheStdenv,
  fetchpatch,
  ...
}: let
  versions = {
    linux_6_19 = {
      version = "6.19.14";
      rev = "jg/ubuntu-qcom-x1e-6.19.y";
      sha256 = "sha256-+geHPb+Y2RxH4Yt/OyBgsQg0iG7RFoXEYcK0C29k4GI=";
    };
    linux_7_1 = {
      version = "7.1.7";
      # rev = "jg/ubuntu-qcom-x1e-7.1.y";
      rev = "jg/ubuntu-qcom-x1e-oldconfig-7.1.y";
      sha256 = "sha256-nxNGVVfitUoFFtutu/MQlrygE0U99l06Rj9/qWOeflY=";
    };
    linux_7_3 = {
      version = "7.3.0";
      rev = "jg/ubuntu-qcom-x1e-7.3.y";
      sha256 = "sha256-72HSJN8LGSvI1GAbqfO1q62pDI1mnj8DdFqtyuNW6jA=";
    };
  };
  selected = versions.linux_7_3;
in
  linuxPackagesFor (
    (buildLinux {
      version = selected.version;

      src = fetchFromGitHub {
        owner = "jglathe";
        repo = "linux_ms_dev_kit";
        inherit (selected) rev sha256;
      };

      kernelPatches = [
        {
          name = "mac-address";
          patch = ./mac-address.patch;
        }
      ];

      structuredExtraConfig = with lib.kernel; {
        CLK_X1E80100_CAMCC = yes;
        CLK_X1P42100_GPUCC = yes;

        # Out-of-tree jglathe driver. No DTS references it (the Slim 5x panel
        # uses "edp-panel"), it still calls the drm_panel_init() that 7.2 made
        # static, and Ubuntu ships CONFIG_DRM_PANEL_SAMSUNG_ATNA40CT01=n.
        # Disable it so nixpkgs' autoModules doesn't try to build it.
        DRM_PANEL_SAMSUNG_ATNA40CT01 = no;
        HZ_1000 = yes;
        MFD_QCOM_RPM = yes;
        PCIE_QCOM = yes;
        PHY_QCOM_QMP = yes;
        PHY_QCOM_QMP_PCIE = yes;
        QCOM_CLK_RPM = yes;
        REGULATOR_QCOM_RPM = yes;
        SCHED_CLUSTER = yes;
        TYPEC = yes;

        VIRTUALIZATION = yes;
        KVM = yes;
        MAGIC_SYSRQ = yes;
      };
    })
    # .override {stdenv = ccacheStdenv;}
  )
