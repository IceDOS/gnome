# IceDOS gnome

The GNOME desktop environment for [IceDOS](https://github.com/IceDOS/core) — extensions,
customisation and a slideshow wallpaper under the `icedos.desktop.gnome` namespace.

Enable it from your config root by adding the repo (same as any DE):

```toml
[[icedos.repositories]]
url = "github:icedos/gnome"
fetchOptionalDependencies = true # pulls gdm
```

Tune it with the options under `icedos.desktop.gnome` — see `icedos.nix` (schema) and
`config.toml` (defaults) in this repo, or run `icedos configuration search --options icedos.desktop.gnome`.

## Documentation

- **This repo's conventions:** [`AGENTS.md`](./AGENTS.md)
- **Framework internals** (module structure, config flow, the `icedos rebuild --build`
  test loop, dep loading): [IceDOS/core `AGENTS.md`](https://github.com/IceDOS/core/blob/main/AGENTS.md)

## License

[GPL-3.0-or-later](./LICENSE)
