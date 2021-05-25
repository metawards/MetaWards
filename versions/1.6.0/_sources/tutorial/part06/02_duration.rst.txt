=======================
Self-isolation duration
=======================

In the last section we saw how self-isolation and a population that
took steps to reduce transmissability of the virus could dramatically
reduce the spread of the disease. However, in that model infected
individuals were moved into self-isolation for the entire duration
of the outbreak. This is clearly unrealistic.

Using demographics to represent days
------------------------------------

Typical advice to someone who is self-isolating is that they should
self-isolate for a set number of days. We can model this by using
different self-isolation demographics to represent the different
days that individuals start their self-isolation. For example,
if self-isolation was for seven days, then we could have a
self-isolation demographic for each day of the week. Once a week
is up, then the individuals who are self-isolating in that
day-demographic are released and moved to the "released" demographic.
Newly infected individuals for that day are then moved into
the now-empty day-demographic.

To do this, create a new demographics file called ``demographics.json``
and copy in the below;

::

    {
      "demographics" : ["home", "released",
                        "isolate_0", "isolate_1", "isolate_2",
                        "isolate_3", "isolate_4", "isolate_5",
                        "isolate_6" ],
      "work_ratios"  : [ 1.0, 0.0,
                         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
      "play_ratios"  : [ 1.0, 0.0,
                         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
    }

This creates the ``home`` demographic, plus one ``isolate`` demographic
for each day of the week. There is also a ``released`` demographic
that will be used to release individuals from self-isolation.

Moving daily
------------

We start with all individuals placed into the ``home`` demographic. We will
now write a custom move function that will move individuals into the
assigned ``isolate_N`` demographic for the day in which they develop
symptoms. This move function will move them into the ``released`` demographic
once they have spent seven days in self-isolation. To do this,
create a move function called ``move_isolate.py`` and copy in the below;

.. code-block:: python

    from metawards import Population
    from metawards.movers import go_isolate, go_to

    def move_isolate(population: Population, **kwargs):
        day = population.day % 7
        isolate = f"isolate_{day}"

        go_isolate_day = lambda **kwargs: go_isolate(
                                            go_from="home",
                                            go_to=isolate,
                                            self_isolate_stage=3,
                                            **kwargs)

        go_released = lambda **kwargs: go_to(go_from=isolate,
                                             go_to="released",
                                             **kwargs)

        return [go_released, go_isolate_day]

This function works out which ``isolate_N`` demographic to use based
on the day of the week (``population.day % 7`` returns a number from ``0``
to ``6``).

It then creates two ``go functions``. The first, ``go_isolate_day``
is a :meth:`~metawards.movers.go_isolate` that moves infected
individuals from ``home`` into the ``isolate_N`` demographic of that day.

The second, ``go_released`` calls :meth:`~metawards.movers.go_to` to
send all individuals who are in that ``isolate_N`` demographic
to the ``released`` demographic.

The ``move_isolate`` function returns ``go_released`` first, so that
everyone who ends their self-isolation leaves before ``go_isolate_day``
then sends in the new cohort of infected individuals.

Mixing home and released
------------------------

Next, create a ``mixing function`` that merges the FOIs of the ``home``
and ``released`` demographics evenly, while making sure that everyone
in the ``isolate_N`` demographics is isolated and does not contribute
to any FOI.

Do this by creating a mixing function called ``mix_isolate.py`` and
copying in the below;

.. code-block:: python

    from metawards import Networks
    from metawards.mixers import merge_using_matrix, InteractionMatrix

    def mix_isolate(network: Networks, **kwargs):
        matrix = InteractionMatrix.ones(n=2)
        matrix.resize(2 + 7, value=0.0)

        network.demographics.interaction_matrix = matrix

        return [merge_using_matrix]

.. note::

   Note that we are using :func:`~metawards.mixers.merge_using_matrix`.
   This may not be the right choice depending on how we want the
   population dynamics to mix, e.g.
   :func:`~metawards.mixers.merge_matrix_single_population` or
   :func:`~metawards.mixers.merge_matrix_multi_population` may
   be a better choice. :doc:`See here for more information <../part05/04_contacts>`.

Here we use :class:`metawards.mixers.InteractionMatrix` to simplify the
creation of the interation matrix. We first create a 2x2 matrix;

::

  [ [1, 1],
    [1, 1] ]

using :meth:`InteractionMatrix.ones(n=2) <metawards.mixers.InteractionMatrix.ones>`.
We then resize this to be a 9x9 matrix using
:meth:`InteractionMatrix.resize(2 + 7, value=0.0) <metawards.mixers.InteractionMatrix.resize>`,
where the new values are equal to
zero. You can double-check that this matrix is correct using, e.g.
ipython or a jupyter notebook;

.. code-block:: python

    >>> from metawards.mixers import InteractionMatrix
    >>> matrix = InteractionMatrix.ones(n=2)
    >>> print(matrix)
    | 1.000, 1.000 |
    | 1.000, 1.000 |
    >>> matrix.resize(2 + 7, value=0.0)
    >>> print(matrix)
    | 1.000, 1.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 1.000, 1.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |
    | 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000 |

.. note::
   You could have created this matrix manually, but that is error-prone.
   The :class:`~metawards.mixers.InteractionMatrix` class has lots
   of helper functions that are useful for setting interactions between
   different demographics.

With this mixer created, you can now run ``metawards`` using;

.. code-block:: bash

   metawards -d lurgy4 -D demographics.json -a ExtraSeedsLondon.dat --mixer mix_isolate --mover move_isolate --extractor extract_none --nsteps 365

.. note::
   We've limited the number of days to model to 365 (one year), as
   self-isolation significantly slows down the spread of the disease,
   and modelling more than a year is unhelpful. We've also here used
   the :func:`~metawards.extractors.extract_none` extractor to limit
   the amount of output. Outputting data can be a little slow when
   there are a large number of demographics.

What do you see? In some cases self-isolation will cause the outbreak to
quickly die out. However, for most runs, we see that the infectious
asymptomatic allows new infections to be seeded before the individual
develops symptoms and moves into self-isolation.

Of more interest, we also see that as the outbreak grows, about 1% of
infected individuals have not recovered after 7 days. They leave
self-isolation and are able to contribute to the *force of infection*
in the ``home`` demographic.

::

    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 11 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082064  E: 0  I: 6  R: 7  IW: 2  POPULATION: 56082077
           home  S: 56082064  E: 0  I: 6  R: 2  IW: 2  POPULATION: 56082072
       released  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
      isolate_0  S:        0  E: 0  I: 0  R: 1  IW: 0  POPULATION:        1
      isolate_1  S:        0  E: 0  I: 0  R: 1  IW: 0  POPULATION:        1
      isolate_2  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
      isolate_3  S:        0  E: 0  I: 0  R: 1  IW: 0  POPULATION:        1
      isolate_4  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
      isolate_5  S:        0  E: 0  I: 0  R: 2  IW: 0  POPULATION:        2
      isolate_6  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
    Number of infections: 6
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 39 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56081874  E: 19  I: 95  R: 89  IW: 13  POPULATION: 56082077
           home  S: 56081874  E: 19  I: 71  R: 13  IW: 13  POPULATION: 56081977
       released  S:        0  E:  0  I:  0  R: 48  IW:  0  POPULATION:       48
      isolate_0  S:        0  E:  0  I:  2  R:  5  IW:  0  POPULATION:        7
      isolate_1  S:        0  E:  0  I:  0  R:  8  IW:  0  POPULATION:        8
      isolate_2  S:        0  E:  0  I:  3  R:  4  IW:  0  POPULATION:        7
      isolate_3  S:        0  E:  0  I:  5  R:  2  IW:  0  POPULATION:        7
      isolate_4  S:        0  E:  0  I: 13  R:  0  IW:  0  POPULATION:       13
      isolate_5  S:        0  E:  0  I:  0  R:  3  IW:  0  POPULATION:        3
      isolate_6  S:        0  E:  0  I:  1  R:  6  IW:  0  POPULATION:        7
    Number of infections: 114
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 139 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56064409  E: 566  I: 4253  R: 12849  IW: 524  POPULATION: 56082077
           home  S: 56064409  E: 566  I: 2938  R:   585  IW: 524  POPULATION: 56068498
       released  S:        0  E:   0  I:   28  R: 10553  IW:   0  POPULATION:    10581
      isolate_0  S:        0  E:   0  I:   23  R:   374  IW:   0  POPULATION:      397
      isolate_1  S:        0  E:   0  I:   42  R:   377  IW:   0  POPULATION:      419
      isolate_2  S:        0  E:   0  I:   85  R:   341  IW:   0  POPULATION:      426
      isolate_3  S:        0  E:   0  I:  121  R:   272  IW:   0  POPULATION:      393
      isolate_4  S:        0  E:   0  I:  218  R:   232  IW:   0  POPULATION:      450
      isolate_5  S:        0  E:   0  I:  364  R:   115  IW:   0  POPULATION:      479
      isolate_6  S:        0  E:   0  I:  434  R:     0  IW:   0  POPULATION:      434
    Number of infections: 4819
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 364 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 54653198  E: 14724  I: 126080  R: 1288075  IW: 6273  POPULATION: 56082077
           home  S: 54653198  E: 14724  I: 84809  R:   14613  IW: 6273  POPULATION: 54767344
       released  S:        0  E:     0  I:  1014  R: 1218000  IW:    0  POPULATION:  1219014
      isolate_0  S:        0  E:     0  I: 14010  R:       0  IW:    0  POPULATION:    14010
      isolate_1  S:        0  E:     0  I:   834  R:   12575  IW:    0  POPULATION:    13409
      isolate_2  S:        0  E:     0  I:  1490  R:   11998  IW:    0  POPULATION:    13488
      isolate_3  S:        0  E:     0  I:  2482  R:   11212  IW:    0  POPULATION:    13694
      isolate_4  S:        0  E:     0  I:  4150  R:    9327  IW:    0  POPULATION:    13477
      isolate_5  S:        0  E:     0  I:  6926  R:    6897  IW:    0  POPULATION:    13823
      isolate_6  S:        0  E:     0  I: 10365  R:    3453  IW:    0  POPULATION:    13818
    Number of infections: 140804

As you can see above, by day 364, there were 1014 infected individuals in
the ``released`` demographic, indicating that they have left self-isolation
too early.
