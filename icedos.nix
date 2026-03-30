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

      extensions = {
        arcmenu = mkBoolOption { default = extensions.arcmenu; };
        dashToPanel = mkBoolOption { default = extensions.dashToPanel; };
      };

      clock = {
        date = mkBoolOption { default = clock.date; };
        weekday = mkBoolOption { default = clock.weekday; };
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
          lib,
          pkgs,
          ...
        }:

        let
          inherit (lib) attrNames filterAttrs;

          getModules =
            path:
            map (dir: ./. + ("/modules/" + dir)) (
              attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir path))
            );
        in
        {
          imports = getModules ./modules;
          services.desktopManager.gnome.enable = true;
          programs.dconf.enable = true;
          environment.systemPackages = [ pkgs.gnome-tweaks ];

          environment.gnome.excludePackages = with pkgs; [
            cheese # Camera
            decibels # Audio player
            eog # Image viewer
            epiphany # Web browser
            evince # Document viewer
            geary # Email
            gnome-browser-connector # Install gnome extensions from the browser
            gnome-calendar # Calendar
            gnome-characters # Emojis
            gnome-console # Terminal
            gnome-contacts # Contacts
            gnome-font-viewer # Font viewer
            gnome-maps # Maps
            gnome-music # Music
            gnome-software # Software center
            gnome-system-monitor # System monitoring tool
            gnome-text-editor # Text editor
            gnome-tour # Greeter
            simple-scan # Scanner
            totem # Videos
            yelp # Help
          ];
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
