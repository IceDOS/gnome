{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) map mapAttrs mkIf;
  cfg = config.icedos;
in
mkIf (cfg.desktop.gnome.extensions.arcmenu) {
  environment.systemPackages = [ pkgs.gnomeExtensions.arcmenu ];

  home-manager.users = mapAttrs (user: _: {
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [ "arcmenu@arcmenu.com" ];
      };

      "org/gnome/shell/extensions/arcmenu" =
        let
          arcmenu = gnomeUser.pinnedApps.arcmenu;
          gnomeUser = cfg.desktop.gnome.users.${user};
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
  }) cfg.users;
}
