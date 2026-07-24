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
