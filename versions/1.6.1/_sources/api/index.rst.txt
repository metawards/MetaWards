=============
Documentation
=============

The metawards program and associated Python module is composed
of six main units;

* The :doc:`metawards <index_MetaWards_app>` command line program, which is
  what most people would use to run metawards. This program comes with
  full help that is provided by typing ``metawards --help``.

* The :doc:`metawards <index_MetaWards>` top-level Python module, which is
  what you should use if you want to write new Python programs that
  integrate metawards functionality. These could include plugging
  metawards as a model into a higher-level statictical
  analysis package.

* The :doc:`metawards.iterators <index_MetaWards_iterators>` module,
  which contains
  all of the package-supplied iterators that are used to advance the
  model infection from day to day. These are used to customise exactly
  how an infection progresses, and how control measures are applied.
  This is described in the :doc:`tutorial <../tutorial/index_part03>`.

* The :doc:`metawards.extractors <index_MetaWards_extractors>` module,
  which contains
  all of the package-supplied extractors that are used to extract and
  output data gathered live during a model run and write them to files.
  These are used to customise exactly what information is gathered,
  how it is processed, and where it is written as the infection progresses.
  You can see how to use these to customise output in
  the :doc:`tutorial <../tutorial/index_part04>`.

* The :doc:`metawards.mixers <index_MetaWards_mixers>` module, which
  contains all of
  the package-supplied mixers that are used to merge and mix values
  calculated across multiple demographic sub-networks. These are used
  to customise exactly how different demographics interact and how
  the disease should move between demographics. You can see how to use
  mixers in the :doc:`tutorial <../tutorial/index_part05>`.

* The :doc:`metawards.movers <index_MetaWards_movers>` module, which
  contains all of package-supplied movers that are used to move
  individuals between different demographics during an outbreak
  (e.g. move between home and hospital, work and holiday etc.).
  You can see how to use movers in the
  :doc:`tutorial <../tutorial/index_part06>`.

* The :doc:`metawards.analysis <index_MetaWards_analysis>` contains
  analysis functions that can be used to process the results of a
  ``metawards`` run to generate insights and useful graphics.

* The :doc:`metawards.utils <index_MetaWards_utils>` utility Python module
  which contains lots of functions that are used by metawards to build and
  perform model runs. These functions are internal to metawards and are
  not designed to be used outside of this program.

* The :doc:`metawards.themes <index_MetaWards_themes>` module contains
  the themes that are used to style the console output and spinners
  used by MetaWards. Choose the theme using the ``--theme`` option,
  e.g. ``--theme default`` or ``--theme simple``.

.. toctree::
   :maxdepth: 1

   index_MetaWards_app
   index_MetaWards
   index_MetaWards_iterators
   index_MetaWards_extractors
   index_MetaWards_mixers
   index_MetaWards_movers
   index_MetaWards_analysis
   index_MetaWards_utils
   index_MetaWards_themes
