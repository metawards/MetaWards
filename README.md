# MetaWards

[![Build status](https://github.com/metawards/MetaWards/workflows/Build/badge.svg)](https://github.com/metawards/MetaWards/actions?query=workflow%3ABuild) [![PyPI version](https://badge.fury.io/py/metawards.svg)](https://pypi.python.org/pypi/metawards) [![Downloads](https://pepy.tech/badge/metawards)](https://pepy.tech/project/metawards) [![DOI](https://joss.theoj.org/papers/10.21105/joss.03914/status.svg)](https://doi.org/10.21105/joss.03914) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5562737.svg)](https://doi.org/10.5281/zenodo.5562737)

* For the most accurate and up to date information please [visit the project website](https://metawards.org).
* For an overview of features please [visit the features page](https://metawards.org/features).
* Please take a read of our [Journal of Open Source Software paper](https://joss.theoj.org/papers/10.21105/joss.03914)
* Please cite according to the CITATION.cff file in this repo.

## Scientific Background

MetaWards implements a stochastic metapopulation model of disease transmission. It can scale from modelling local transmission up to full national- or international-scale metapopulation models.

Please follow the [quick start guide](https://metawards.org/quickstart) to see how to quickly get up and running using MetaWards to model your own custom disease or metapopulation model.

It is was originally developed to support modelling of disease transmission in Great Britain. The complete model description and the original C code are described here;

*  *"The role of routine versus random movements on the spread of disease in Great Britain"*, Leon Danon, Thomas House, Matt J. Keeling, Epidemics, December 2009, 1 (4), 250-258; DOI:[10.1016/j.epidem.2009.11.002](https://doi.org/10.1016/j.epidem.2009.11.002)

*  *"Individual identity and movement networks for disease metapopulations"*, Matt J. Keeling, Leon Danon, Matthew C. Vernon, Thomas A. House Proceedings of the National Academy of Sciences, May 2010, 107 (19) 8866-8870; DOI:[10.1073/pnas.1000416107](https://doi.org/10.1073/pnas.1000416107)

In this model, the population is divided into electoral wards. Disease transmission between wards occurs via the daily movement of individuals. For each ward, individuals contribute to the *force of infection* (FOI) in their *home* ward during the night, and their *work* ward during the day.

This model was recently adapted to model CoVID-19 transmission in England and Wales, with result of the original C code published here;

* *"A spatial model of CoVID-19 transmission in England and Wales: early spread and peak timing"*, Leon Danon, Ellen Brooks-Pollock, Mick Bailey, Matt J Keeling, Philosophical Transactions of the Royal Society B, 376(1829); DOI:[10.1098/rstb.2020.0272](https://doi.org/10.1098/rstb.2020.0272)

This Python code is a port which can identically reproduce the outputs from the original C code as used in that work. This Python code has been optimised and parallelised, with additional testing added to ensure that development and scale-up of MetaWards has been robustly and efficiently conducted.

## Program Info

The package makes heavy use of [cython](https://cython.org) which is used with [OpenMP](https://openmp.org) to compile bottleneck parts of the code to parallelised C. This enables this Python port to run at approximately the same speed as the original C program on one core, and to run several times faster across multiple cores.

The program compiles on any system that has a working C compiler that supports OpenMP, and a working Python >= 3.7. This include X86-64 and ARM64 servers.

The software supports running over a cluster using MPI (via [mpi4py](https://mpi4py.readthedocs.io/en/stable/)) or via simple networking (via [scoop](http://scoop.readthedocs.io)).

Full instructions on how to use the program, plus example job submission scripts can be found on the [project website](https://metawards.org).

## Installation

[Full installation instructions are here](https://metawards.org/install.html).

Binary packages are uploaded to [pypi](https://pypi.python.org/pypi/metawards) for Windows, OS X and Linux (manylinux). The easiest way to install is to type in the console:

```
pip install metawards
```

(this assumes that you have pip installed and are using Python 3.7 or above - if this doesn't work please follow the [full installation instructions](https://metawards.org/install.html)).

Alternatively, you can also install from within R (or RStudio) by typing;

```
library(devtools)
install_github("metawards/rpkg")
metawards::py_install_metawards()
```

But, as you are here, I guess you want to install the latest code from GitHub ;-)

To do that, first clone and install the requirements;

```
git clone https://github.com/metawards/MetaWards
cd MetaWards
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

Next, you can make using the standard Python setup.py script route.

```
CYTHONIZE=1 python setup.py build
CYTHONIZE=1 python setup.py install
```

Alternatively, you can also use the makefile, e.g.

```
make
make install
```

(assuming that `python` is version 3.7 or above)

You can run tests using pytest, e.g.

```
METAWARDSDATA="/path/to/MetaWardsData" pytest tests
```

or you can type

```
make test
```

You can generate the docs using

```
make doc
```

## Running

* [A quick start guide is here](https://metawards.org/quickstart)
* [A complete tutorial is here](https://metawards.org/tutorial)
* [Full usage instructions are here](https://metawards.org/usage.html)

You can either load and use the Python classes directly, or you can run the `metawards` front-end command line program that is automatically installed.

```
metawards --help
```

will print out all of the help for the program.

### Running an ensemble

This program supports parallel running of an ensemble of jobs using [multiprocessing](https://docs.python.org/3.7/library/multiprocessing.html) for single-node jobs, and [mpi4py](https://mpi4py.readthedocs.io/en/stable/) or [scoop](http://scoop.readthedocs.io) for multi-node cluster jobs.

Note that mpi4py and scoop are not installed by default, so you will need to install them before you run on a cluster (e.g. `pip install mpi4py` or `pip install scoop`).

[Full instructions for running on a cluster are here](https://metawards.org/cluster_usage.html)

## History

This is a Python port of the [MetaWards](https://github.com/ldanon/MetaWards) package originally written by Leon Danon. This port has been performed with Leon's support by the [Bristol Research Software Engineering Group](https://www.bristol.ac.uk/acrc/research-software-engineering).
