{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatMapStrings
    elemAt
    hasPrefix
    imap0
    length
    mkIf
    mod
    removePrefix
    ;

  globalWallpaper = config.icedos.desktop.wallpaper;
  isColor = hasPrefix "color:" globalWallpaper;
  isPath = !isColor && globalWallpaper != "";
  gnomeWallpaper = removePrefix "path:" globalWallpaper;
  colorHex = removePrefix "color:" globalWallpaper;

  slideshow = config.icedos.desktop.gnome.slideshow;
  imgs = slideshow.images;
  hasSlideshow = (length imgs) > 0;

  next = i: elemAt imgs (mod (i + 1) (length imgs));

  pairs = imap0 (i: img: {
    from = img;
    to = next i;
  }) imgs;

  segment = p: ''
    <static><duration>${toString slideshow.durationSeconds}.0</duration><file>${p.from}</file></static>
    <transition type="overlay"><duration>${toString slideshow.transitionSeconds}.0</duration><from>${p.from}</from><to>${p.to}</to></transition>
  '';

  xml = ''
    <?xml version="1.0"?>
    <background>
    ${concatMapStrings segment pairs}
    </background>
  '';

  slideshowFile = pkgs.writeText "icedos-gnome-slideshow.xml" xml;
in
{
  home-manager.sharedModules = [
    (mkIf hasSlideshow {
      dconf.settings."org/gnome/desktop/background" = {
        picture-uri = "file://${slideshowFile}";
        picture-uri-dark = "file://${slideshowFile}";
        picture-options = "zoom";
      };
    })

    (mkIf (!hasSlideshow && isPath) {
      dconf.settings."org/gnome/desktop/background" = {
        picture-uri = "file://${gnomeWallpaper}";
        picture-uri-dark = "file://${gnomeWallpaper}";
        picture-options = "zoom";
      };
    })

    (mkIf (!hasSlideshow && isColor) {
      dconf.settings."org/gnome/desktop/background" = {
        picture-options = "none";
        primary-color = "#${colorHex}";
        secondary-color = "#${colorHex}";
        color-shading-type = "solid";
      };
    })
  ];
}
