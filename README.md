# Class-Balance Bias in Regularized Regression

This repository hosts the code for the paper _Class-Balance Bias
in Regularized Regression_, including both the code used for the
examples as well as the paper itself.

## Reproducing the Results

The final results from the experiments are available in [data/](data/) and
can be reproduced by calling the scripts in [scripts/experiments/](/scripts/experiments).

### Nix

If you want to ensure to be able to fully reproduce the results here, you
can setup all the dependencies of this project using the nix flake
provided here. You need only to call

```shell
nix develop
```

## Compiling the Paper

The source code for the paper itself is available in [/paper/]
