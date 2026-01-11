{
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.deviceTree = {
    enable = true;
    name = "qcom/x1p42100-lenovo-ideapad-slim5x-oled.dtb";
  };

  systemd.tpm2.enable = false;
  boot = {
    initrd = {
      systemd.tpm2.enable = false;
      availableKernelModules = [
        # Definitely needed for USB:
        "usb_storage"
        "phy_qcom_qmp_combo"
        "phy_snps_eusb2"
        "phy_qcom_eusb2_repeater"
        "tcsrcc_x1e80100"

        "i2c_hid_of"
        "i2c_qcom_geni"
        "dispcc-x1e80100"
        "gpucc-x1p42100"
        "phy_qcom_edp"
        "panel_edp"
        "msm"
        "nvme"
        "phy_qcom_qmp_pcie"

        # Needed with the DP altmode patches
        "ps883x"
        "pmic_glink_altmode"
        "qrtr"
      ];
      kernelModules = [
        "nvme"
        "f2fs"
      ];
      extraFirmwarePaths = [
        "qcom/gen71500_sqe.fw"
        "qcom/gen71500_gmu.bin"
        "qcom/x1p42100/gen71500_zap.mbn"
        "qcom/x1p42100/LENOVO/83HL/qcadsp8380.mbn"
        "qcom/x1p42100/LENOVO/83HL/qccdsp8380.mbn"
        "qcom/x1p42100/LENOVO/83HL/qcdxkmsucpurwa.mbn"
      ];
    };

    kernelParams = [
      "pd_ignore_unused"
      "clk_ignore_unused"
      #"console=tty1"
    ];

    kernelPatches = [
      {
        extraConfig = ''
          CLK_X1E80100_CAMCC y
          CLK_X1P42100_GPUCC y
          HZ_1000 y
          MFD_QCOM_RPM y
          PCIE_QCOM y
          PHY_QCOM_QMP y
          PHY_QCOM_QMP_PCIE y
          QCOM_CLK_RPM y
          REGULATOR_QCOM_RPM y
          SCHED_CLUSTER y
          TYPEC y
        '';
        name = "snapdragon-config";
        patch = null;
      }
    ];

    kernelPackages = pkgs.callPackage ../packages/x1e42100-linux.nix { };
  };
}
