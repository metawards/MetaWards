=========
MetaWards
=========

.. image:: https://github.com/metawards/MetaWards/workflows/Build/badge.svg
   :target: https://github.com/metawards/MetaWards/actions?query=workflow%3ABuild
   :alt: Build Status

.. image:: https://badge.fury.io/py/metawards.svg
   :target: https://pypi.python.org/pypi/metawards
   :alt: PyPi version

.. image:: https://img.shields.io/pypi/pyversions/metawards.svg
   :target: https://pypi.org/project/metawards
   :alt: PyPi project

.. image:: https://pepy.tech/badge/metawards
   :target: https://pepy.tech/project/metawards
   :alt: Number of downloads

.. image:: https://img.shields.io/badge/License-GPLv3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0.html
   :alt: License

Please take a look at the :doc:`features <features>` to see what
MetaWards can do. Follow the :doc:`quick start guide <quickstart/index>` to
see how to quickly get up and running using MetaWards to model your own custom
disease or metapopulation model.

Scientific Background
=====================

MetaWards implements a stochastic metapopulation model of disease
transmission. It can scale from modelling local transmission up to
full national- or international-scale metapopulation models.

This is a Python port of the
`MetaWards <https://github.com/ldanon/MetaWards>`__ package originally written
by Leon Danon. This port has been performed with Leon's support by the
`Bristol Research Software Engineering Group
<https://www.bristol.ac.uk/acrc/research-software-engineering/>`__.

It is was originally developed to support modelling of disease transmission
in Great Britain. The complete model description and the
original C code are described here;

*  *"The role of routine versus random movements on the spread of disease
   in Great Britain"*, Leon Danon, Thomas House, Matt J. Keeling,
   Epidemics, December 2009, 1 (4), 250-258; DOI:
   `10.1016/j.epidem.2009.11.002 <https://doi.org/10.1016/j.epidem.2009.11.002>`__

*  *"Individual identity and movement networks for disease metapopulations"*,
   Matt J. Keeling, Leon Danon, Matthew C. Vernon, Thomas A.
   House Proceedings of the National Academy of Sciences,
   May 2010, 107 (19) 8866-8870; DOI:
   `10.1073/pnas.1000416107 <https://doi.org/10.1073/pnas.1000416107>`__

In this model, the population is divided into electoral wards. Disease
transmission between wards occurs via the daily movement of individuals.
For each ward, individuals contribute to the *force of infection* (FOI)
in their *home* ward during the night, and their *work* ward during the
day.

This model was recently adapted to model CoVID-19 transmission in
England and Wales, with result of the original C code
published (pre-print) here;

* *"A spatial model of CoVID-19 transmission in England and Wales:
  early spread and peak timing"*, Leon Danon, Ellen Brooks-Pollock,
  Mick Bailey, Matt J Keeling, medRxiv 2020.02.12.20022566; DOI:
  `10.1101/2020.02.12.20022566 <https://doi.org/10.1101/2020.02.12.20022566>`__

This Python code is a port which can identically reproduce the outputs
from the original C code as used in that work. This Python code has
been optimised and parallelised, with additional testing added to ensure
that development and scale-up of MetaWards has been robustly and
efficiently conducted.

Features
========

.. toctree::
   :maxdepth: 2

   features

Installation
============

.. toctree::
   :maxdepth: 2

   install

Model Data
==========

.. toctree::
   :maxdepth: 2

   model_data

Quick Start Guide
=================

.. toctree::
   :maxdepth: 2

   quickstart/index

Tutorial
========

.. toctree::
   :maxdepth: 2

   tutorial/index

Files
=====

.. toctree::
   :maxdepth: 2

   fileformats/index

Usage
=====

.. toctree::
   :maxdepth: 2

   usage
   cluster_usage

Getting help
============

.. toctree::
   :maxdepth: 2

   support

Contributing
============

.. toctree::
   :maxdepth: 2

   contributing
   devsupport
   roadmap
   packaging
   development
   snaglist

Documentation
=============

.. toctree::
   :maxdepth: 2

   api/index

Changelog
=========
.. toctree::
   :maxdepth: 2

   changelog

Acknowledgements
================
.. toctree::
   :maxdepth: 2

   acknowledgements

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
