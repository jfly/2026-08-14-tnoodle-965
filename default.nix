{
  lib,
  openjdk25,
  fetchurl,
  writeShellApplication,
  nixos,
  glib,
}:
let
  tnoodleJar = fetchurl {
    url = "https://github.com/thewca/tnoodle/releases/download/v1.2.3/TNoodle-WCA-1.2.3.jar";
    hash = "sha256-6f9qFk7/7op+zcxcGBEdSqCdHeRxtx3iJIiaEoLZjNU=";
  };
  tnoodle = writeShellApplication {
    name = "tnoodle";
    text = ''
      export LD_LIBRARY_PATH=${lib.getLib glib}/lib
      exec ${lib.getExe openjdk25} -jar ${tnoodleJar}
    '';
  };
  nixosConfig = nixos (
    { config, modulesPath, ... }: {
      imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;
      environment.systemPackages = [ tnoodle ];

      system.stateVersion = config.system.nixos.release;
      users.mutableUsers = false;
      services.displayManager.autoLogin = {
        enable = true;
        user = "demo";
      };
      security.sudo.wheelNeedsPassword = false;
      users.groups.demo = { };
      users.users.demo = {
        isNormalUser = true;
        password = "passpass";
        group = "demo";
        extraGroups = [
          "wheel"
        ];
      };

      virtualisation.memorySize = 2048;
    }
  );
in
nixosConfig.config.system.build.vm
