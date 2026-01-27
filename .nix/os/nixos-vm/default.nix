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
    windowsDeviceId = "DUMMY-DEVICE-ID";
  };
}
