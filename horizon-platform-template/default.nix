{ pkgs, fs, onlyExts-fs, fs2source, lib, lu-pkgs, inputs, system, ... }:
let
  hlib = pkgs.haskell.lib;
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
    server = final.callCabal2nix "horizon-platform-template" (onlyHaskell ./.) { };
  };
  devtools = inputs.horizon-devtools.packages.${system};


  # Create the legacyPackages by extending the horizon-platform
  legacyPackages =
    inputs.horizon-platform.legacyPackages.${system}.extend myOverlay;

  # Build a specific executable by using the Haskell package and extracting just the exe
  buildExe = exeName:
    pkgs.runCommand exeName {} ''
      if [ ! -d "$out/bin" ]; then
        mkdir -p $out/bin
      fi

      # Find the executable in the server package
      SERVER_BIN="${legacyPackages.server}/bin/${exeName}"

      if [ -f "$SERVER_BIN" ]; then
        # If found, copy it to our output
        cp "$SERVER_BIN" "$out/bin/"
        chmod +x "$out/bin/${exeName}"
      else
        # If not found, fail with a helpful error message
        echo "ERROR: Could not find the executable '${exeName}' in ${legacyPackages.server}/bin/"
        ls -la ${legacyPackages.server}/bin/
        exit 1
      fi
    '';
  oneTarget = target:
    let
      package =
        hlib.justStaticExecutables
          (hlib.dontCheck
            (hlib.setBuildTarget legacyPackages.server target));
    in
    if lib.hasPrefix "exe:" target then
      package.overrideAttrs
        { meta.mainProgram = lib.removePrefix "exe:" target;}
    else
     package;
in
{
  inherit legacyPackages;

  # Development shell inputs
  shell-inputs = with pkgs; [
    legacyPackages.cabal-install  # Use cabal-install from the legacyPackages
  ] ++ lib.optionals (system == "x86_64-linux" || system == "aarch64-linux") (with pkgs; [
    devtools.ghcid
    devtools.haskell-language-server
  ]);

  # Define your executable packages
  packages = {
    server = legacyPackages.server;
    digspot = buildExe "digspot-server";
    migration = buildExe "migration";
  };
}
