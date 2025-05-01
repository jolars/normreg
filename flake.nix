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
              "GR"
              "IterativeSolvers"
              "JSON"
              "Lasso"
              "LanguageServer"
              "LaTeXStrings"
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
              "OrderedCollections"
              "ProgressBars"
              "SparseArrays"
              "Printf"
              "Downloads"
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
