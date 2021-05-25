================
Custom variables
================

In the last example we got ``metawards`` to model a lockdown. However,
we put a lot of hard-coded parameters into ``iterate_lockdown`` function
we wrote. One of the main purposes of ``metawards`` is to enable us
to scan through multiple variables to see their affect on the
population trajectories.

User variables
--------------

``metawards`` supports the use of any custom user variables. For example,
create a new file called ``custom.inp`` and copy in the below;

::

    # first state
    user.scale[0] = 0.2
    user.flag[0]  = False

    # second state
    user.scale[1] = 0.5
    user.flag[1]  = True

    # third state
    user.scale[2] = 0.7
    user.flag[2]  = True

.. note::
  Comments start with a '#'. The file format is very flexible. You can
  use an '=' sign or a ':' or even nothing, e.g. "user.scale[1] 0.5".
  You can abbreviate "user.variable" to ".variable" too if you want.

This file is going to be used to define three states. The first (at index 0)
has a scale factor of 0.2, and a flag set to ``False``. The second has
a scale factor of 0.5 and a flag set to ``True``. The third has a
scale factor of 0.7 and a flag set also to ``True``.

We can pass this input file into ``metawards`` using the ``--user-variables``
(or ``-u``) parameter, e.g. try typing;

.. code-block:: bash

   metawards -d lurgy3 --user-variables custom.inp

In the output you should see a line that reads;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Custom parameters and seeds ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Adjusting variables to (.scale[0]=0.2, .flag[0]=False, .scale[1]=0.5, .flag[1]=True,
    .scale[2]=0.7, .flag[2]=True)[repeat 1]

.. note::
  See how "user.variable" has been abbreviated to ".variable" in this output

This shows that ``metawards`` has read your custom parameters into the
program. They are stored as ``user_params`` in a
:class:`~metawards.Parameters` object that is stored in the
:class:`~metawards.Network` that holds the network of wards being modelled.

Reading user variables in custom iterators
------------------------------------------

You can access these parameters in an iterator or advance function using
``network.params.user_params[X]`` when ``X`` is the name of the parameter
you want. For example, ``network.params.user_params["scale[0]"] returns
``0.2``. For example, copy the below into a file called ``custom.py``;

.. code-block:: python

    from metawards.utils import Console

    def get_state(population):
        if population.day < 2:
            return 0
        elif population.day < 4:
            return 1
        else:
            return 2

    def advance_lockdown(network, population, **kwargs):
        params = network.params
        state = get_state(population)
        scale = params.user_params["scale"][state]
        Console.debug("Hello advance_lockdown", variables=[scale])

    def advance_relaxed(network, population, **kwargs):
        params = network.params
        state = get_state(population)
        scale = params.user_params["scale"][state]
        Console.debug("Hello advance_relaxed", variables=[scale])

    def iterate_custom(network, population, **kwargs):
        params = network.params
        state = get_state(population)
        flag = params.user_params["flag"][state]
        Console.debug("Hello iterate_custom", variables=[scale, flag])

        if flag:
            return [advance_lockdown]
        else:
            return [advance_relaxed]

This code defines four functions:

1. ``get_state`` - this returns the state that the population should be
   set to. In this case, the state is 0, 1 or 2 depending on the day
   of the outbreak.

2. ``iterate_custom`` - this gets the state using ``get_state``. It then
   looks up the ``flag`` custom parameter at index ``state``.
   If the flag is True, then it returns ``advance_lockdown``. Otherwise
   it returns ``advance_relaxed``.

3. ``advance_lockdown`` - this gets the state using ``get_state``. It then
   looks up the ``scale`` custom parameter at index ``state``.
   It prints this to the screen.

4. ``advance_relaxed`` - this does the same as ``advance_lockdown``, but
   prints a different message to the screen.

Use this iterator by running ``metawards`` via;

.. code-block:: bash

   metawards -d lurgy3 -u custom.inp --iterator custom --debug

You should now see printed to the screen something very similar to the below;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [15:56:50]                       Hello iterate_custom                        custom.py:31

      Name │ Value
    ═══════╪═══════
     state │ 0
      flag │ False

                                    Hello advance_relaxed                       custom.py:24

      Name │ Value
    ═══════╪═══════
     scale │ 0.2

    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    Hello iterate_custom                        custom.py:31

      Name │ Value
    ═══════╪═══════
     state │ 0
      flag │ False

                                    Hello advance_relaxed                       custom.py:24

      Name │ Value
    ═══════╪═══════
     scale │ 0.2

    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    Hello iterate_custom                        custom.py:31

      Name │ Value
    ═══════╪═══════
     state │ 1
      flag │ True

                                    Hello advance_lockdown                       custom.py:17

      Name │ Value
    ═══════╪═══════
     scale │ 0.5

    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    Hello iterate_custom                        custom.py:31

      Name │ Value
    ═══════╪═══════
     state │ 1
      flag │ True

                                    Hello advance_lockdown                       custom.py:17

      Name │ Value
    ═══════╪═══════
     scale │ 0.5

    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    Hello iterate_custom                        custom.py:31

      Name │ Value
    ═══════╪═══════
     state │ 2
      flag │ True

    [15:56:51]                      Hello advance_lockdown                       custom.py:17

      Name │ Value
    ═══════╪═══════
     scale │ 0.7

    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0
    Infection died ... Ending on day 5


Hopefully the change between state, functions called and values of the
scale factor printed makes sense and follows what you expected.

Scanning custom variables
-------------------------

You can also adjust your custom variables by scanning in the same way
that we adjusted in-built variables like **beta** and **progress**
in :doc:`an earlier part of this tutorial <../part02/02_adjustable>`.

In this case, we use the full (``user.variable``) or abbreviated
(``.variable``) names as titles in the ``metawards`` input file.

For example, create a new file called ``scan.csv`` and copy in the below;

::

    .scale[0]  .flag[0]
      0.1        False
      0.2        False
      0.3        False
      0.1         True
      0.2         True
      0.3         True

This tells ``metawards`` to perform six *model runs*, with ``user.scale[0]``
varied from 0.1-0.3, and ``user.flag[0]`` varied from "True" to "False".

Perform these model runs using;

.. code-block:: bash

   metawards -d lurgy3  -u custom.inp --iterator custom -i scan.csv

You should get output that is very similar to this;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ MULTIPROCESSING ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 1 of 6                                                                  │
    │  (.scale[0]=0.1, .flag[0]=False)[repeat 1]                                             │
    │  2020-05-25: DAY: 5 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0   TOTAL     │
    │  POPULATION 56082077                                                                   │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 2 of 6                                                                  │
    │  (.scale[0]=0.2, .flag[0]=False)[repeat 1]                                             │
    │  2020-05-25: DAY: 5 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0   TOTAL     │
    │  POPULATION 56082077                                                                   │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 3 of 6                                                                  │
    │  (.scale[0]=0.3, .flag[0]=False)[repeat 1]                                             │
    │  2020-05-25: DAY: 5 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0   TOTAL     │
    │  POPULATION 56082077                                                                   │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 4 of 6                                                                  │
    │  (.scale[0]=0.1, .flag[0]=True)[repeat 1]                                              │
    │  2020-05-25: DAY: 5 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0   TOTAL     │
    │  POPULATION 56082077                                                                   │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 5 of 6                                                                  │
    │  (.scale[0]=0.2, .flag[0]=True)[repeat 1]                                              │
    │  2020-05-25: DAY: 5 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0   TOTAL     │
    │  POPULATION 56082077                                                                   │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 6 of 6                                                                  │
    │  (.scale[0]=0.3, .flag[0]=True)[repeat 1]                                              │
    │  2020-05-25: DAY: 5 S: 56082077    E: 0    I: 0    R: 0    IW: 0   UV: 1.0   TOTAL     │
    │  POPULATION 56082077                                                                   │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Writing a summary of all results into the csv file                                    │
    │  /Users/chris/GitHub/tutorial/weekend/output/results.csv.bz2. You can use this to      │
    │  quickly look at statistics across all runs using e.g. R or pandas                     │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘

A quick look in the ``output/results.csv.bz2`` file, e.g. using pandas,
shows that the fingerprint and columns for custom variables are
constructed identially to in-built variables, e.g.

.. code-block:: python

    >>> import pandas as pd
    >>> df = pd.read_csv("output/results.csv.bz2")
    >>> print(df)
        ingerprint  repeat  .scale[0]  .flag[0]  day        date         S  E  I  R  IW   UV
    0        0i1vF       1        0.1     False    0  2020-05-20  56082077  0  0  0   0  1.0
    1        0i1vF       1        0.1     False    1  2020-05-21  56082077  0  0  0   0  1.0
    2        0i1vF       1        0.1     False    2  2020-05-22  56082077  0  0  0   0  1.0
    3        0i1vF       1        0.1     False    3  2020-05-23  56082077  0  0  0   0  1.0
    4        0i1vF       1        0.1     False    4  2020-05-24  56082077  0  0  0   0  1.0
    5        0i1vF       1        0.1     False    5  2020-05-25  56082077  0  0  0   0  1.0
    6        0i2vF       1        0.2     False    0  2020-05-20  56082077  0  0  0   0  1.0
    7        0i2vF       1        0.2     False    1  2020-05-21  56082077  0  0  0   0  1.0
    8        0i2vF       1        0.2     False    2  2020-05-22  56082077  0  0  0   0  1.0
    9        0i2vF       1        0.2     False    3  2020-05-23  56082077  0  0  0   0  1.0
    10       0i2vF       1        0.2     False    4  2020-05-24  56082077  0  0  0   0  1.0
    11       0i2vF       1        0.2     False    5  2020-05-25  56082077  0  0  0   0  1.0
    12       0i3vF       1        0.3     False    0  2020-05-20  56082077  0  0  0   0  1.0
    13       0i3vF       1        0.3     False    1  2020-05-21  56082077  0  0  0   0  1.0
    14       0i3vF       1        0.3     False    2  2020-05-22  56082077  0  0  0   0  1.0
    15       0i3vF       1        0.3     False    3  2020-05-23  56082077  0  0  0   0  1.0
    16       0i3vF       1        0.3     False    4  2020-05-24  56082077  0  0  0   0  1.0
    17       0i3vF       1        0.3     False    5  2020-05-25  56082077  0  0  0   0  1.0
    18       0i1vT       1        0.1      True    0  2020-05-20  56082077  0  0  0   0  1.0
    19       0i1vT       1        0.1      True    1  2020-05-21  56082077  0  0  0   0  1.0
    20       0i1vT       1        0.1      True    2  2020-05-22  56082077  0  0  0   0  1.0
    21       0i1vT       1        0.1      True    3  2020-05-23  56082077  0  0  0   0  1.0
    22       0i1vT       1        0.1      True    4  2020-05-24  56082077  0  0  0   0  1.0
    23       0i1vT       1        0.1      True    5  2020-05-25  56082077  0  0  0   0  1.0
    24       0i2vT       1        0.2      True    0  2020-05-20  56082077  0  0  0   0  1.0
    25       0i2vT       1        0.2      True    1  2020-05-21  56082077  0  0  0   0  1.0
    26       0i2vT       1        0.2      True    2  2020-05-22  56082077  0  0  0   0  1.0
    27       0i2vT       1        0.2      True    3  2020-05-23  56082077  0  0  0   0  1.0
    28       0i2vT       1        0.2      True    4  2020-05-24  56082077  0  0  0   0  1.0
    29       0i2vT       1        0.2      True    5  2020-05-25  56082077  0  0  0   0  1.0
    30       0i3vT       1        0.3      True    0  2020-05-20  56082077  0  0  0   0  1.0
    31       0i3vT       1        0.3      True    1  2020-05-21  56082077  0  0  0   0  1.0
    32       0i3vT       1        0.3      True    2  2020-05-22  56082077  0  0  0   0  1.0
    33       0i3vT       1        0.3      True    3  2020-05-23  56082077  0  0  0   0  1.0
    34       0i3vT       1        0.3      True    4  2020-05-24  56082077  0  0  0   0  1.0
    35       0i3vT       1        0.3      True    5  2020-05-25  56082077  0  0  0   0  1.0