{
  description = "Advanced Proximal Optimization Toolbox";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          pkgs,
          pkgs-eigen_5,
          self',
          system,
          ...
        }:
        {
          _module.args =
            let
              proxsuiteOverlay = final: prev: {
                proxsuite = prev.proxsuite.overrideAttrs {
                  src = final.lib.fileset.toSource {
                    root = ./.;
                    fileset = final.lib.fileset.unions [
                      ./benchmark
                      ./bindings
                      ./cmake-external
                      ./CMakeLists.txt
                      ./doc
                      ./examples
                      ./include
                      ./package.xml
                      ./test
                    ];
                  };
                  postPatch = "";
                };
              };
              eigen5Overlay = final: prev: {
                eigen = prev.eigen.overrideAttrs (super: rec {
                  version = "5.0.0";
                  src = final.fetchFromGitLab {
                    inherit (super.src) owner repo;
                    tag = version;
                    hash = "sha256-L1KUFZsaibC/FD6abTXrT3pvaFhbYnw+GaWsxM2gaxM=";
                  };
                  patches = [ ];
                  postPatch = "";
                });
              };
            in
            {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ proxsuiteOverlay ];
              };
              pkgs-eigen_5 = import inputs.nixpkgs {
                inherit system;
                overlays = [
                  eigen5Overlay
                  proxsuiteOverlay
                ];
              };
            };
          apps.default = {
            type = "app";
            program = pkgs.python3.withPackages (_: [ self'.packages.default ]);
          };
          packages = {
            default = self'.packages.proxsuite;
            proxsuite = pkgs.python3Packages.proxsuite;
            proxsuite-eigen_5 = pkgs-eigen_5.python3Packages.proxsuite;
          };
        };
    };
}
