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
    kernelPatches = [
      {
        name = "gamma";
        patch = fetchpatch {
          url = "https://patchwork.kernel.org/project/linux-arm-msm/patch/20251018-dpu-add-dspp-gc-driver-v1-1-ed0369214252@izzo.pro/mbox/";
          sha256 = "sha256-ez9nsrfhKGiP/YB9LsyRISYPDK1l9G8aqjnacCltQDE=";
        };
      }
    ];

    # structuredExtraConfig = with lib.kernel; {
    #   VIRTUALIZATION = yes;
    #   KVM = yes;
    #   MAGIC_SYSRQ = yes;

    #   # Stuff to reduce compile times.
    #   # ACPI = no;

    #   HOTPLUG_PCI = no;

    #   ARCH_ACTIONS = no;
    #   ARCH_AIROHA = no;
    #   ARCH_SUNXI = no;
    #   ARCH_ALPINE = no;
    #   ARCH_APPLE = no;
    #   ARCH_AXIADO = no;
    #   ARCH_BCM = no;
    #   # ARCH_BCM2835 = no;
    #   # ARCH_BCM_IPROC = no;
    #   # ARCH_BCMBCA = no;
    #   ARCH_BRCMSTB = no;
    #   ARCH_BERLIN = no;
    #   ARCH_BLAIZE = no;
    #   ARCH_CIX = no;
    #   ARCH_EXYNOS = no;
    #   ARCH_SPARX5 = no;
    #   ARCH_K3 = no;
    #   ARCH_LG1K = no;
    #   ARCH_HISI = no;
    #   ARCH_KEEMBAY = no;
    #   ARCH_MEDIATEK = no;
    #   ARCH_MESON = no;
    #   ARCH_MVEBU = no;
    #   ARCH_NXP = no;
    #   # ARCH_LAYERSCAPE = no;
    #   # ARCH_MXC = no;
    #   ARCH_S32 = no;
    #   ARCH_MA35 = no;
    #   ARCH_NPCM = no;
    #   ARCH_REALTEK = no;
    #   ARCH_RENESAS = no;
    #   ARCH_ROCKCHIP = no;
    #   ARCH_SEATTLE = no;
    #   ARCH_INTEL_SOCFPGA = no;
    #   ARCH_SOPHGO = no;
    #   # ARCH_STM32 = no;
    #   ARCH_SYNQUACER = no;
    #   ARCH_TEGRA = no;
    #   # ARCH_TESLA_FSD = no;
    #   ARCH_SPRD = no;
    #   ARCH_THUNDER = no;
    #   ARCH_THUNDER2 = no;
    #   ARCH_UNIPHIER = no;
    #   ARCH_VEXPRESS = no;
    #   ARCH_VISCONTI = no;
    #   ARCH_XGENE = no;
    #   ARCH_ZYNQMP = no;

    #   DRM_NOUVEAU = no;
    #   DRM_ETNAVIV = no;
    #   DRM_HISI_HIBMC = no;
    #   DRM_HISI_KIRIN = no;
    #   DRM_LIMA = no;
    #   DRM_PANFROST = no;
    #   DRM_PANTHOR = no;
    #   DRM_TIDSS = no;
    #   DRM_POWERVR = no;

    #   WLAN_VENDOR_ADMTEK = no;
    #   WLAN_VENDOR_ATMEL = no;
    #   WLAN_VENDOR_BROADCOM = no;
    #   WLAN_VENDOR_INTEL = no;
    #   WLAN_VENDOR_INTERSIL = no;
    #   WLAN_VENDOR_MARVELL = no;
    #   WLAN_VENDOR_MEDIATEK = no;
    #   WLAN_VENDOR_MICROCHIP = no;
    #   WLAN_VENDOR_PURELIFI = no;
    #   WLAN_VENDOR_RALINK = no;
    #   WLAN_VENDOR_REALTEK = no;
    #   WLAN_VENDOR_RSI = no;
    #   WLAN_VENDOR_SILABS = no;
    #   WLAN_VENDOR_ST = no;
    #   WLAN_VENDOR_TI = no;
    #   WLAN_VENDOR_ZYDAS = no;
    #   WLAN_VENDOR_QUANTENNA = no;
    #   # SND_DRIVERS = no;
    #   # SND_PCI = no;
    # };
  })
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
