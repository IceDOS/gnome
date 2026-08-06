{
  config,
  icedosLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (config.icedos) desktop hardware;
  inherit (desktop) clock gnome;
  inherit (gnome) workspaces;

  resolved = icedosLib.generateAccent config;
in
{
  environment.systemPackages = [ pkgs.gnomeExtensions.user-themes ];

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        dconf.settings =
          let
            idle = desktop.users.${config.home.username}.idle;
            gnomeUser = desktop.users.${config.home.username}.gnome;
          in
          {
            "org/gnome/desktop/input-sources" = {
              # Use different keyboard language for each window
              per-window = true;
            };

            "org/gnome/desktop/interface" = {
              accent-color = resolved.name;
              color-scheme = "prefer-dark";
              clock-format = if clock.hourFormat24 then "24h" else "12h";
              clock-show-seconds = clock.seconds;
              clock-show-date = clock.date;
              clock-show-weekday = clock.weekday;
              show-battery-percentage = hardware.devices.laptop;
              enable-hot-corners = gnome.hotCorners;
            };

            # Disable lockscreen notifications
            "org/gnome/desktop/notifications" = {
              show-in-lock-screen = false;
            };

            "org/gnome/desktop/wm/preferences" = {
              focus-mode = if desktop.windows.focus.followsMouse then "sloppy" else "click";
              num-workspaces = toString workspaces.maxWorkspaces;
            };

            # Disable mouse acceleration
            "org/gnome/desktop/peripherals/mouse" = {
              accel-profile = "flat";
            };

            # Disable file history
            "org/gnome/desktop/privacy" = {
              remember-recent-files = false;
            };

            # Turn off screen
            "org/gnome/desktop/session" = {
              idle-delay = if (idle.disable-monitors.enable) then toString (idle.disable-monitors.seconds) else 0;
            };

            # Set screen lock
            "org/gnome/desktop/screensaver" = {
              lock-enabled = idle.lock.enable;
              lock-delay = toString (idle.lock.seconds);
            };

            # Disable system sounds
            "org/gnome/desktop/sound" = {
              event-sounds = false;
            };

            "org/gnome/mutter" = {
              # Enable window snapping to the edges of the screen
              edge-tiling = true;
              # Enable fractional scaling
              experimental-features = [ "scale-monitor-framebuffer" ];
              dynamic-workspaces = workspaces.dynamicWorkspaces;
            };

            "org/gnome/settings-daemon/plugins/power" = {
              # Auto suspend
              sleep-inactive-ac-type = if (idle.suspend.enable) then "suspend" else "nothing";
              # Auto suspend timeout
              sleep-inactive-ac-timeout = toString (idle.suspend.seconds);
              # Power button shutdown
              power-button-action = gnome.powerButtonAction;
            };

            "org/gnome/shell" = {
              always-show-log-out = true;
              disable-user-extensions = false;
              enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" ];

              favorite-apps = mkIf (gnomeUser.pinned-apps.shell.enable) gnomeUser.pinned-apps.shell.list;
            };

            "org/gnome/shell/keybindings" = {
              # Disable clock shortcut
              toggle-message-tray = [ ];
            };

            # Limit app switcher to current workspace
            "org/gnome/shell/app-switcher" = {
              current-workspace-only = true;
            };
          };
      }
    )
  ];
}
