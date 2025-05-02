{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        buildEnv = pkgs.buildFHSEnv {
          name = "build-env";
          targetPkgs = pkgs: [
            pkgs.bashInteractive
            pkgs.gcc-unwrapped
            pkgs.binutils-unwrapped
            pkgs.glibc
            pkgs.cmake
            pkgs.pkg-config
            pkgs.julia-bin
          ];
        };
      in
      {
        # packages.default = pkgs.mkShell {
        #   packages = [
        #     pkgs.bashInteractive
        #   ];
        # };
        #
        devShells.default = buildEnv.env;
      }
    );
}
