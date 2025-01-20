# The Choice of Normalization Influences Shrinkage in Regularized Regression

This repository hosts the code for the paper _The Choice of Normalization
Influences Shrinkage in Regularized Regression_.

## Reproducing the Results

The final results from the experiments are available in [results/](results/) and
can be reproduced by calling the scripts in [scripts/experiments/](/scripts/experiments).

### Nix

If you want to ensure to be able to fully reproduce the results here, you can
setup all the dependencies of this project using the nix flake provided in this
repository. You only need to enter the root directory of this project and run
the following nix command.

```shell
nix develop
```

### Julia

This project is based on Julia, and dependencies are declared in
[`Project.toml`](/Project.toml). (We have omitted `Manifest.toml` since
everything is reproducible through the nix flake already.)

Before proceeding, make sure that the folders
<results/> and <plots/> are present in the working
directory (project root). If they are not, then run

```sh
mkdir plots
mkdir results
```

or perform the equivalent options through some graphical user interface.

To activate the project, first start Julia in the project directory (by
just running `julia` in the terminal.

Then activate and instantiate by running the following lines.

```julia
]activate .
]instantiate
```

After this, you can either run the experiments, stored in
[scripts/experiments/](scripts/experiments/), interactively through the REPL,
or run them from the console by calling the following line, replacing
`<experiment>` with whatever experiment you want to run.

```sh
julia --project scripts/experiments/<experiment>.jl
```

The same applies to all the scripts for plotting, which are stored in
