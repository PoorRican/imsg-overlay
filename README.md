# imsg-overlay

Nix overlay packaging [`steipete/imsg`](https://github.com/steipete/imsg) for macOS.

What this repo provides:
- `overlay.nix` for easy import into an existing Nix setup
- `flake.nix` exposing `packages.<system>.imsg`
- `package.nix` with vendored Swift dependency pins via `Package.resolved`

## Quick start with flakes

Build:

```bash
cd ~/repos/imsg-overlay
nix build .#imsg
```

Run:

```bash
nix run .#imsg -- --help
```

## Use as an overlay

```nix
{
  inputs.imsg-overlay.url = "path:~/repos/imsg-overlay";

  outputs = { self, nixpkgs, imsg-overlay, ... }: {
    darwinConfigurations.my-mac = nixpkgs.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ imsg-overlay.overlays.default ];
          environment.systemPackages = [ pkgs.imsg ];
        })
      ];
    };
  };
}
```

For non-flake usage, import `overlay.nix` directly.

## Notes

- This package is macOS-only.
- `imsg` still needs Messages.app access on the host:
  - Full Disk Access for your terminal to read `~/Library/Messages/chat.db`
  - Automation permission for your terminal to control Messages.app for sends
- Upstream currently targets macOS 14+.

## Updating

1. Update `version` and source hash in `package.nix`
2. Refresh `Package.resolved` from upstream for the target release
3. Update the vendored dependency revisions and hashes in `package.nix`
4. Rebuild with `nix build .#imsg`
