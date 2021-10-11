==================
MetaWards.analysis
==================

These are analysis functions that make it easy to produce graphs
or perform analyses. These use `pandas <https://pandas.pydata.org>`__
and `matplotlib <https://matplotlib.org>`__, which must both be
installed in able to use the `MetaWards.analysis` functions.

These functions are designed to either be called from within a
`Jupyter notebook <https://jupyter.org>`__, or are used by some of
the ``metawards`` command line tools to create quick outputs. An
example of such a tool is :doc:`metawards-plot <../metawards_plot_help>`.

Core functions include;

* :meth:`~metawards.analysis.save_summary_plots`
    Quick function that creates and saves summary plots from the
    ``results.csv.bz2`` files that are produced by ``metawards``

* :meth:`~metawards.analysis.import_graphics_modules`
    Safely import the graphics modules, and give a useful error message
    if this doesn't work. `metawards.analysis` needs Pandas and matplotlib,
    but these are often not available or are broken on clusters. We safely
    import these modules in this function to prevent any other part
    of ``metawards`` from being affected by a bad pandas or matplotlib
    install.

* :meth:`~metawards.analysis.create_average_plot`
    Create the average plot and return the resulting matplotlib figure.
    Use this to get and view figures in, e.g. a Jupyter notebook

* :meth:`~metawards.analysis.create_overview_plot`
    Create the overview plot and return the resulting matplotlib figure.
    Use this to get and view figures in, e.g. a Jupyter notebook

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_analysis
