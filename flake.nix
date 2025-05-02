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

        devShells.default = buildEnv.env;
      }
    );
}
#
# {
#
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#     systems.url = "github:nix-systems/default";
#   };
#
#   outputs =
#     { systems, nixpkgs, ... }:
#     let
#       eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
#     in
#     {
#       devShells = eachSystem (pkgs: {
#         default = pkgs.mkShell {
#           buildInputs = with pkgs; [
#             go-task
#             (python3.withPackages (
#               ps: with ps; [
#                 matplotlib
#               ]
#             ))
#             (julia_19-bin.withPackages [
#               "ColorSchemes"
#               "CSV"
#               "DataFrames"
#               "DataFramesMeta"
#               "Distributions"
#               "DrWatson"
#               "FileIO"
#               "FilePathsBase"
#               "GLM"
#               "GR"
#               "IterativeSolvers"
#               "JSON"
#               "Lasso"
#               "LanguageServer"
#               "LaTeXStrings"
#               "LinearAlgebra"
#               "MLBase"
#               "Plots"
#               "PlotThemes"
#               "ProjectRoot"
#               "PythonPlot"
#               "QuadGK"
#               "Random"
#               "Revise"
#               "Roots"
#               "SparseArrays"
#               "SpecialFunctions"
#               "OrderedCollections"
#               "ProgressBars"
#               "SparseArrays"
#               "Printf"
#               "Downloads"
#               "Statistics"
#               "StatsBase"
#               "StatsPlots"
#               "Test"
#             ])
#           ];
#         };
#       });
#     };
# }
