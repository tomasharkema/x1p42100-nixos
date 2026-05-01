{
  pkgs,
  lib,
  ...
}: {
  boot = {
    blacklistedKernelModules = ["qcom_q6v5_pas"];
    supportedFilesystems = {
      zfs = lib.mkForce false;
      cifs = lib.mkForce false;
    };
  };

  hardware = {
    enableAllHardware = lib.mkForce false; # true;

    enableRedistributableFirmware = lib.mkForce false; # true;
    firmware = with pkgs; [
      linux-firmware
      wireless-regdb
      (pkgs.callPackage ./modules/firmware.nix {})
    ];
  };

  isoImage = {
    forceTextMode = true;
    squashfsCompression = "zstd";
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
}
