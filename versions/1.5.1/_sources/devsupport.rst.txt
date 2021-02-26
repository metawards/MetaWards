=================
Developer Support
=================

``metawards`` comes with a set of functionality that, we hope, will make
it easier for you to develop the code.

Profiling
---------

Use the ``--profile`` command-line option to switch on profiling. This
is very detailed and is free (doesn't affect the run-time). Use this
if you think the code is slow, or to examine the scaling of parallel
sections.

This will print out a tree showing the call path and the amount of time
in each function or sub-section of the function (more on that later ;-)).

For example, running;

.. code-block:: bash

   metawards -d lurgy --profile

gives;

::

  Total time: 3548.695 ms (3548.695 ms)
    \-Network.build: 3548.695 ms (3546.863 ms)
        \-build_function: 3143.628 ms (3143.561 ms)
            \-build_wards_network: 3143.561 ms (3081.800 ms)
                \-read_work_file: 1232.249 ms
                \-fill_in_gaps: 5.017 ms
                \-build_play_matrix: 1752.456 ms (1752.430 ms)
                    \-build_play_matrix: 1752.430 ms (1751.152 ms)
                        \-allocate_memory: 353.156 ms
                        \-read_play_file: 1367.946 ms
                        \-renormalise?: 0.003 ms
                        \-renormalise_loop: 5.227 ms
                        \-fill_in_gaps: 10.288 ms
                        \-read_play_size_file: 14.532 ms
                \-resize_nodes_and_links: 92.078 ms
        \-read_and_validate: 11.067 ms
        \-add_distances: 256.749 ms
        \-add_lookup: 88.264 ms
        \-read_done_file: 3.898 ms
        \-reset_everything: 9.651 ms (9.033 ms)
            \-reset_work: 4.989 ms
            \-reset_play: 4.008 ms
            \-reset_susceptibles: 0.021 ms
            \-reset_params: 0.015 ms
        \-rescale_play_matrix: 11.787 ms
        \-move_from_play_to_work: 21.819 ms

for the timing for building the Network, and

::

  Total time: 75.417 ms (75.417 ms)
    \-timing for day 3: 75.417 ms (74.053 ms)
        \-<function advance_additional at 0x10186c0e0>: 0.014 ms (0.002 ms)
            \-additional_seeds: 0.002 ms
        \-<built-in function advance_foi>: 13.983 ms (13.942 ms)
            \-setup: 0.031 ms
            \-loop_over_classes: 13.911 ms (13.843 ms)
                \-work_0: 3.539 ms
                \-play_0: 0.014 ms
                \-work_1: 3.411 ms
                \-play_1: 0.014 ms
                \-work_2: 3.421 ms
                \-play_2: 0.013 ms
                \-work_3: 3.418 ms
                \-play_3: 0.013 ms
        \-<built-in function advance_recovery>: 6.339 ms (6.311 ms)
            \-recovery: 6.311 ms
        \-<built-in function advance_infprob>: 0.067 ms (0.042 ms)
            \-infprob: 0.042 ms
        \-<built-in function advance_fixed>: 11.027 ms (10.990 ms)
            \-fixed: 10.990 ms
        \-<built-in function advance_play>: 5.347 ms (5.297 ms)
            \-play: 5.297 ms
        \-<built-in function output_core>: 29.488 ms
        \-<function output_basic at 0x10185e8c0>: 0.710 ms
        \-<built-in function output_dispersal>: 0.428 ms
        \-<function output_incidence at 0x10185ef80>: 3.333 ms
        \-<function output_prevalence at 0x101867320>: 3.317 ms

for the timing of each iteration.

.. note::
   The timings will vary for each iteration as more individuals are
   infected. It will also vary depending on the computer and number
   of threads used.

Each level of the tree gives the total time within that tree, e.g.
``timing for day 3: 75.417 ms (74.053 ms)`` is the total time spent
in all of the sub-functions used to calculate ``day 3``. The first
number (``75.417 ms``) is the actual measured time, while the number
in brackets (``74.053 ms``) is the sum of the reported measured times for
the sub-functions. Any large different between the two indicates that
some time is not being reported.

Profiler
--------

You control what is reported using the :class:`metawards.utils.Profiler` class.
You start timing using ``profiler = profiler.start("name of section")`` and you
stop timing using ``profiler = profiler.stop()``. For example using the
iterator ``iterate_profile.py``;

.. code-block:: python

    from metawards.utils import Profiler

    import time

    def advance_profile(profiler: Profiler, **kwargs):
        p = profiler.start("timing advance_profile")

        for i in range(0, 10):
            p = p.start(f"Timing loop iteration {i}")
            time.sleep(0.02)
            p = p.stop()

        p.stop()

    def iterate_profile(**kwargs):
        return [advance_profile]

and then running using;

.. code-block:: bash

   metawards -d lurgy --iterator iterate_profile

gives this in the output;

::

      \-<function advance_profile at 0x1092bc5f0>: 228.184 ms (228.175 ms)
          \-timing advance_profile: 228.175 ms (228.038 ms)
              \-Timing loop iteration 0: 20.354 ms
              \-Timing loop iteration 1: 25.021 ms
              \-Timing loop iteration 2: 23.624 ms
              \-Timing loop iteration 3: 22.029 ms
              \-Timing loop iteration 4: 20.011 ms
              \-Timing loop iteration 5: 25.011 ms
              \-Timing loop iteration 6: 21.608 ms
              \-Timing loop iteration 7: 25.014 ms
              \-Timing loop iteration 8: 21.466 ms
              \-Timing loop iteration 9: 23.900 ms

As you can see, the ``time.sleep(0.02)`` slept for a little-over
20 milliseconds. As with all profiling, it is worth repeating runs
several times and taking an average, especially if you are interested
in plotting parallel scaling of the individual ``metawards`` functions.

.. note::
   A :class:`~metawards.utils.Profiler` is always passed as the ``profiler``
   keyword argument to all of the plugin classes (iterators, extractors etc.)

By default, all plugin functions are timed, hence why in the output
you can see all of the ``advance_functions`` and ``output_functions`` that
were called, in which order, and how long they took. This is actually
the easiest way to debug whether your plugin function has been called - just
run using ``--profile`` and see if your function is listed in the timing.

printf Debugging
----------------

``metawards`` developers are big fans of
`printf debugging <https://tedspence.com/the-art-of-printf-debugging-7d5274d6af44>`__.

All printing in ``metawards`` is handled using the
:class:`metawards.utils.Console` object, which comes with a handy
:meth:`~metawards.utils.Console.debug` function. Use this to print
debug messages, and, optionally, also the values of variables by passing
them as a list to the ``variables`` keyword, e.g. using an iterator
in the file ``iterate_debug.py``;

.. code-block:: python

    from metawards import Population
    from metawards.iterators import iterate_default
    from metawards.utils import Console

    def iterate_debug(population: Population, **kwargs):
        beta_scale = 0.5
        Console.debug("Hello!", variables=[population, beta_scale])

        return iterate_default(population=population, **kwargs)

and running ``metawards`` using the ``--debug`` keyword;

.. code-block:: bash

    metawards -d lurgy --iterator iterate_debug --debug

you will see;

::

    [12:33:05]                           Hello!                            iterate_debug.py:7

            Name │ Value
     ════════════╪═══════════════════════════════════════════════════════════════════════════
      population │ 2020-05-20: DAY: 0 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0
                 │ TOTAL POPULATION 56082077
      beta_scale │ 0.5


printed for every iteration.

.. note::

   The time of the printout is on the top-left, and the filename and line
   for the debug statement is on the top-right. The time is only printed
   once for each second, so if you have a lot of debug statements printed
   in a single second then they won't show the time.

The debug output is only printed when you run ``metawards`` using the
``--debug`` command line argument, so it is safe to leave in
production code.

Debugging levels
----------------

You can optionally set the debugging level of your output using
the ``level`` keyword argument, e.g.

.. code-block:: python

    from metawards import Population
    from metawards.iterators import iterate_default
    from metawards.utils import Console

    def iterate_debug(population: Population, **kwargs):
        beta_scale = 0.5
        Console.debug("Hello!", variables=[population, beta_scale],
                      level=3)

        return iterate_default(population=population, **kwargs)

would only print out if the debugging level was ``3`` or above.

You can set the level using the ``--debug-level`` command line argument,
e.g.

.. code-block:: bash

   metawards -d lurgy --iterator iterate_debug --debug --debug-level 5

would set the debug level to ``5``, which is above ``3``,
and so the debug output will be printed;

::

    [12:53:02]                      Level 3: Hello!                       iterate_debug.py:10

            Name │ Value
     ════════════╪═══════════════════════════════════════════════════════════════════════════
      population │ 2020-05-22: DAY: 2 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0
                 │ TOTAL POPULATION 56082077
      beta_scale │ 0.5

If the level was below ``3``, or was not set, then this debug output would
not be printed.

Debugging lambdas
-----------------

It is better to avoid constructing expensive debug strings if they are
not going to be printed to the screen. There are two ways to avoid this;

1. Use the :meth:`~metawards.utils.Console.debugging_enabled` function of
   :class:`~metawards.utils.Console` to see if debugging is enabled for
   the level you wish, and only call
   :meth:`Console.debug <metawards.utils.Console.debug>` if it is.

2. Put your debug string into a lambda function. The
   :meth:`Console.debug <metawards.utils.Console.debug>`
   function will call this lambda function only if the debug output
   is enabled. This is really easy to do, e.g. here we change the
   debug statement to;

.. code-block:: python

    from metawards import Population
    from metawards.iterators import iterate_default
    from metawards.utils import Console

    def iterate_debug(population: Population, **kwargs):
        beta_scale = 0.5
        Console.debug(lambda: "Hello!", variables=[population, beta_scale],
                      level=3)

        return iterate_default(population=population, **kwargs)

such that we use ``lambda: "Hello!"`` instead of
``"Hello!"``. This converts the string into a lambda function, meaning
that it should not be generated unless the debug statement is
actually printed.

Testing
-------

``metawards`` has a
`large test suite <https://github.com/metawards/MetaWards/tree/devel/tests>`__
built using `pytest <https://docs.pytest.org/en/latest/>`__.
We encourage you to
look through the tests and use these to help learn how to use the classes.
We also encourage you to write your own tests for your new code :-)
