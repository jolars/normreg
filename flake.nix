{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { systems, nixpkgs, ... }@inputs:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = eachSystem (pkgs: {
        hello = pkgs.hello;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (julia-lts.withPackages [
              "Lasso"
              "CSV"
              "ColorSchemes"
              "DataFrames"
              "DataFramesMeta"
              "Distributions"
              "DrWatson"
              "FileIO"
              "FilePathsBase"
              "GLM"
              "IterativeSolvers"
              "JSON"
              "LIBSVMdata"
              "LaTeXStrings"
              "LinearAlgebra"
              "MLBase"
              "PlotThemes"
              "Plots"
              "ProjectRoot"
              "PythonPlot"
              "QuadGK"
              "Random"
              "Roots"
              "SparseArrays"
              "SpecialFunctions"
              "Statistics"
              "StatsBase"
              "StatsPlots"
              "Test"
            ])
          ];
        };
      });
    };
}
