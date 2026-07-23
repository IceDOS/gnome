{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (config.icedos) desktop;
  inherit (desktop) gnome;
in
mkIf gnome.extensions.arcmenu {
  environment.systemPackages = [ pkgs.gnomeExtensions.arcmenu ];

  home-manager.sharedModules = [
    (
      { config, ... }:

      {
        dconf.settings = {
          "org/gnome/shell" = {
            enabled-extensions = [ "arcmenu@arcmenu.com" ];
          };

          "org/gnome/shell/extensions/arcmenu" =
            let
              arcmenu = gnomeUser.pinned-apps.arcmenu;
              gnomeUser = desktop.users.${config.home.username}.gnome;
            in
            {
              distro-icon = 6;
              menu-button-icon = "Distro_Icon"; # Use arch icon
              multi-monitor = true;
              menu-layout = "Windows";
              windows-disable-frequent-apps = true;
              windows-disable-pinned-apps = !arcmenu.enable;
              pinned-apps =
                with inputs.home-manager.lib.hm.gvariant;
                (map (s: [
                  (mkDictionaryEntry [
                    "id"
                    s
                  ])
                ]) arcmenu.list);
            };
        };
      }
    )
  ];
}
