{
  lib,
  openjdk,
  fetchurl,
  writeShellApplication,
  nixos,
}:
let
  tnoodleJar = fetchurl {
    url = "https://github.com/thewca/tnoodle/releases/download/v1.2.3/TNoodle-WCA-1.2.3.jar";
    hash = "sha256-6f9qFk7/7op+zcxcGBEdSqCdHeRxtx3iJIiaEoLZjNU=";
  };
  tnoodle = writeShellApplication {
    name = "tnoodle";
    text = ''
      exec ${lib.getExe openjdk} -jar ${tnoodleJar}
    '';
  };
  nixosConfig = nixos (
    { config, ... }: {
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;
      system.stateVersion = config.system.nixos.release;

      users.mutableUsers = false;

      services.displayManager.autoLogin = {
        enable = true;
        user = "demo";
      };

      environment.systemPackages = [ tnoodle ];

      users.groups.demo = { };
      users.users.demo = {
        isNormalUser = true;
        password = "passpass";
        group = "demo";
        extraGroups = [
          "wheel"
        ];
      };
    }
  );
in
nixosConfig.config.system.build.vm
