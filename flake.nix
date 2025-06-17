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
        { pkgs, self', ... }:
        {
          apps.default = {
            type = "app";
            program = pkgs.python3.withPackages (_: [ self'.packages.default ]);
          };
          packages = {
            default = self'.packages.proxsuite;
            proxsuite = pkgs.python3Packages.proxsuite.overrideAttrs {
              src = pkgs.lib.fileset.toSource {
                root = ./.;
                fileset = pkgs.lib.fileset.unions [
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
            };
          };
        };
    };
}
