{ icedosLib, lib, ... }:

let
  inherit (icedosLib)
    mkBoolOption
    mkEnumOption
    mkFloatBetweenOption
    mkIntBetweenOption
    mkStrListOption
    mkSubmoduleAttrsOption
    ;
in
{
  # DE-wide gnome options plus a nested `gnome` contribution to the shared desktop
  # per-user submodule (`icedos.desktop.users`, declared/materialised in the desktop
  # repo). The `users` child declaration MUST omit `default` — only desktop/default
  # (mkUsersOption) sets `default = {}`; two defaulted `attrsOf submodule` decls of
  # the same path fail to type-merge.
  options.icedos.desktop =
    let
      inherit (lib) importTOML;

      desktopCfg = (importTOML ./config.toml).icedos.desktop;

      inherit (desktopCfg.gnome)
        excludeDefaultPackages
        extensions
        hotCorners
        powerButtonAction
        slideshow
        workspaces
        ;

      inherit (desktopCfg.users.username.gnome) pinned-apps;
    in
    {
      gnome = {
        excludeDefaultPackages = mkStrListOption { default = excludeDefaultPackages; };

        extensions = {
          appindicator = mkBoolOption { default = extensions.appindicator; };
          arcmenu = mkBoolOption { default = extensions.arcmenu; };
          dashToPanel = mkBoolOption { default = extensions.dashToPanel; };
        };

        hotCorners = mkBoolOption { default = hotCorners; };

        powerButtonAction =
          mkEnumOption
            {
              path = "icedos.desktop.gnome.powerButtonAction";
              source = ./config.toml;
              default = powerButtonAction;
            }
            [
              "nothing"
              "suspend"
              "hibernate"
              "interactive"
            ];

        slideshow = {
          images = mkStrListOption { default = slideshow.images; };

          durationSeconds = mkFloatBetweenOption {
            path = "icedos.desktop.gnome.slideshow.durationSeconds";
            source = ./config.toml;
            default = slideshow.durationSeconds;
          } 1 86400;

          transitionSeconds = mkFloatBetweenOption {
            path = "icedos.desktop.gnome.slideshow.transitionSeconds";
            source = ./config.toml;
            default = slideshow.transitionSeconds;
          } 0 60;
        };

        workspaces = {
          dynamicWorkspaces = mkBoolOption { default = workspaces.dynamicWorkspaces; };

          maxWorkspaces = mkIntBetweenOption {
            path = "icedos.desktop.gnome.workspaces.maxWorkspaces";
            source = ./config.toml;
            default = workspaces.maxWorkspaces;
          } 1 36;
        };
      };

      users = mkSubmoduleAttrsOption { } {
        gnome.pinned-apps = {
          arcmenu = {
            enable = mkBoolOption { default = pinned-apps.arcmenu.enable; };
            list = mkStrListOption { default = pinned-apps.arcmenu.list; };
          };

          shell = {
            enable = mkBoolOption { default = pinned-apps.shell.enable; };
            list = mkStrListOption { default = pinned-apps.shell.list; };
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

    dependencies = [
      {
        url = "github:icedos/hardware";
        modules = [ ];
      }
    ];

    optionalDependencies = [
      {
        url = "github:icedos/desktop";
        modules = [ "gdm" ];
      }
    ];
  };
}
