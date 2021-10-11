==============================
Modelling population movements
==============================

We can use :func:`~metawards.movers.go_ward` to model population movements.
There are many mass population movements that occur through the year,
e.g. people travelling to holiday destinations in the summer, people
travelling home to family at Christmas, and students going to university
in the autumn. Each of these have the potential to spread a local
disease outbreak and seed it in many new locations.

Ward 0, the null ward
---------------------

To perform this move, we first need to gather together all of the students,
into a single "scratch" or "null" ward, from where they can then
be dispersed to the various university wards. We want to do this because
it is much more efficient than trying to sample the double loop of
from each ward to each university ward.

To help with this, ``metawards`` provides a single null (or scratch) ward,
which is not used in any calculation. This is ward 0. It is at index 0
in the internal arrays used by ``metawards``. You can use this ward
as a temporary space to hold individuals during the day. However, you
must ensure that there are no individuals left in this ward at the
end of the day, when :func:`~metawards.extractors.output_core`
is called.

Moving to university
--------------------

We will model the first day of university, when (in this ideal model),
all students will travel from their home ward to live in their
university ward. Students will be modelled as workers in the university
ward, who commute to the university ward each day.

Create a mover called ``move_university.py`` and copy in the below;

.. code-block:: python

    from metawards import WardID
    from metawards.movers import MoveGenerator, MoveRecord, go_ward
    from metawards.utils import Console, ran_int


    def move_university(population, **kwargs):

        def go_null(network, **kwargs):
            record = MoveRecord()
            gen = MoveGenerator(to_ward=WardID(0,0), fraction=0.02)

            Console.print("Moving students to the null ward...")
            go_ward(generator=gen, network=network, record=record, **kwargs)

            nstudents = 0

            for r in record:
                nstudents += r[-1]

            Console.print(f"Number of students: {nstudents}")

            ninfected = network.links.weight[0] - network.links.suscept[0]

            Console.print(f"Number of infected students: {int(ninfected)}")

        def go_university(network, rngs, **kwargs):
            # get the first random number generator from the
            # list of thread-local generators
            rng = rngs[0]

            # how many wards are there?
            nwards = network.nnodes

            # generate a list of 50 random wards that
            # represent 50 university towns
            uni_wards = [ran_int(rng, 1, nwards) for _ in range(0, 50)]

            for uni_ward in uni_wards[0:-1]:
                nstudents = 0

                record = MoveRecord()
                gen = MoveGenerator(from_ward=WardID(0,0),
                                    to_ward=WardID(uni_ward, uni_ward),
                                    fraction=0.075)
                go_ward(generator=gen, network=network,
                        rngs=rngs, record=record, **kwargs)

                for r in record:
                    nstudents += r[-1]

                Console.print(f"{nstudents} went to university ward {uni_ward}")

            # move the remainder of the students to the last university
            record = MoveRecord()
            gen = MoveGenerator(from_ward=WardID(0,0),
                                to_ward=WardID(uni_wards[-1], uni_wards[-1]))

            go_ward(generator=gen, network=network,
                    rngs=rngs, record=record, **kwargs)

            nstudents = 0

            for r in record:
                nstudents += r[-1]

            Console.print(f"{nstudents} went to university ward {uni_wards[-1]}")


        if population.day == 20:
            return [go_null, go_university]
        else:
            return []

There is a lot to discuss with this code, so we will explore each bit
separately.

This code defines a mover (``move_university``), which, on the 20th
day of the outbreak, returns two go functions (``go_null`` and
``go_university``). This is controlled by the code at the end of the
function;

.. code-block:: python

        if population.day == 20:
            return [go_null, go_university]
        else:
            return []

go_null
-------

This is the ``go_null`` function again;

.. code-block:: python

        def go_null(network, **kwargs):
            record = MoveRecord()
            gen = MoveGenerator(to_ward=WardID(0,0), fraction=0.02)

            Console.print("Moving students to the null ward...")
            go_ward(generator=gen, network=network, record=record, **kwargs)

            nstudents = 0

            for r in record:
                nstudents += r[-1]

            Console.print(f"Number of students: {nstudents}")

            ninfected = network.links.weight[0] - network.links.suscept[0]

            Console.print(f"Number of infected students: {int(ninfected)}")

This creates a :class:`~metawards.movers.MoveGenerator` that moves
2% of individuals from every ward and disease stage to become workers
in the null ward.

.. note::

   Workers in the null ward have a :class:`~metawards.WardID` of
   ``WardID(0,0)``, while players have ``WardID(0)``, or, simply ``0``.

We use a :class:`~metawards.movers.MoveRecord` to record the moves,
and count up the total number of individuals moved, which is the
total number of students.

The total number of workers in a ward is held in
:meth:`network.links.weight <metawards.Links.weight>`. The current number
of susceptible workers in a ward is held in
:meth:`network.links.suscept <metawards.Links.suscept>`. The null ward
is at index 0, and so;

.. code-block:: python

   ninfected = network.links.weight[0] - network.links.suscept[0]

gives the number of infected workers in the null ward.

.. note::

   Similarly, :meth:`network.nodes.save_play_suscept <metawards.Nodes.save_play_suscept>`
   is the number of players in a ward, while
   :meth:`network.nodes.play_suscept <metawards.Nodes.play_suscept>` is the
   number of susceptible players in a ward. The difference between these
   is the number of infected individuals in a ward.

go_university
-------------

This is the ``go_university`` function again;

.. code-block:: python

        def go_university(network, rngs, **kwargs):
            # get the first random number generator from the
            # list of thread-local generators
            rng = rngs[0]

            # how many wards are there?
            nwards = network.nnodes

            # generate a list of 50 random wards that
            # represent 50 university towns
            uni_wards = [ran_int(rng, 1, nwards) for _ in range(0, 50)]

            for uni_ward in uni_wards[0:-1]:
                nstudents = 0

                record = MoveRecord()
                gen = MoveGenerator(from_ward=WardID(0,0), to_ward=uni_ward,
                                    fraction=0.075)
                go_ward(generator=gen, network=network,
                        rngs=rngs, record=record, **kwargs)

                for r in record:
                    nstudents += r[-1]

                Console.print(f"{nstudents} went to university ward {uni_ward}")

            # move the remainder of the students to the last university
            record = MoveRecord()
            gen = MoveGenerator(from_ward=WardID(0,0), to_ward=uni_wards[-1])

            go_ward(generator=gen, network=network,
                    rngs=rngs, record=record, **kwargs)

            nstudents = 0

            for r in record:
                nstudents += r[-1]

            Console.print(f"{nstudents} went to university ward {uni_wards[-1]}")

Because this is an illustrative model, we are not using any real world
data. As such, we first need to randomly generate the IDs of 50 wards
that will be designated as the locations of the 50 universities in this
model.

To do this, we use ``rngs``, which is a list of random number generators,
one for each running thread of ``metawards``. As this is a single-threaded
function, we will take the first random number generator, and
assign that to the variable ``rng``, via,

.. code-block:: python

           rng = rngs[0]

The 50 random ward IDs are 50 integers randomly picked between 1 and
the number of wards in the network, using the :func:`~metawards.utils.ran_int`
function;

.. code-block:: python

            # how many wards are there?
            nwards = network.nnodes

            # generate a list of 50 random wards that
            # represent 50 university towns
            uni_wards = [ran_int(rng, 1, nwards) for _ in range(0, 50)]

.. note::

   Note that we haven't checked for duplicated random ward IDs because
   this is just meant to be a simple, illustrative model.

Next, we loop over the first 49 of those random wards, and create
a :class:`~metawards.movers.MoveGenerator` that moves 7.5% of the
students (on average) from being workers in the null ward
(``WardID(0,0)``), to being workers in the university ward
(``WardID(uni_ward, uni_ward)``).

.. code-block:: python

            for uni_ward in uni_wards[0:-1]:
                nstudents = 0

                record = MoveRecord()
                gen = MoveGenerator(from_ward=WardID(0,0),
                                    to_ward=WardID(uni_ward, uni_ward),
                                    fraction=0.075)
                go_ward(generator=gen, network=network,
                        rngs=rngs, record=record, **kwargs)

                for r in record:
                    nstudents += r[-1]

                Console.print(f"{nstudents} went to university ward {uni_ward}")

Finally, we move the remaining students from the null ward to the 50th
university;

.. code-block:: python

            # move the remainder of the students to the last university
            record = MoveRecord()
            gen = MoveGenerator(from_ward=WardID(0,0), to_ward=uni_wards[-1])

            go_ward(generator=gen, network=network,
                    rngs=rngs, record=record, **kwargs)

            nstudents = 0

            for r in record:
                nstudents += r[-1]

            Console.print(f"{nstudents} went to university ward {uni_wards[-1]}")

50 universities should have 2% of the students each, so why did we use 7.5%?
The reason is because ``fraction`` is used with a random binomial distribution
to sample a random number of individuals with that fraction. This
underestimates the number as we draw more students. Thus the number
of students sampled reduces as we loop through the 49 universities,
to the point that far too many are remaining to go into the 50th university.
Through trial and error, we found that 7.5% gave a reasonable number remaining
for the 50th university.

Performing the run
------------------

We will run this model using ``lurgy5.json`` developed in the last chapter.
We can run our mover using;

.. code-block:: bash

   metawards -d lurgy5.json -m 2011Data --mover move_university.py -a ExtraSeedsLondon.dat --nsteps 40

We are using the 2011Data England and Wales model, and have seeded five infections
in London. We've limited the run to 40 steps as we are only interested in the
change in the outbreak caused by the movement of students to universities
which, in this model, occurs on day 20.

You can plot the results using;

.. code-block:: bash

   metawards-plot -i output/results.csv.bz2

The resulting graph shows that the movement to university had no
perceptible impact on the outbreak, e.g.

.. image:: ../../images/tutorial_9_4.jpg
   :alt: Outbreak during which students went to university

This is unsurprising when you look at the number of students going to
university, as printed in the output. For example, I got;

::

    Moving students to the null ward...
    Number of students: 1122060
    Number of infected students: 25
    84257 went to university ward 8253
    77500 went to university ward 7782
    72120 went to university ward 5122
    66461 went to university ward 2257
    61307 went to university ward 7124
    56873 went to university ward 2241
    53190 went to university ward 1776
    49065 went to university ward 4896
    44821 went to university ward 7752
    42100 went to university ward 4987
    38481 went to university ward 6981
    35484 went to university ward 4100
    32644 went to university ward 5628
    30619 went to university ward 6048
    28363 went to university ward 4480
    26001 went to university ward 5377
    24077 went to university ward 1395
    22415 went to university ward 3738
    20795 went to university ward 3999
    19507 went to university ward 5433
    17863 went to university ward 8282
    16316 went to university ward 4203
    15206 went to university ward 6343
    13909 went to university ward 5494
    12823 went to university ward 6732
    12102 went to university ward 1645
    11238 went to university ward 8275
    10269 went to university ward 4975
    9476 went to university ward 8339
    8869 went to university ward 5837
    7943 went to university ward 2057
    7668 went to university ward 4077
    6915 went to university ward 1506
    6469 went to university ward 1405
    5863 went to university ward 2197
    5563 went to university ward 6986
    5137 went to university ward 6863
    4851 went to university ward 6086
    4229 went to university ward 2494
    3999 went to university ward 4986
    3747 went to university ward 7534
    3447 went to university ward 1583
    3108 went to university ward 2696
    2966 went to university ward 2020
    2597 went to university ward 398
    2473 went to university ward 2202
    2329 went to university ward 5530
    2089 went to university ward 8114
    1978 went to university ward 3328
    24538 went to university ward 2293

Of the 1.1M students who moved, only 25 were infected. These 25 were
dispersed over 50 wards, and so had little impact on an outbreak
that was already spreading rapidly due to normal movements.
