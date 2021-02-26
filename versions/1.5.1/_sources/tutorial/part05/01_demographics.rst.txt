==============================
Multi-demographic sub-networks
==============================

So far every member of the population during a ``metawards`` *model run* has
been treated equally. There was no concept of different groups of individuals,
e.g. school children, hospital patients, holiday-makers etc. being
modelled any differently. The only distinction was between *workers*,
who made fixed movements (potentially between wards)
during the day, and random interactions within their home ward in
the evening, and *players*, who just made random interactions within
their home ward.

Understanding Network
---------------------

The :class:`~metawards.Network` class models this network of *workers* and
*players*. It holds a set of :class:`~metawards.Nodes` that represent each
electoral ward, and a set of :class:`~metawards.Links` that represent the
fixed motions between wards made by the "workers".

The :class:`~metawards.Node` class holds the number of *players* who
are susceptible to infection (S). This is held in the variable
:data:`metawards.Node.play_suscept`.

The :class:`~metawards.Link` class contains the number of *workers* who are
susceptible to infection (S) who travel regularly between their
"home" ward and their "work" ward. This is held in the
variable :data:`metawards.Link.suscept`.

During a *model run* these values will be reduced as individuals are
infected and then progressed through the different disease stages.

.. note::

  These variables are stored as double precision floating point numbers,
  despite representing integer values. This is because it
  is more efficient to use double precision numbers when they are used
  for calculations during a *model run*.

Understanding Networks
----------------------

To model multiple demographics, we need to create space for multiple different
sets of *workers* and *players*. This is achieved in ``metawards`` by
giving each demographic its own :class:`~metawards.Network`. All of these
demographic sub-networks are merged and managed via the
:class:`~metawards.Networks` class.

We create a :class:`~metawards.Networks` object by first specifying the way
we would like to distribute the population between different demographics.
We do this by writing a *demographics* file, which is a simple
`JSON-format <https://guide.couchdb.org/draft/json.html>`__
file. First, create a file called ``demographics.json`` and copy in the below;

::

    {
      "demographics" : ["red", "blue"],
      "work_ratios"  : [ 0.0,   1.0  ],
      "play_ratios"  : [ 0.5,   0.5  ]
    }

This file specifies that the population will be distributed between
two demographics, *red* and *blue*, named in the ``demographics``
field. You can have as many or as few demographics as you wish, and
can name them in any way you want.

The ``work_ratios`` lists the ratio (or percentage) of the *worker* population
that should belong to each demographic. For example, here all of the
*workers* are in the *blue* demographic, and none of the workers are
in the *red* demographic.

The ``play_ratios`` lists the ratio (or percentage) of the *player* population
that should belong to each demographic. For example, here 50% of the
*players* are in the *red* demographic, and 50% of the *players* are in the
*blue* demographic.

.. note::
  You can specify the work and play ratios using either numbers between
  0.0 and 1.0, or you can pass in strings that are interpreted using
  :func:`metawards.Interpret.number`, e.g. "50%", "1/4" or
  "(10+15)%". The only requirement is that the sum of ratios must
  equal 1.0 (or 100%), as every individual must be assigned to one
  of the demographics.

Now that you have created the ``demographics.json`` file, you can tell
``metawards`` to use it via the ``--demographics``, or ``-D``,
command line argument. Run ``metawards`` using;

.. code-block:: bash

   metawards -d lurgy3 -D demographics.json

In the output you should see lines such as;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Specialising into demographics ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Demographics demographics.json
    loaded from demographics.json
    version: None
    author(s): unknown
    contact(s): unknown
    references(s): none
    repository: None
    repository_branch: None
    repository_version: None
    demographics = [
        Demographic(name='red', work_ratio=0.0, play_ratio=0.5, adjustment=None)
        Demographic(name='blue', work_ratio=1.0, play_ratio=0.5, adjustment=None)
    ]
    Seeding generator used for demographics with seed 4751828
    Using random number seed: 4751828
    Number of differences is 0.0 + 0.0
    Specialising network - population: 56082077
    red - population: 16806530
    blue - population: 39275547

These show that your demographics file was read correctly. In this case,
this has specialised the :class:`~metawards.Network` which modelled a
population of 56082077 individuals into a :class:`~metawards.Networks`
which has a *red* population of 16806530 and a *blue* population of
39275547.

.. warning::
  A fixed random number seed is used to assign left-over individuals
  to a random demographic. For example, 10 individuals cannot be divided
  equally between 3 demographics, so one randomly chosen demographic
  will have 4 individuals, while the other two will have 3. This
  division is performed by ``metawards`` in every single
  :class:`~metawards.Node` and every single :class:`~metawards.Link`,
  to ensure that every individual is allocated. This random seed is
  hard-coded to ``4751828``. Or, you can set it for a demographic
  by adding ``"random_seed" = number`` to the *demographics* file,
  e.g. ``"random_seed" = 10859403``.

Once the :class:`~metawards.Networks` had been specialised, the *model run*
was performed as before. Now, the output shows the S, E, I, R values
for both the overall total population, and also for the demographic
sub-network populations, e.g.

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R: 0  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R: 0  IW: 0  POPULATION: 39275547
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R: 0  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R: 0  IW: 0  POPULATION: 39275547
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R: 0  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R: 0  IW: 0  POPULATION: 39275547
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R: 0  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R: 0  IW: 0  POPULATION: 39275547
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R: 0  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R: 0  IW: 0  POPULATION: 39275547
    Number of infections: 0
    Infection died ... Ending on day 5

In this case no infection was seeded, so nothing appears to happen.

We can seed an infection just as before, by using the ``--additional``
(or ``-a``) option, e.g. now run;

.. code-block:: bash

   metawards -d lurgy3 -D demographics.json -a ExtraSeedsLondon.dat

You should see output similar (but not identical) to;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 249 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079607  E: 0  I: 2  R: 2468  IW: 0  POPULATION: 56082077
       red  S: 16804060  E: 0  I: 2  R: 2468  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R:    0  IW: 0  POPULATION: 39275547
    Number of infections: 2

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 250 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079607  E: 0  I: 2  R: 2468  IW: 0  POPULATION: 56082077
       red  S: 16804060  E: 0  I: 2  R: 2468  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R:    0  IW: 0  POPULATION: 39275547
    Number of infections: 2

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 251 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079607  E: 0  I: 1  R: 2469  IW: 0  POPULATION: 56082077
       red  S: 16804060  E: 0  I: 1  R: 2469  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R:    0  IW: 0  POPULATION: 39275547
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 252 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079607  E: 0  I: 1  R: 2469  IW: 0  POPULATION: 56082077
       red  S: 16804060  E: 0  I: 1  R: 2469  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R:    0  IW: 0  POPULATION: 39275547
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 253 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079607  E: 0  I: 0  R: 2470  IW: 0  POPULATION: 56082077
       red  S: 16804060  E: 0  I: 0  R: 2470  IW: 0  POPULATION: 16806530
      blue  S: 39275547  E: 0  I: 0  R:    0  IW: 0  POPULATION: 39275547
    Number of infections: 0
    Infection died ... Ending on day 254

By default, infections are seeded into the first demographic (in this case
*red*). This demographic are *players*, so only interact in their home
ward via random interactions. As such, the infection did not spread
beyond that home ward and so it died out quite quickly.

Seeding different demographics
------------------------------

You can seed different demographics by specifying the demographic in
the additional seeding file. Create a new seeding file called
``ExtraSeedsLondonBlue.dat`` and copy in the below;

::

  1  5  255  blue

The format of this file is a list of lines that say which wards should
be seeded. In this case, there is just one line containing four values.

* The first value (``1``) is the day of seeding, in this case on day 1.
* The second value  (``5``) is the number of individuals to infect, in
  this case 5.
* The third value (``255``) is the index of the ward to infect. You can find
  the index of the ward you want using the :class:`~metawards.WardInfos`
  object, e.g. via ``network.info.find("...")``.
* The fourth value (``blue``) is the name or index of the demographic
  you want to seed.

.. note::

  If you want, you could have specified the demographic in this file by
  its index (``1``) rather than by its name (``blue``). It is up to you.

The *blue* demographic contains all of the *workers*, so we would expect
to see a different outbreak. Perform a *model run* using;

.. code-block:: bash

  metawards -d lurgy3 -D demographics.json -a ExtraSeedsLondonBlue.dat

You should see a more sustained outbreak, ending in a similar way to this;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 147 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 16864032  E: 0  I: 1  R: 39218044  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R:        0  IW: 0  POPULATION: 16806530
      blue  S:    57502  E: 0  I: 1  R: 39218044  IW: 0  POPULATION: 39275547
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 148 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 16864032  E: 0  I: 1  R: 39218044  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R:        0  IW: 0  POPULATION: 16806530
      blue  S:    57502  E: 0  I: 1  R: 39218044  IW: 0  POPULATION: 39275547
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 149 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 16864032  E: 0  I: 0  R: 39218045  IW: 0  POPULATION: 56082077
       red  S: 16806530  E: 0  I: 0  R:        0  IW: 0  POPULATION: 16806530
      blue  S:    57502  E: 0  I: 0  R: 39218045  IW: 0  POPULATION: 39275547
    Number of infections: 0
    Infection died ... Ending on day 150

Because the *blue workers* could move between wards, they were able to carry
the infection across the country, meaning that most members of the *blue*
demographic were infected.
