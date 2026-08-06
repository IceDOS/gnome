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
    escapeXML
    hasPrefix
    imap0
    length
    mkIf
    mod
    removePrefix
    ;

  inherit (config.icedos) desktop;
  inherit (desktop.gnome) slideshow;

  globalWallpaper = desktop.wallpaper;
  isColor = hasPrefix "color:" globalWallpaper;
  isPath = !isColor && globalWallpaper != "";
  gnomeWallpaper = removePrefix "path:" globalWallpaper;
  colorHex = removePrefix "#" (removePrefix "color:" globalWallpaper);
  isHexColor = builtins.match "[0-9a-fA-F]{6}" colorHex != null;
  imgs = slideshow.images;
  hasSlideshow = (length imgs) > 0;

  next = i: elemAt imgs (mod (i + 1) (length imgs));

  pairs = imap0 (i: img: {
    from = img;
    to = next i;
  }) imgs;

  segment = p: ''
    <static><duration>${toString slideshow.durationSeconds}</duration><file>${escapeXML p.from}</file></static>
    <transition type="overlay"><duration>${toString slideshow.transitionSeconds}</duration><from>${escapeXML p.from}</from><to>${escapeXML p.to}</to></transition>
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
  assertions = [
    {
      assertion = !isColor || isHexColor;
      message = "icedos.desktop.gnome.wallpaper: invalid color '${globalWallpaper}' — expected 'color:#RRGGBB' or 'color:RRGGBB'";
    }
  ];

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
