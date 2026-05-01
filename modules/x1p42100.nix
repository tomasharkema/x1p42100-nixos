{
  config,
  pkgs,
  lib,
  ...
}: let
  slbounce = pkgs.callPackage ../packages/slbounce.nix {};
  qebspil = pkgs.callPackage ../packages/qebspil.nix {};
  firm = pkgs.callPackage ./firmware.nix {};

  dtbloader-new = pkgs.dtbloader.overrideAttrs (finalAttrs: {
    pname = "dtbloader";
    version = "1.5.4";

    src = pkgs.fetchFromGitHub {
      owner = "TravMurav";
      repo = "dtbloader";
      tag = "1.5.4";
      hash = "sha256-2M1S8cBsP/wX8ODAIR3iL7tRBhtpruWRIpBjK7bDku8=";
      fetchSubmodules = true;
    };
  });
  qcom-firmware-paths = [
    "qcom/x1p42100/Microsoft/Surface12/adsp_dtbs.elf"
    "qcom/x1p42100/Microsoft/Surface12/adspr.jsn"
    "qcom/x1p42100/Microsoft/Surface12/adsps.jsn"
    "qcom/x1p42100/Microsoft/Surface12/adspua.jsn"
    "qcom/x1p42100/Microsoft/Surface12/battmgr.jsn"
    "qcom/x1p42100/Microsoft/Surface12/cdsp_dtbs.elf"
    "qcom/x1p42100/Microsoft/Surface12/cdspr.jsn"
    "qcom/x1p42100/Microsoft/Surface12/qcadsp8380.mbn"
    "qcom/x1p42100/Microsoft/Surface12/qcadsprpc8380.cat"
    "qcom/x1p42100/Microsoft/Surface12/qccdsp8380.mbn"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmbase8380.bin"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmbase8380_pa_111.bin"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmsuc8380.mbn"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmsucpurwa.mbn"
  ];
  boot-firmware = builtins.listToAttrs (map (v: {
      value = builtins.unsafeDiscardStringContext "${config.hardware.firmware}/lib/firmware/${v}.zst";
      name = "firmware/${v}.zst";
    })
    qcom-firmware-paths);
in {
  hardware = {
    deviceTree = {
      enable = true;
      name = "qcom/x1p42100-microsoft-sp12.dtb";
    };
    enableAllFirmware = true; # lib.mkForce false; # true;;
    enableRedistributableFirmware = true; # lib.mkForce false; # true;;

    firmware = [
      firm
    ];
  };

  systemd.tpm2.enable = false;
  boot = {
    growPartition = false;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        netbootxyz.enable = true;
        edk2-uefi-shell.enable = true;
        consoleMode = "max";
        extraFiles =
          {
            "EFI/systemd/drivers/slbounceaa64.efi" = "${slbounce}/slbounce.efi";
            "EFI/systemd/drivers/qebspilaa64.efi" = "${qebspil}/qebspilaa64.efi";
            "EFI/systemd/drivers/dtbloaderaa64.efi" = "${dtbloader-new}/share/dtbloader/efi/dtbloader.efi";
            "dtbloader/dtbs/${config.hardware.deviceTree.name}" = "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";
          }
          // boot-firmware;
      };
    };

    hardwareScan = true;
    initrd = {
      systemd.tpm2.enable = false;
      availableKernelModules = [
        # Definitely needed for USB:
        "usb_storage"
        "phy_qcom_qmp_combo"
        "phy_snps_eusb2"
        "phy_qcom_eusb2_repeater"
        "tcsrcc_x1e80100"
        "ext4"
        "btrfs"
        "i2c_hid_of"
        "i2c_qcom_geni"
        "dispcc-x1e80100"
        "gpucc-x1p42100"
        "phy_qcom_edp"
        "panel_edp"
        "msm"
        "nvme"
        "phy_qcom_qmp_pcie"
        "uas"
        # Needed with the DP altmode patches
        "ps883x"
        "pmic_glink_altmode"
        "qrtr"
        "ufs_qcom"
        "phy_qcom_qmp_ufs"
        "uas"
        "typec"
        "cdc_ether"
        "r8152"
      ];
      kernelModules = [
        #"ufshcd_qcom"
        "nvme"
        "f2fs"
        "usb_storage"
        "phy_qcom_qmp_combo"
        "phy_snps_eusb2"
        "phy_qcom_eusb2_repeater"
        "uas"
        "msm"
        "dispcc_x1e80100"
        "gpucc_x1p42100"
        "i2c_hid_of"
        "i2c_qcom_geni"
        "typec"
        "r8152"
      ];

      extraFirmwarePaths =
        [
          "qcom/gen71500_sqe.fw.zst"
          "qcom/gen71500_gmu.bin.zst"
          "qcom/gen71500_zap.mbn.zst"

          # "qcom/x1p42100/qcadsp8380.mbn"
          # "qcom/x1p42100/qccdsp8380.mbn"
          # "qcom/x1p42100/qcdxkmsuc8380.mbn"
          # "qcom/x1p42100/qcdxkmsucpurwa.mbn"
          # "qcom/x1p42100/qcvss8380.mbn"
        ]
        ++ qcom-firmware-paths;
    };

    kernelParams = [
      "pd_ignore_unused"
      "clk_ignore_unused"
      "efi=noruntime"
      "pcie_aspm=off"
      "regulator_ignore_unused"
      "id_aa64mmfr0.ecv=1"
      "console=tty0"
      # "cma=128MB"
      # "snd-soc-x1e80100.i_accept_the_danger=1"
    ];

    # kernelPatches = [
    #   {
    #     extraConfig = ''
    #       CLK_X1E80100_CAMCC y
    #       CLK_X1P42100_GPUCC y
    #       HZ_1000 y
    #       MFD_QCOM_RPM y
    #       PCIE_QCOM y
    #       PHY_QCOM_QMP y
    #       PHY_QCOM_QMP_PCIE y
    #       QCOM_CLK_RPM y
    #       REGULATOR_QCOM_RPM y
    #       SCHED_CLUSTER y
    #       TYPEC y
    #     '';
    #     name = "snapdragon-config";
    #     patch = null;
    #   }
    # ];

    kernelPackages = pkgs.callPackage ../packages/x1e42100-linux.nix {};
  };
}
