inputs:
let
  inherit (inputs) nixpkgs self zig2nix;
  lib = nixpkgs.lib.extend (import ./extended.nix);

  inherit (builtins)
    mapAttrs
    readDir
    filter
    listToAttrs
    ;
  inherit (lib)
    nixosSystem
    genAttrs
    isNixFile
    mkDefaultOizysModule
    mkOizysModule
    enabled
    ;
  inherit (lib.filesystem) listFilesRecursive;

  inherit (import ./find-modules.nix { inherit lib; }) findModulesList;
  #supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
  supportedSystems = [ "x86_64-linux" ];
in
rec {
  forAllSystems = f: genAttrs supportedSystems (system: f (import nixpkgs { inherit system; }));
  oizysModules = listToAttrs (findModulesList ../modules);

  mkSystem =
    hostName:
    nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../modules/oizys.nix
        ../overlays
        inputs.lix-module.nixosModules.default
      ] ++ filter isNixFile (listFilesRecursive (../. + "/hosts/${hostName}"));

      specialArgs = {
        inherit
          inputs
          lib
          self
          mkDefaultOizysModule
          mkOizysModule
          enabled
          hostName
          ;
      };
    };

  oizysHosts = mapAttrs (name: _: mkSystem name) (readDir ../hosts);
  oizysPkg = forAllSystems (pkgs: rec {
    oizys-zig = pkgs.callPackage ../pkgs/oizys/oizys-zig { inherit zig2nix; };
    oizys-nim = pkgs.callPackage ../pkgs/oizys/oizys-nim { };
    oizys-rs = pkgs.callPackage ../pkgs/oizys/oizys-rs { };
    oizys-go = pkgs.callPackage ../pkgs/oizys/oizys-go { };
    default = oizys-go;
  });
  oizysShells = forAllSystems (pkgs: {
    default = pkgs.mkShell {
      packages = with pkgs; [
        git
        deadnix
      ];
    };
  });

  oizysChecks = forAllSystems (pkgs: import ./checks.nix { inherit pkgs inputs; });
  oizysFormatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
  oizysFlake = {
    nixosModules = oizysModules;
    nixosConfigurations = oizysHosts;
    packages = oizysPkg;
    devShells = oizysShells;
    formatter = oizysFormatter;
    checks = oizysChecks;
    # checks = forAllSystems (pkgs: {
    #   packageCheck = mkPackageCheck {
    #     inherit pkgs;
    #     # make sure lix is in this?
    #     packages = [
    #       pkgs.pixi
    #       pkgs.swww
    #
    #       inputs.tsm.packages.${pkgs.system}.default
    #       inputs.hyprman.packages.${pkgs.system}.default
    #
    #       inputs.roc.packages.${pkgs.system}.full
    #       inputs.roc.packages.${pkgs.system}.lang-server
    #
    #       inputs.zls.outputs.packages.${pkgs.system}.default
    #       inputs.zig2nix.outputs.packages.${pkgs.system}.zig.master.bin
    #     ];
    #
    #   };
    # });
  };
}
