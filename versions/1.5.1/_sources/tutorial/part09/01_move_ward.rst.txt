========================
Creating intricate moves
========================

Up to now you have used the top-level go functions (e.g.
:func:`~metawards.movers.go_isolate`, :func:`~metawards.movers.go_stage`
and :func:`~metawards.movers.go_to`) to perform more complex
moves of individuals between demographics and/or disease stages.

These go functions are built on top of lower-level function
:func:`~metawards.movers.go_ward`. This is a generic go function that
can move individuals between any and all combinations of
demographics, disease stages, wards (for players)
(for workers) and :class:`~metawards.PersonType` (worker or player).

It uses :class:`~metawards.movers.MoveGenerator` to define the move.
This is a generator that generates all of the moves to perform
based on the arguments to its constructor.

Using MoveGenerator
-------------------

You construct a :class:`~metawards.movers.MoveGenerator` object by specifying
the ``from`` and ``to`` states of individuals for the moves to be
generated. You can specify one or more of;

* ``from_demographic`` / ``to_demographic`` : Moving individuals between
  different demographics (and thus different networks)
* ``from_stage`` / ``to_stage`` : Moving individuals between different
  disease stages
* ``from_ward`` / ``to_ward`` : Moving individuals between different
  wards.

You can use the index or the name of the demographic, stage or ward when
specifying the move.

For example;

.. code-block:: python

   from metawards.movers import MoveGenerator

   # Move from disease stage E to I
   gen = MoveGenerator(from_stage="E", to_stage="I")

   # Move from disease stage 0 to 1
   gen = MoveGenerator(from_stage=0, to_stage=1)

   # Move from demographic "red" to "blue"
   gen = MoveGenerator(from_stage="red", to_stage="blue")

   # Move from ward Bristol to London
   gen = MoveGenerator(from_ward="Bristol", to_ward="London")

   # Move from ward with ID 5 to ID 7
   gen = MoveGenerator(from_ward=5, to_ward=7)

You can also specify multiple from and to stages, e.g.

.. code-block:: python

   from metawards.movers import MoveGenerator

   # Move from both E and I to R
   gen = MoveGenerator(from_stage=["E", "I"], to_stage="R")

   # Move from S to E, and also move from I to R
   gen = MoveGenerator(from_stage=["S", "I"], to_stage=["E", "R"])

   # Move from red and blue to green
   gen = MoveGenerator(from_demographic=["red", "blue"], to_demographic="green")

   # Move from Bristol and Oxford to London
   gen = MoveGenerator(from_ward=["Bristol", "Oxford"], to_ward="London")

If a state isn't specified, then all matching individuals will move,
keeping the states the same as much as possible. So a move from
disease stage E to I that does not specify a move of demographic or ward
would move all individuals in every demographic and every ward from
E to I.

You can limit this by specifying multiple states per move, e.g.

.. code-block:: python

   from metawards.movers import MoveGenerator

   # Move everyone in the blue demographic from E to I
   gen = MoveGenerator(from_demographic="blue", from_stage="E", to_stage="I")

   # Move everyone in the I stage from Bristol to Oxford
   gen = MoveGenerator(from_stage="I", from_ward="Bristol", to_ward="Oxford")

   # Move everyone in the red demographic and E stage to the blue
   # demographic and I stage
   gen = MoveGenerator(from_demographic="red", from_stage="E",
                       to_demographic="blue", to_stage="I")

   # Move everyone in Bristol from the red demographic and E stage to the blue
   # demographic and I stage
   gen = MoveGenerator(from_ward="Bristol",
                       from_demographic="red", from_stage="E",
                       to_demographic="blue", to_stage="I")

   # Move everyone from Bristol who is in the red demographic and E stage
   # to Oxford to the blue demographic and I stage
   gen = MoveGenerator(from_ward="Bristol", to_ward="Oxford",
                       from_demographic="red", from_stage="E",
                       to_demographic="blue", to_stage="I")

   # Move everyone who is in the red demographic to Oxford from wherever
   # they are now to Oxford
   gen = MoveGenerator(from_demographic="red", to_ward="Oxford")

.. note::

   Note how you can specify the ``from`` without a ``to``. This would mean
   move everyone who matches the ``from``. Note also how you can specify
   the ``to`` without the ``from``. In this case, it moves everyone
   to the ``to``.

WardID and commuters
--------------------

``from_ward`` and ``to_ward`` are a little more complex because individuals
are either workers or players.

Players are modelled in a single ward, and so can be identified just by
the ward ID or name. Thus ``from_ward="Bristol"`` means only the players
who reside in Bristol.

Workers are modelled in a ward-link (or ward-connection). This is a link
from the home ward of the worker to the commute ward where they work each
day. We need to specify both the home and commute ward to identify a worker.
To do this, the :class:`metawards.WardID` class is used, e.g.

.. code-block:: python

   from metawards import WardID
   from metawards.movers import MoveGenerator

   # Move all of the workers who live in Bristol and commute to Oxford
   # to become players who live in London
   gen = MoveGenerator(from_ward=WardID("Bristol", "Oxford"), to_ward="London")

Often you want to identify all workers who reside in a ward, not just those
that commute between two wards. To do this, you need to set
``all_commute`` to true, e.g.

.. code-block:: python

   from metawards import WardID
   from metawards.movers import MoveGenerator

   # Move all of the workers who live in Bristol
   # to become players who live in London
   gen = MoveGenerator(from_ward=WardID("Bristol", all_commute=True),
                       to_ward="London")

This enables you to specify moves with a lot of detail, e.g.

.. code-block:: python

   from metawards import Network, Ward, Network
   from metawards.movers import MoveGenerator

   # create the Bristol, Oxford and London wards
   bristol = Ward("Bristol")
   london = Ward("London")
   oxford = Ward("Oxford")

   # Add the connections for commuters
   bristol.add_workers(0, destination=london)
   bristol.add_workers(0, destination=oxford)
   london.add_workers(0, destination=bristol)
   london.add_workers(0, destination=oxford)

   # build a network from these wards
   network = Network.from_wards(bristol+london+oxford)

   # Move everyone who lives in Bristol from the red to blue demographic
   gen = MoveGenerator(from_wards=["bristol",
                                    WardID("bristol", all_commute=True)],
                       from_demographic="red", to_demographic="blue")

   # Move only workers who live in Bristol from the red to blue demographic
   gen = MoveGenerator(from_wards=WardID("bristol", all_commute=True),
                       from_demographic="red", to_demographic="blue")

   # Move only workers who live in Bristol and commute to London
   # from the red to blue demographic
   gen = MoveGenerator(from_wards=WardID("bristol", "london"),
                       from_demographic="red", to_demographic="blue")

   # Move only workers who commute to London from red to blue
   gen = MoveGenerator(from_wards=[WardID("bristol", "london"),
                                   WardID("oxford", "london")],
                       from_demographic="red", to_demographic="blue")

   # Move all workers who commute to Oxford to become players in Oxford
   gen = MoveGenerator(from_wards=[WardID("bristol", "oxford"),
                                   WardID("london", "oxford")],
                       to_wards="Oxford")

   # Move all players in Bristol to become workers who commute to London
   gen = MoveGenerator(from_wards="Bristol",
                       to_wards=WardID("Bristol", "London"))

Moving a number or fraction
---------------------------

You can also control how many individuals will be moved using either
the ``number`` or ``fraction`` arguments. ``number`` specifies the
maximum number of individuals in an individual ward or ward-link who can move.
``fraction`` specifies the fraction (percentage) of individuals from an
individual ward or ward-link who can move. ``fraction`` should be
between 0 and 1. If it is not 1, then the fraction of individuals
are sampled according to the random binomial distribution. For example;

.. code-block:: python

   from metawards.movers import MoveGenerator

   # move 50% of individuals from the red to blue demographics
   gen = MoveGenerator(from_demographic="red", to_demographic="blue",
                       fraction=0.5)

   # move up to 10 individuals from each ward or ward-link from the
   # S stage to the E stage. If there are more than or equal to
   # 10 matching individuals, then all 10 will be moved. Else, only
   # the number who match will be moved.
   gen = MoveGenerator(from_stage="S", to_stage="E", number=10)

   # move 25% of the maximum number of 10 players in Bristol to play in Oxford.
   # In this case, 25% of the up-to 10 individuals in Bristol will be sampled
   # using the binomial distribution.
   gen = MoveGenerator(from_ward="Bristol", to_ward="Oxford",
                       number=10, fraction=0.25)

Using go_ward
-------------

:class:`~metawards.movers.MoveGenerator` is used to generate the moves that
are made by :func:`~metawards.movers.go_ward`. This is a go_function that
you can use in a move function. For example, let's create now a
custom go_function that will use :class:`~metawards.movers.MoveGenerator`
and :func:`~metawards.movers.go_ward` to move individuals from the
R stage back to S. This would imply that as soon as they have recovered,
they are not immune and can be infected again.

To do this, create a move function in a file called ``move_cycle.py``
and copy in the below;

.. code-block:: python

   from metawards.movers import MoveGenerator, go_ward


   def move_cycle(**kwargs):

       # Create the go-function
       def go_cycle(**kwargs):
           gen = MoveGenerator(from_stage="R", to_stage="S")
           go_ward(generator=gen, **kwargs)

       # Return this function to be called
       return [go_cycle]

.. note::

   We've put go_cycle inside move_cycle as this is cleaner than
   having it as a function defined in global scope. This style will
   also be used in later pages in this tutorial as it will enable
   information to be passed between multiple go functions.

You can run this model using;

.. code-block:: bash

   metawards --mover move_cycle -m single -d lurgy -a 5

.. note::

   Here we are using the original lurgy disease model and the single
   ward network for speed. We have seeded the outbreak with 5 infections.

You should see that the outbreak cycles forever (cutting off at the
automatic 2-year - 720 day mark). The plot of ``results.csv.bz2``
(e.g. produced using ``metawards-plot``) shows the outbreak becoming
random noise once R individuals are moved back into S, e.g.

.. image:: ../../images/tutorial_9_1.jpg
   :alt: Demographic trajectories for a cyclic model
