{
  description = "Nix overlay packaging steipete/imsg for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      overlay = final: prev: {
        imsg = final.callPackage ./package.nix { };
      };
    in {
      overlays.default = overlay;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in {
          inherit (pkgs) imsg;
          default = pkgs.imsg;
        });
    };
}
