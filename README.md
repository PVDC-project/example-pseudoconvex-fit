# Pseudoconvex fit
This repository contains MATLAB code for fitting a [pseudoconvex function](https://en.wikipedia.org/wiki/Pseudoconvex_function) to a given dataset.
Three main types of functions are used for the approximation:

- kernel regression, based on Section II in [this paper](https://ieeexplore.ieee.org/document/9699361)
- a cubic function, with coefficient constraints described in [this paper](https://ieeexplore.ieee.org/document/8302960)
- a polynomial function of arbitrary order

For a generic polynomial function, the pseudoconvexity constraints are imposed following the approach described [here](https://yalmip.github.io/example/polynomialdesign/), which is based on [sum-of-squares programming](https://www.princeton.edu/~aaa/Public/Teaching/ORF523/ORF523_Lec15.pdf).

The fitting problem is formulated and solved using [YALMIP](https://yalmip.github.io/).

This example fits such functions to data representing the losses of an electric motor. The approximation is then used to determine the optimal torque split for an electric vehicle with multiple drivetrains.

Determining the optimal torques can be done using a grid search, also called "direct test", or by formulating and solving a nonlinear optimization problem. The optimization-based approach can be tested using the following software:

- [YALMIP](https://yalmip.github.io/) - uses `fmincon` or another interfaced NLP solver
- [CasADi](https://web.casadi.org/) - v3.6.7 or higher is required
- [acados](https://docs.acados.org/) - v0.4.0 or higher is required