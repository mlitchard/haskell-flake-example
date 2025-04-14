{ fs, fs2source,onlyExts-fs,pkgs, lib, inputs, system, ... }:
let
  hlib = pkgs.haskell.lib;

  # Helper to include only Haskell-related files
    onlyHaskell = fs2source
    (fs.union
      (onlyExts-fs
        [
          "cabal"
          "hs"
          "project"
        ]
        ./.)
      ./LICENSE # horizon requires this file to build
    );

  # Custom overlay for additional dependencies or overrides
  myOverlay = final: prev: {
    server = final.callCabal2nix "digspot" (onlyHaskell ./.) { };
    
    # Add any additional package overrides here if needed
    # For example:
    # some-dependency = hlib.doJailbreak (final.callHackage "some-dependency" "0.1.0" {});
  };

  # Create the legacyPackages by extending the horizon-platform
  legacyPackages =
    inputs.horizon-platform.legacyPackages.${system}.extend myOverlay;

  # Helper function to create an executable target
  makeExecutable = target:
    let
      package = hlib.justStaticExecutables 
        (hlib.dontCheck 
          (hlib.setBuildTarget legacyPackages.server target));
    in
    if lib.hasPrefix "exe:" target then
      package.overrideAttrs (old: {
        meta = (old.meta or {}) // { mainProgram = lib.removePrefix "exe:" target; };
      })
    else
      package;

in
{
  inherit legacyPackages;

  # Development shell inputs
  shell-inputs = with pkgs; [
    cabal-install
  ];
  packages = {
    server = makeExecutable "exe:horizon-platform-template";
  };
}
