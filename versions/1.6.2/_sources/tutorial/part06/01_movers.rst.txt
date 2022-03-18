=======================
Movers and go functions
=======================

Demographics in ``metawards`` are a powerful concept that enables the
modelling of a wide variety of different scenarios. Just as *work*
and *play* have very general meanings in ``metawards``, so to do
*demographics*. We use it to mean any group of individuals. It is fluid,
in the sense that an individual can move between different demographics
during a *model run*, with the constraint that they can only belong
to one demographic at a time.

Demographic for self-isolation
------------------------------

Individuals are moved between demographics during a model run using
:doc:`mover functions <../../api/index_MetaWards_movers>`. These are
plugins that return the ``go functions`` that are used to make individuals
go from one demographic to another.

This is best demonstrated by example. In this example we will use
demographics to model the effect of self-isolation or
quarantine during an outbreak.

First, create a new ``demographics.json`` file that contains;

::

    {
        "demographics" : ["home", "isolate"],
        "work_ratios"  : [ 1.0,      0.0   ],
        "play_ratios"  : [ 1.0,      0.0   ]
    }

This specifies two demographics:

1. ``home`` - this holds the entire population and represents individuals
   behaving "normally", e.g. continuing to *work* and *play*.
2. ``isolate`` - this currently has no members. We will use this demographic
   to represent individuals who are self-isolating or in quarantine, e.g.
   they will not contribute to the force of infection of any ward.

Moving individuals to isolation
-------------------------------

Next, create a custom :doc:`move function <../../api/index_MetaWards_movers>`
called ``move_isolate`` by creating a file called ``move_isolate.py``
and copying in the below;

.. code-block:: python

    from metawards.movers import go_isolate

    def move_isolate(**kwargs):
        func = lambda **kwargs: go_isolate(go_from="home",
                                           go_to="isolate",
                                           self_isolate_stage=2,
                                            **kwargs)

        return [func]

This defines a custom :doc:`move function <../../api/index_MetaWards_movers>`
called ``move_isolate``. This returns the
``go function`` :meth:`~metawards.movers.go_isolate` that is
provided in :mod:`metawards.movers`. This
:meth:`~metawards.movers.go_isolate` function scans through the
demographics idenfied by ``go_from`` to search for individuals who
are showing signs of infection, i.e. individuals in a disease stage
that is greater or equal to ``self_isolate_stage``.

:meth:`~metawards.movers.go_isolate` moves these infected individuals
from their existing demographic into the new demographic identified
by ``go_to``.

This go function has several parameters that must be set before it
can be returned by ``move_isolate``. We set these parameters by using
`lambda <https://chryswoods.com/parallel_python/lambda.html>`__ to create
a new anonymous go function where those arguments are bound to fixed
values.

.. note::
   Here is a `good explanation of lambda and argument binding <https://chryswoods.com/parallel_python/lambda.html>`__
   if you've never seen this before. In this case we have bound
   ``go_from`` to equal ``"home"``, ``go_to`` to equal ``"isolate"``,
   and ``self_isolate_stage`` to equal ``2`` . This means that these values
   will be used every time the ``go_isolate`` function returned
   from ``move_isolate`` is called.

Mixing without infection
------------------------

Next, create a :doc:`mixer <../../api/index_MetaWards_mixers>` in
``mix_isolate.py`` and copy in the below;

.. code-block:: python

    from metawards.mixers import merge_using_matrix

    def mix_isolate(network, **kwargs):

        matrix = [ [1.0, 0.0],
                   [0.0, 0.0] ]

        network.demographics.interaction_matrix = matrix

        return [merge_using_matrix]

This mixer specifies an interaction matrix where the only contribution
to the FOIs comes from the ``home`` demographic (``matrix[0][0] == 1``).
The ``isolate`` demographic makes no contribution to the FOI
(``matrix[0][1]``, ``matrix[1][0]`` and ``matrix[1][1]`` are all zero).

Running the model
-----------------

You can run the simulation by passing in your custom mover using the
``--mover`` command line argument, and your custom mixer using the
``--mixer`` command line argument. We will seed the infection using
``ExtraSeedsBrighton.dat`` and will use the parameters from ``lurgy3.json``
which you should copy into this directory. Run the job using;

.. code-block:: bash

   metawards -d lurgy3 -D demographics.json -a ExtraSeedsBrighton.dat --mover move_isolate --mixer mix_isolate

.. note::
   Note that we are using the ``lurgy3`` parameters that were
   :doc:`optimised earlier <../part02/05_refining>`. These include the
   long-lived asymptomatic but infectious stage 3 of the disease.

You should see a trajectory that looks something like this;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
          home  S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
       isolate  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    seeding demographic 0 play_infections[0][2124] += 5
    S: 56082072  E: 5  I: 0  R: 0  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 5  I: 0  R: 0  IW: 0  POPULATION: 56082077
       isolate  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082072  E: 0  I: 5  R: 0  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 0  I: 5  R: 0  IW: 0  POPULATION: 56082077
       isolate  S:        0  E: 0  I: 0  R: 0  IW: 0  POPULATION:        0
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082072  E: 0  I: 5  R: 0  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082072
       isolate  S:        0  E: 0  I: 5  R: 0  IW: 0  POPULATION:        5
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082072  E: 0  I: 5  R: 0  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082072
       isolate  S:        0  E: 0  I: 5  R: 0  IW: 0  POPULATION:        5
    Number of infections: 5
    ...
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 20 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082072  E: 0  I: 1  R: 4  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082072
       isolate  S:        0  E: 0  I: 1  R: 4  IW: 0  POPULATION:        5
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 21 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082072  E: 0  I: 1  R: 4  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082072
       isolate  S:        0  E: 0  I: 1  R: 4  IW: 0  POPULATION:        5
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 22 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082072  E: 0  I: 0  R: 5  IW: 0  POPULATION: 56082077
          home  S: 56082072  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082072
       isolate  S:        0  E: 0  I: 0  R: 5  IW: 0  POPULATION:        5
    Number of infections: 0
    Infection died ... Ending on day 22

The infection was seeded with five individuals on day 1. They had a
latent infection for a day (``E == 5``), before developing symptoms
on day 2 (``I == 5``). At the beginning of day 3 then were moved
into the ``isolate`` demographic, in which they were unable to
infect others, and so progressed through the disease until they had
all recovered by day 22.

The asymptomatic stage
----------------------

Self-isolation appeared to have worked well. However, we neglected
to account for the asymptomatic ``stage 3`` of the lurgy. We modelled
the disease such that symptoms only appeared in stage 3, but individuals
were infectious from stage 2. We need to update our ``move_isolate`` function
so that individuals only self-isolate at stage 3, when they realise
that they have symptoms. Edit ``move_isolate.py`` and change it to read;

.. code-block:: python

    from metawards.movers import go_isolate

    def move_isolate(**kwargs):
        func = lambda **kwargs: go_isolate(go_from="home",
                                           go_to="isolate",
                                           self_isolate_stage=3,
                                            **kwargs)

        return [func]

(we have just changed ``self_isolate_stage`` from ``2`` to ``3``).

Now run ``metawards`` again using;

.. code-block:: bash

   metawards -d lurgy3 -D demographics.json -a ExtraSeedsBrighton.dat --mover move_isolate --mixer mix_isolate

We now have a completely different outbreak. Asymptomatic (and thus not
self-isolating) individuals were able to spread the infection to others
before going into isolation. This spread was exponential, and so
the epidemic lasted for a long time, with the vast majority of Individuals
in the model being infected. For example;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 370 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 11394138  E: 0  I: 1  R: 44687938  IW: 0  POPULATION: 56082077
          home  S: 11394138  E: 0  I: 0  R:        0  IW: 0  POPULATION: 11394138
       isolate  S:        0  E: 0  I: 1  R: 44687938  IW: 0  POPULATION: 44687939
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 371 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 11394138  E: 0  I: 1  R: 44687938  IW: 0  POPULATION: 56082077
          home  S: 11394138  E: 0  I: 0  R:        0  IW: 0  POPULATION: 11394138
       isolate  S:        0  E: 0  I: 1  R: 44687938  IW: 0  POPULATION: 44687939
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 372 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 11394138  E: 0  I: 0  R: 44687939  IW: 0  POPULATION: 56082077
          home  S: 11394138  E: 0  I: 0  R:        0  IW: 0  POPULATION: 11394138
       isolate  S:        0  E: 0  I: 0  R: 44687939  IW: 0  POPULATION: 44687939
    Number of infections: 0
    Infection died ... Ending on day 373

Here, the outbreak lasted for 372 days, with ~45M infections.

Adjusting progress
------------------

The issue here is that the amount of time spent in the asymptomatic but
infectious stage was very long (``progress[3] == 0.2``) and the
infectiousness of asymptomatic individuals was very high
(``beta[3] == 0.4``). During a real outbreak it is likely that individuals
would take actions that would reduce the chance of infection even from
asymptomatic carriers, e.g. by generally being more wary of one another,
washing hands, wearing masks etc. To account for this, we should reduce
the value of ``beta[3]`` to a lower value, e.g. to ``0.2``. Copy
``lurgy3.json`` to ``lurgy4.json`` and update that to read;

::

    { "name"             : "The Lurgy",
      "version"          : "May 18th 2020",
      "author(s)"        : "Christopher Woods",
      "contact(s)"       : "christopher.woods@bristol.ac.uk",
      "reference(s)"     : "Completely ficticious disease - no references",
      "beta"             : [0.0, 0.0, 0.2, 0.5, 0.5, 0.0],
      "progress"         : [1.0, 1.0, 0.2, 0.5, 0.5, 0.0],
      "too_ill_to_move"  : [0.0, 0.0, 0.0, 0.5, 0.8, 1.0],
      "contrib_foi"      : [1.0, 1.0, 1.0, 1.0, 1.0, 0.0]
    }

(we have just changed ``beta[3]`` from ``0.4`` to ``0.2``)

.. note::

    In a real outbreak you should scan the value of ``beta[3]`` to match
    against observations. We are not doing this now as the lurgy is a
    fictional disease.

Now run the model using the command;

.. code-block:: bash

    metawards -d lurgy4 -D demographics.json -a ExtraSeedsBrighton.dat --mover move_isolate --mixer mix_isolate --nsteps 365

.. note::
   We've switched to using ``lurgy4`` and have limited the run to modelling
   just a single year (365 days)

You should see output similar to;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 362 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 55673047  E: 4015  I: 35748  R: 369267  IW: 3073  POPULATION: 56082077
          home  S: 55673047  E: 4015  I: 23938  R:   4094  IW: 3073  POPULATION: 55705094
       isolate  S:        0  E:    0  I: 11810  R: 365173  IW:    0  POPULATION:   376983
    Number of infections: 39763

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 363 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 55668968  E: 4094  I: 35800  R: 373215  IW: 2990  POPULATION: 56082077
          home  S: 55668968  E: 4094  I: 23987  R:   4079  IW: 2990  POPULATION: 55701128
       isolate  S:        0  E:    0  I: 11813  R: 369136  IW:    0  POPULATION:   380949
    Number of infections: 39894

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 364 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 55664887  E: 4079  I: 35966  R: 377145  IW: 3028  POPULATION: 56082077
          home  S: 55664887  E: 4079  I: 24148  R:   4081  IW: 3028  POPULATION: 55697195
       isolate  S:        0  E:    0  I: 11818  R: 373064  IW:    0  POPULATION:   384882
    Number of infections: 40045
    Exiting model run early
    Infection died ... Ending on day 365

.. note::

  You may find that the outbreak dies out quite quickly. The number of
  infections is low at the start, and the action of low ``beta`` and
  the move to self-isolating does quench the outbreak during some runs.
  However, once it catches light, the outbreak will spread to approximately
  40,000 individuals within one year.

The spread of the infection was significantly reduced by the reduction
in ``beta[3]`` for the asymptomatic stage. This demonstrates how small changes
in ``beta``, e.g. caused by increased hand-washing, masks etc., can have
a big impact on the spread of the disease in the model.
