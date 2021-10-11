=============
MetaWards.app
=============

This module contains all of the functions needed to write the
``metawards`` command line application.

The ``metawards`` command line application will automatically run itself
in one of three modes;

main
    This is the default mode, and is used when you normally run metawards
    to perform calculations using a single computer. Key functions that are
    used in ``main`` mode are;

    * :meth:`~metawards.app.cli`: The main command line interface
    * :meth:`~metawards.app.parse_args`: Parse command line arguments

    This mode is used to run either single model runs, or to run multiple
    runs in parallel on the same computer via a
    `multiprocessing pool <https://docs.python.org/3.4/library/multiprocessing.html?highlight=process#using-a-pool-of-workers>`__.

worker
    This is the mode used when ``metawards`` detects that it should be
    running as a worker process as part of a simulation run on a large
    cluster. If this is the case, then the application will go to sleep
    until it is called upon as part of a parallel run on multiple
    computers via either a
    `scoop mapping pool <https://scoop.readthedocs.io/en/0.7/usage.html#mapping-api>`__,
    or an
    `mpi4py MPI pool <https://mpi4py.readthedocs.io/en/stable/mpi4py.futures.html#mpipoolexecutor>`__.

    The worker will automatically detect whether scoop or mpi4py is being
    used based on which of these modules have been loaded via the
    ``-m scoop`` or ``-m mpi4py`` command line injector.

    The key function used in ``worker`` mode is;

    * :meth:`~metawards.app.get_parallel_scheme` : Auto-detect scoop or mpi4py

supervisor
    This is the mode used when ``metawards`` detects that it is being
    run across multiple computer nodes in a cluster. This is detected
    automatically via environment variables from common queueing systems
    that supply a ``hostfile``, or by manually specifying a
    ``hostfile`` via the ``--hostfile`` command line argument.

    The ``metawards`` application will choose to parallelise over the
    cluster using `mpi4py <https://mpi4py.readthedocs.io>`__ or
    `scoop <https://scoop.readthedocs.io>`__, depending on what the
    user specifies, which modules are installed, or automatically
    choosing in the order scoop > mpi4py (this order is simply because
    MPI is more error-prone to use automatically).

    Key functions used in ``supervisor`` mode are;

    * :meth:`~metawards.app.get_hostfile`: Get the hostfile
    * :meth:`~metawards.app.get_cores_per_node`: Work out the number of cores per compute node
    * :meth:`~metawards.app.get_threads_per_task`: Work out the number of threads per model run
    * :meth:`~metawards.app.scoop_supervisor`: Run a scoop supervisor to start and manage jobs
    * :meth:`~metawards.app.mpi_supervisor`: Run a mpi4py supervisor to start and manage jobs

All of the above functions (and others in the metawards.app package) are
described :doc:`in more detail here <index_api_MetaWards_app>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_app
