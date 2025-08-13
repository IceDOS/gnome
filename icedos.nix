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
  options.icedos =
    let
      gnome = (fromTOML (lib.fileContents ./config.toml)).icedos.desktop.gnome;
    in
    {
      desktop.gnome = {
        accentColor = mkStrOption { default = gnome.accentColor; };

        extensions = {
          arcmenu = mkBoolOption { default = false; };
          dashToPanel = mkBoolOption { default = false; };
        };

        clock = {
          date = mkBoolOption { default = false; };
          weekday = mkBoolOption { default = false; };
        };

        hotCorners = mkBoolOption { default = false; };
        powerButtonAction = mkStrOption { default = gnome.powerButtonAction; };
        titlebarLayout = mkStrOption { default = gnome.titlebarLayout; };

        workspaces = {
          dynamicWorkspaces = mkBoolOption { default = true; };
          maxWorkspaces = mkNumberOption { default = 1; };
        };
      };

      system.users = mkSubmoduleAttrsOption { } {
        desktop.gnome = {
          pinnedApps = {
            arcmenu = {
              enable = mkBoolOption { };
              list = mkStrListOption { };
            };

            shell = {
              enable = mkBoolOption { };
              list = mkStrListOption { };
            };
          };

          startupScript = mkStrOption { };
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

  meta.name = "default";
}
