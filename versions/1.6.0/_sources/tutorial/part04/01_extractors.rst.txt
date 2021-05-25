=================
Custom extractors
=================

You have now learned how to use custom iterators to customise the
advancement of the outbreak during a model run.

In a similar way, ``metawards`` provides custom extractors that
enable you to customise the output that is produced and written
to a file (or files).

Hello extractors
----------------

You create an extractor in an almost identical manner as an iterator.
Start by creating a python file called ``hello.py`` and copy in the
below;

.. code-block:: python

  from metawards.utils import Console

  def extract_hello(**kwargs):
      Console.print("Hello extract_hello")

      return []

The extractor is passed using the ``--extractor`` command-line argument.
Run ``metawards`` using;

.. code-block:: bash

   metawards --extractor hello

You should see output something similar to this;

::

    Importing a custom extractor from hello
    Loaded hello from hello.py
    <function extract_hello at 0x1068599e0>
    Building a custom extractor for <function extract_hello at 0x1068599e0>
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello extract_hello
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello extract_hello
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello extract_hello
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello extract_hello
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello extract_hello
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0
    Infection died ... Ending on day 5

extract_XXX and output_XXX
--------------------------

At the end of each model day, ``metawards`` calls the
:meth:`~metawards.utils.extract` function. This calls your ``extract_XXX``
function. The signature is very similar to the custom iterator functions,
namely it should take ``**kwargs``, and then return a list of functions
that :meth:`~metawards.utils.extract` will then call to output data
(what we term ``output_XXX`` functions).

At the moment, nothing is being written to the output directory. We
can change this by adding an ``output_XXX`` function. For example,
create a new python file called ``population.py`` and copy in
the below;

.. code-block:: python

    from metawards.utils import Console

    def output_population(population, output_dir, **kwargs):
        Console.debug("Hello output_population")

        # create an output file called 'population.dat'
        popfile = output_dir.open("population.dat")

        # write the population to this file
        popfile.write(f"{population.day} {population.date.isoformat()} "
                      f"{population.susceptibles} {population.latent} "
                      f"{population.total} {population.recovereds}\n")

    def extract_population(**kwargs):
        Console.debug("hello extract_population")

        return [output_population]

This defines two functions;

* ``extract_population``, which tells ``metawards`` to use your
  ``output_population`` function,

* and ``output_population`` that uses the passed
  :class:`population <metawards.Population>` and
  :class:`output_dir <metawards.OutputFiles>` objects to write
  the population of the different disease states to a file
  in the output directory called ``population.dat``.

Use this extractor using the command;

.. code-block:: bash

   metawards --extractor population

If you take a look in the ``output`` directory you should see that a file
called ``population.dat.bz2`` has been created. You can take a look at
this in R, Python pandas or excel. For example, we can load this in
pandas using;

.. code-block:: python

   >>> import pandas as pd
   >>> df = pd.read_csv("output/population.dat.bz2", sep=" ", header=None)
   >>> print(df)
         0           1         2  3  4  5
      0  0  2020-04-26  56082077  0  0  0
      1  1  2020-04-27  56082077  0  0  0
      2  2  2020-04-28  56082077  0  0  0
      3  3  2020-04-29  56082077  0  0  0
      4  4  2020-04-30  56082077  0  0  0

.. note::
   ``metawards`` will auto-compress all files written into the output
   directory. If you don't want this, then use the command-line argument
   ``--no-auto-bzip``.

Notice that there are no headers to the columns. We can add a header
by passing in the headers to the
:meth:`~metawards.OutputFiles.open` function, e.g. change ``population.py``
to read;

.. code-block:: python

    from metawards.utils import Console

    def output_population(population, output_dir, **kwargs):
        Console.debug("Hello output_population")

        # create an output file called 'population.dat'
        popfile = output_dir.open("population.dat",
                                  headers=["day", "date", "S", "E",
                                           "I", "R"])

        # write the population to this file
        popfile.write(f"{population.day} {population.date.isoformat()} "
                      f"{population.susceptibles} {population.latent} "
                      f"{population.total} {population.recovereds}\n")

    def extract_population(**kwargs):
        Console.debug("hello extract_population")

        return [output_population]

Run ``metawards`` again, and now if you load the ``population.dat.bz2``
file into pandas (or R or Excel) you will see something similar to;

.. code-block:: python

  >>> import pandas as pd
  >>> df = pd.read_csv("output/population.dat.bz2", sep=" ", index_col="day")
  >>> print(df)
               date         S  E  I  R
    day
    0    2020-04-26  56082077  0  0  0
    1    2020-04-27  56082077  0  0  0
    2    2020-04-28  56082077  0  0  0
    3    2020-04-29  56082077  0  0  0
    4    2020-04-30  56082077  0  0  0

.. note::
  Note how I have used ``index_col`` to set the ``day`` as the index
  in pandas

Occasional functions
--------------------

Just as with iterators, we can choose to only call the output function
on specific days. For example, to only output the population to the
file on even days, change ``population.py`` to read;

.. code-block:: python

    from metawards.utils import Console

    def output_population(population, output_dir, **kwargs):
        Console.debug("Hello output_population")

        # create an output file called 'population.dat'
        popfile = output_dir.open("population.dat",
                                headers=["day", "date", "S", "E",
                                        "I", "R"])

        # write the population to this file
        popfile.write(f"{population.day} {population.date.isoformat()} "
                    f"{population.susceptibles} {population.latent} "
                    f"{population.total} {population.recovereds}\n")


    def extract_population(population, **kwargs):
        Console.debug("hello extract_population")

        if population.day % 2 == 0:
            return [output_population]
        else:
            return []

Run ``metawards`` using this extractor and you should see that the
``population.dat.bz2`` file contains output only for days 0, 2, and 4.

.. note::
   The line ``population.day % 2 == 0`` takes the remainder division
   of ``population.day`` with 2. Any day that is divisible by 2 will
   return 0. You can output every ``N`` days using
   ``population.day % N == 0``.

.. note::
   You are also able to only print out on other conditions, e.g.
   when the *model run* reaches a certain date, or when the
   infected population grows above a certain size.

Exiting early
-------------

Sometimes you may want to exit a *model run* early if a condition
is reached. The best way to do this is to raise a Python
`StopIteration <https://docs.python.org/3/library/exceptions.html>`__
exception. This will signal to ``metawards`` that the *model run* should
stop at the end of the current iteration (other functions that are
part of that iteration can still complete, and any output written
for that iteration will still be recorded).

For example, you could use this output function to stop the *model run*
once the number of infections reaches 2000. Copy the below into
``extract_stop.py``;

.. code-block:: python

    from metawards.extractors import extract_default

    def output_stop(population, **kwargs):
        if population.infecteds > 2000:
            raise StopIteration


    def extract_stop(**kwargs):
        output_funcs = extract_default(**kwargs)

        output_funcs.append(output_stop)

        return output_funcs

This extractor uses all of the functions of
:meth:`~metawards.extractors.extract_default`, plus a new custom
output function called ``output_stop``. This compares the number
of infections (:data:`population.infecteds <metawards.Population.infecteds>`),
and if this is more than 2000, then it raises a Python
`StopIteration <https://docs.python.org/3/library/exceptions.html>`__.

Run ``metawards`` using;

.. code-block:: bash

    metawards -d lurgy3 -a ExtraSeedsLondon.dat --extractor extract_stop

You should see that the *model run* is stopped once the number of infections
is greater than 2000, e.g.

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 29 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56078417  E: 566  I: 1275  R: 1819  IW: 501  POPULATION: 56082077
    Number of infections: 1841

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 30 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56077705  E: 650  I: 1555  R: 2167  IW: 543  POPULATION: 56082077
    <function output_stop at 0x105412e60> has indicated that the model run should stop early. Will finish the
    run at the end of this iteration
    Number of infections: 2205
    Exiting model run early due to function request
    Infection died ... Ending on day 31

You can use this to stop a *model run* for any reason you want, e.g.
a calculated condition has been reached, the model is unstable or
uses parameters that are uninteresting. Another option is to use this to
stop ``metawards`` from running for more than a specified amount of time.

To do this, create an extractor called ``extract_stop_time.py`` and
copy in;

.. code-block:: python

    from metawards.extractors import extract_default
    from metawards.utils import Console

    from datetime import datetime


    def output_stop_time(network, **kwargs):
        if not hasattr(network.params, "_start_model_time"):
            network.params._start_model_time = datetime.now()
            return

        runtime = datetime.now() - network.params._start_model_time

        Console.print(f"Runtime is {runtime.total_seconds()} seconds")

        if runtime.total_seconds() > 5:
            Console.warning(f"Runtime exceeded 5 seconds!")
            raise StopIteration


    def extract_stop_time(**kwargs):
        output_funcs = extract_default(**kwargs)

        output_funcs.append(output_stop_time)

        return output_funcs


This uses the Python
`datetime <https://docs.python.org/3/library/datetime.html>`__ module to
calculate the time since ``output_stop_time`` was first called.

.. note::

    We've recorded this start time by adding an attribute to ``network.params``
    called ``_start_model_time``. Adding attributes like this to the
    ``network.params`` object is a good way to store parameters between
    model runs, or to initialise values at the start of a model run.
    Any parameters are guaranteed to be cleared between runs, and
    the threading model means that anything you read/write is thread
    safe and will not interfere with other runs.

Run this extractor using;

.. code-block:: bash

    metawards -d lurgy3 -a ExtraSeedsLondon.dat --extractor extract_stop_time

You should see that the run ends after five seconds, e.g.;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 38 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56064800  E: 2313  I: 5934  R: 9030  IW: 1784  POPULATION: 56082077
    Runtime is 4.538544 seconds
    Number of infections: 8247

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 39 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56061567  E: 2816  I: 7023  R: 10671  IW: 2026  POPULATION: 56082077
    Runtime is 4.831688 seconds
    Number of infections: 9839

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 40 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56057698  E: 3233  I: 8359  R: 12787  IW: 2306  POPULATION: 56082077
    Runtime is 5.156103 seconds

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ WARNING ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Runtime exceeded 5 seconds!

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    <function output_stop_time at 0x10aa3ec20> has indicated that the model run should stop early. Will
    finish the run at the end of this iteration
    Number of infections: 11592
    Exiting model run early due to function request
    Infection died ... Ending on day 41
