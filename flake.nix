{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { systems, nixpkgs, ... }:
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
            go-task
            (julia-lts.withPackages [
              "ColorSchemes"
              "CSV"
              "DataFrames"
              "DataFramesMeta"
              "Distributions"
              "DrWatson"
              "FileIO"
              "FilePathsBase"
              "GLM"
              "IterativeSolvers"
              "JSON"
              "Lasso"
              "LanguageServer"
              "LaTeXStrings"
              "LIBSVMdata"
              "LinearAlgebra"
              "MLBase"
              "Plots"
              "PlotThemes"
              "ProjectRoot"
              "PythonPlot"
              "QuadGK"
              "Random"
              "Revise"
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
