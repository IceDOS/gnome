{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (config.icedos.desktop.gnome.extensions) appindicator;
in
mkIf appindicator {
  environment.systemPackages = [
    pkgs.gnomeExtensions.appindicator
  ];

  home-manager.sharedModules = [
    {
      dconf.settings."org/gnome/shell".enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
    }
  ];
}
