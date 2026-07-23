# AGENTS.md — IceDOS **gnome**

> Utilizes the **IceDOS** framework. The full bible — module structure, config flow,
> the `icedos rebuild --build` test loop, `validate.*` helpers, dep loading — lives in
> **core**: <https://github.com/IceDOS/core/blob/main/AGENTS.md> — this file only
> covers what is specific to **gnome**.

## Non-negotiable rules (full detail in core)
- Build/test only via the `icedos` CLI — **never `sudo nixos-rebuild`**.
- **Never** `git commit/stash/reset/pull` — the user manages git.
- Every option uses a `validate.*`/`mk*Option` helper; **no untyped options**.
- A module's `config.toml` defaults must mirror its `icedos.nix` defaults.
- Format with `icedos nixf .` after editing any `.nix`.
- If a repo or the config root you need isn't checked out locally, **ask the user** for
  its path or permission to `git clone` it — don't guess or clone unprompted.

## Purpose
The GNOME desktop environment for IceDOS, with extensions and customization, under the
`icedos.desktop.gnome` namespace.

## Layout (DE repo)
- **Root `icedos.nix`** = the DE-wide option schema (`options.icedos.desktop.gnome`),
  with defaults read from the **root `config.toml`**.
- `modules/<feature>/icedos.nix` = sub-feature modules: `appindicator`, `arcmenu`,
  `dash-to-panel`, `home`, `wallpaper`.
- `flake.nix` scans the whole repo: `icedosLib.scanModules { path = ./.; filename = "icedos.nix"; }`.

## Module shape here
Same IceDOS module shape as elsewhere; just note the **root `icedos.nix` + root
`config.toml`** pair carries the DE options (extensions toggles, hot corners,
workspaces, slideshow wallpaper, …) rather than a `modules/<name>/` subdir.

## Test a change to this repo
In the config root's `config.toml`, point this repo's `overrideUrl` at your local
checkout (`path:/abs/path/to/gnome`), then `icedos rebuild --build` (no activation).
Live desktop changes only appear after a `switch` and re-login — the **user's** call.

## Notable modules / gotchas
- **Per-user config nests under the shared desktop user submodule**, not a gnome-owned
  `.users` tree: pinned apps live at `icedos.desktop.users.<name>.gnome.pinnedApps`
  (materialised by `desktop/default`'s `genDefaults`). The root `icedos.nix` contributes
  the nested `gnome` sub-option to `desktop.users`. See core's *Per-user (`users`) options*.
- Extensions wired via `extensions.{arcmenu,dashToPanel}`; `appindicator` for tray.
- DE/session changes typically require a re-login to take effect; validate with
  `--build` first.
