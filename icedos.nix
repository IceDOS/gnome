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
  options.icedos.desktop =
    let
      inherit (lib) readFile;

      desktopCfg = (fromTOML (readFile ./config.toml)).icedos.desktop;

      inherit (desktopCfg.gnome)
        excludeDefaultPackages
        extensions
        hotCorners
        powerButtonAction
        slideshow
        workspaces
        ;

      inherit (desktopCfg.users.username.gnome) pinnedApps;
    in
    {
      gnome = {
        excludeDefaultPackages = mkStrListOption { default = excludeDefaultPackages; };

        extensions = {
          arcmenu = mkBoolOption { default = extensions.arcmenu; };
          dashToPanel = mkBoolOption { default = extensions.dashToPanel; };
        };

        hotCorners = mkBoolOption { default = hotCorners; };
        powerButtonAction = mkStrOption { default = powerButtonAction; };

        slideshow = {
          images = mkStrListOption { default = slideshow.images; };
          durationSeconds = mkNumberOption { default = slideshow.durationSeconds; };
          transitionSeconds = mkNumberOption { default = slideshow.transitionSeconds; };
        };

        workspaces = {
          dynamicWorkspaces = mkBoolOption { default = workspaces.dynamicWorkspaces; };
          maxWorkspaces = mkNumberOption { default = workspaces.maxWorkspaces; };
        };
      };

      # Contributes `gnome` to the desktop per-user submodule (declared in
      # icedos/desktop). Module-merge means gnome per-user config lives at
      # icedos.desktop.users.<name>.gnome and materialises via desktop's genDefaults.
      users = mkSubmoduleAttrsOption { default = { }; } {
        gnome.pinnedApps = {
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
          pkgs,
          ...
        }:

        let
          inherit (icedosLib) getModules;
          inherit (icedosLib.pkgs) mapper;
          inherit (config) icedos;
        in
        {
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
            ++ (mapper pkgs icedos.desktop.gnome.excludeDefaultPackages);
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
