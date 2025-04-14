{
  description = "digspot backend toplevel";

  nixConfig = {
    extra-substituters = "https://horizon.cachix.org";
    extra-trusted-public-keys = "horizon.cachix.org-1:MeEEDRhRZTgv/FFGCv3479/dmJDfJ82G6kfUDxMSAw0=";
  };

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    horizon-devtools.url = "git+https://gitlab.horizon-haskell.net/package-sets/horizon-platform?ref=lts/ghc-9.8.x";
    horizon-platform.url = "git+https://gitlab.horizon-haskell.net/package-sets/horizon-platform?ref=lts/ghc-9.8.x";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, horizon-platform, ... }:
    flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ] (system:
      let
        # Environment record to pass to server module
        env = rec {
          inherit inputs system;
          pkgs = import nixpkgs { inherit system; };
          packages = inputs.self.packages.${system};
          inherit (pkgs) lib;
          fs = lib.fileset;
          onlyExts-fs = exts: fs.fileFilter (f: lib.foldl' lib.or false (map f.hasExt exts));
          fs2source = fs': path:
            fs.toSource {
                root = path;
                fileset = fs';
              };
          # Import the server module
          server = import ./horizon-platform-template env;

        };

      in
      {
        # Use the server's legacyPackages
        legacyPackages = env.server.legacyPackages;

        # Setup development shell
        devShells.default = env.server.legacyPackages.shellFor {
          packages = p: [ p.server ];
          buildInputs = [
            env.server.legacyPackages.cabal-install
          ] ++ env.server.shell-inputs;
        };

        # Export packages from the server module
        packages = env.server.packages // {
          default = env.server.packages.server;
        };
      }
    );
}
