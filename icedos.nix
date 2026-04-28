{ icedosLib, lib, ... }:

let
  inherit (icedosLib)
    mkBoolOption
    mkNumberOption
    mkStrListOption
    mkStrOption
    mkSubmoduleAttrsOption
    ;
in
{
  options.icedos.desktop.gnome =
    let
      inherit (lib) readFile;

      inherit ((fromTOML (readFile ./config.toml)).icedos.desktop.gnome)
        accentColor
        clock
        excludeDefaultPackages
        extensions
        hotCorners
        powerButtonAction
        titlebarLayout
        users
        workspaces
        ;
    in
    {
      accentColor = mkStrOption { default = accentColor; };

      clock = {
        date = mkBoolOption { default = clock.date; };
        weekday = mkBoolOption { default = clock.weekday; };
      };

      excludeDefaultPackages = mkStrListOption { default = excludeDefaultPackages; };

      extensions = {
        arcmenu = mkBoolOption { default = extensions.arcmenu; };
        dashToPanel = mkBoolOption { default = extensions.dashToPanel; };
      };

      hotCorners = mkBoolOption { default = hotCorners; };
      powerButtonAction = mkStrOption { default = powerButtonAction; };
      titlebarLayout = mkStrOption { default = titlebarLayout; };

      workspaces = {
        dynamicWorkspaces = mkBoolOption { default = workspaces.dynamicWorkspaces; };
        maxWorkspaces = mkNumberOption { default = workspaces.maxWorkspaces; };
      };

      users =
        let
          inherit (users.username) pinnedApps;
        in
        mkSubmoduleAttrsOption { default = { }; } {
          pinnedApps = {
            arcmenu = {
              enable = mkBoolOption { default = pinnedApps.arcmenu.enable; };
              list = mkStrListOption { default = pinnedApps.arcmenu.list; };
            };

            shell = {
              enable = mkBoolOption { default = pinnedApps.shell.enable; };
              list = mkStrListOption { default = pinnedApps.shell.list; };
            };
          };
        };
    };

  outputs.nixosModules =
    { ... }:
    [
      (
        {
          config,
          icedosLib,
          lib,
          pkgs,
          ...
        }:

        let
          inherit (lib) attrNames filterAttrs;
          inherit (icedosLib) genUserDefaults pkgMapper;

          getModules =
            path:
            map (dir: ./. + ("/modules/" + dir)) (
              attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir path))
            );
        in
        {
          icedos.desktop.gnome.users = genUserDefaults {
            users = config.icedos.users;
          };

          imports = getModules ./modules;
          services.desktopManager.gnome.enable = true;
          programs.dconf.enable = true;
          environment.systemPackages = [ pkgs.gnome-tweaks ];

          environment.gnome.excludePackages =
            with pkgs;
            [
              decibels # Audio player
              epiphany # Web browser
              gnome-calendar
              gnome-characters # Emojis
              gnome-console
              gnome-contacts
              gnome-font-viewer
              gnome-maps
              gnome-music
              gnome-user-docs
              gnome-software
              gnome-system-monitor
              gnome-tour
              gnome-weather
              nixos-render-docs
              simple-scan
              yelp # Help
            ]
            ++ (pkgMapper pkgs config.icedos.desktop.gnome.excludeDefaultPackages);
        }
      )
    ];

  meta = {
    name = "default";

    optionalDependencies = [
      {
        url = "github:icedos/desktop";
        modules = [ "gdm" ];
      }
    ];
  };
}
