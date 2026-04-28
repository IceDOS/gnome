{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gnomeExtensions.appindicator
  ];

  home-manager.sharedModules = [
    {
      dconf.settings."org/gnome/shell".enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
    }
  ];
}
