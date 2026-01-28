{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos-vm";
  system.stateVersion = "25.05";

  # Syncthing receiver (Windows -> NixOS)
  syncReceiver = {
    enable = true;
    folderId = "win-sync";
    folderPath = "/home/nixos/.syncthing";

    # Fill this with the actual Windows Syncthing Device ID.
    windowsDeviceId = "V437FTY-KXSHFX4-56KFXAC-LYJWQTP-ZJLHNLK-LW45GF4-SL36OP3-ION5TA5";
  };
}
