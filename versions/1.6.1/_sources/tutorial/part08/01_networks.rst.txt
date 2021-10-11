===============================
Understanding the Model Network
===============================

At its core, ``metawards`` implements a meta-population model. Individuals
are grouped into workers and players, and distributed across wards. The
force of infection of a ward caused by infection of an individual, based on
their movements and behaviour is calculated, and used to decide whether
other individuals who reside or visit that ward should be infected.

The :class:`~metawards.Network` is the collection of
:class:`~metawards.Nodes` and :class:`~metawards.Links` that describe
the individual wards, and the movements between wards of their
residents.

Up to now, you have used a single underlying :class:`~metawards.Network`
for every demographic and model run in this tutorial. This does not need
to be the case, and you can choose to assign different
:class:`~metawards.Network` objects to different demographics in
a simulation. You would do this, for example, to model different connections
or movements between wards for different demographics, e.g. workers
or school students. Or to use different networks to represent movements
related to holidays or foreign travel.

The single-node network
-----------------------

You can set the overall network used by default by all demographics via
the ``--model`` or ``-m`` command-line argument. The default value
is ``2011Data``, which is based on 2011 census data, and models every
electoral ward in England and Wales.

There are two other models supplied;

* ``2011UK`` : Again, this is based on the 2011 census, but includes Scotland
  and Northern Ireland. This model is still a work in progress.
* ``single`` : This is a single-ward network that is used for testing, or
  when you don't want to model geographic behaviour.

You can run a single-ward simulation using the command line;

.. code-block:: bash

   metawards -d lurgy_home -m single -P 100

.. note::

   We are using the ``lurgy_home.json`` file from the last chapter of this
   tutorial. Note that we also need to set the population of this single
   ward using the ``-P`` or ``--population`` command line argument. In this
   case, we are setting the population to 100 individuals.

When you run, you should see that ``metawards`` is siginficantly faster.
Also, as the outbreak is not seeded, nothing much happens.

Seeding the outbreak
--------------------

Up to now, you have been using the ``ExtraSeedsLondon.dat`` file to seed
every outbreak. This file contains the single line;

::

    1       5   255

The three numbers instruct ``metawards`` to seed the outbreak on day 1
(the first number), infecting 5 individuals (the second number) in
ward 255 (the third number).

.. warning::

   The name of this file is misleading, as it is really seeding
   the ward with index 255, not seeding a ward in London. This will
   only be seeding London if the network this is used with has a
   ward in London at index 255.

If you try to seed using this file you will get an error, e.g.

.. code-block:: bash

   metawards -d lurgy_home -m single -P 100 -a ExtraSeedsLondon.dat

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ERROR ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Unable to seed the infection using (1, 255, 5, None). The error was <class 'IndexError'>: Invalid node index
    255. Number of nodes in this container equals 2. Please double-check that you are trying to seed a node that
    exists in this network.

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Traceback (most recent call last):

    [lots of output]

    IndexError: Invalid node index 255. Number of nodes in this container equals 2

.. note::

   The traceback can be long and complex, and is really only of use for ``metawards``
   developers. You can normally work out what has gone wrong by scrolling up
   to before the traceback, and seeing if there is a ``ERROR`` printed immediately
   before.

We have provided an ``ExtraSeedsOne.dat`` file, which seeds 5 infections
in ward 1 on the first day of the outbreak. This contains the line;

::

  1       5        1

which says to seed 5 individuals on the first day in ward 1.

.. note::

   Nodes are indexed from 1 rather than 0. This means that ``ward[1]``
   is the first node, and ``ward[nnodes]`` is the last node in the
   network.

You can use this with single-ward networks, e.g.

.. code-block:: bash

   metawards -d lurgy_home -m single -P 100 -a ExtraSeedsOne.dat

However, creating a file to seed an outbreak is inconvenient, particularly
when you only want to seed a single ward. You can, optionally, pass
the seeding information as the argument, instead of the filename. Thus
this will work;

.. code-block:: bash

   metawards -d lurgy_home -m single -P 100 -a "1 5 1"

Equally, you can seed on multiple days, e.g. seeding 5 individuals on day 1,
and then 10 individuals on day 2, via;

.. code-block:: bash

   metawards -d lurgy_home -m single -P 100 -a "1 5 1\n2 10 1"

The contents of the string is interpreted identically to if it had been
read from a file, with ``\n`` representing a newline character.

.. note::

   The extra seeds file has a flexible and powerful format, e.g. supporting
   seeding by date, seeding random wards or by random amounts etc.
   More information on the format of this file can
   be :doc:`found here <../../fileformats/extraseeds>`.
