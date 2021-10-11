======================
Using a Custom Network
======================

You can run a simulation using a custom network by passing filename of
the JSON file that contains the network to ``metawards`` via the
``--model`` or ``-m`` parameter.

For example, to use the ``custom_network.json.bz2`` file from the last section,
together with the ``lurgy4.json`` disease model from previous chapters,
and seed the outbreak with 5 infections in London on day 1
you would run;

.. code-block:: bash

   metawards -d lurgy4 -m custom_network.json.bz2 -a "1 5 London"

You should see that the model runs very quickly, producing output similar
to;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Loading additional seeds from the command line
    ┏━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
    ┃ Day ┃ Demographic ┃                                   Ward                                    ┃   Number   ┃
    ┃     ┃             ┃                                                                           ┃   seeded   ┃
    ┡━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━┩
    │  1  │    None     │ 2 : WardInfo(name='London', alternate_names=, code='', alternate_codes=,  │     5      │
    │     │             │        authority='', authority_code='', region='', region_code='')        │            │
    └─────┴─────────────┴───────────────────────────────────────────────────────────────────────────┴────────────┘
    seeding play_infections[0][2] += 5
    S: 20345  E: 5  I: 0  R: 0  IW: 0  POPULATION: 20350
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 20345  E: 0  I: 5  R: 0  IW: 0  POPULATION: 20350
    Number of infections: 5

    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 129 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 2895  E: 0  I: 1  R: 17454  IW: 0  POPULATION: 20350
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 130 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 2895  E: 0  I: 1  R: 17454  IW: 0  POPULATION: 20350
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 131 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 2895  E: 0  I: 1  R: 17454  IW: 0  POPULATION: 20350
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 132 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 2895  E: 0  I: 0  R: 17455  IW: 0  POPULATION: 20350
    Number of infections: 0
    Ending on day 132

Running MetaWards from within Python or R
-----------------------------------------

It is also possible to run your custom network by passing it in directly
to the :func:`metawards.run` function in Python or R. For example,
in Python;

.. code-block:: python

   >>> from metawards import Ward, run
   >>> bristol = Ward(name="Bristol")
   >>> bristol.add_workers(500)
   >>> bristol.set_num_players(750)
   >>> london = Ward(name="London")
   >>> london.add_workers(8500)
   >>> london.set_num_players(10000)
   >>> bristol.add_workers(500, destination=london)
   >>> london.add_workers(100, destination=bristol)
   >>> wards = bristol + london
   >>> print(wards)
   [ Ward( info=Bristol, id=1, num_workers=1000, num_players=750 ), Ward( info=London, id=2, num_workers=8600, num_players=10000 ) ]
   >>> results = run(model=wards, additional=5)

This would create the wards, and then run the model. This will run in a
new directory called ``output_XXXX`` (where XXXX is replaced by a random
string). The ``results`` variable holds the full path to the resulting
``results.csv.bz2`` file for this run. The arguments to
:func:`metawards.run` match those of the command line program. Any Python
objects (e.g. the wards, disease, demographics) can be passed in as
Python objects. They will be automatically converted to JSON files and
passed to the ``metawards`` processed in the background.

.. note::

   You can use the ``+`` operator to add multiple individual ward objects
   together to create the wards, e.g. ``wards = bristol + london``.

.. note::

   You can force :func:`metawards.run` to use a specified output directory
   by passing in the ``output`` argument. You will need to set
   ``force_overwrite_output`` to True to overwrite any existing output.
   You can silence the printing to the screen by passing in
   ``silent = True``.

You can achieve the same in R by typing;

.. code-block:: R

   > library(metawards)
   > bristol <- metawards$Ward(name="Bristol")
   > bristol$add_workers(500)
   > bristol$set_num_players(750)
   > london <- metawards$Ward(name="London")
   > london$add_workers(8500)
   > london$set_num_players(10000)
   > bristol$add_workers(500, destination=london)
   > london$add_workers(100, destination=bristol)
   > wards = metawards$Wards()
   > wards$add(bristol)
   > wards$add(london)
   > print(wards)
   [ Ward( info=Bristol, id=1, num_workers=1000, num_players=750 ), Ward( info=London, id=2, num_workers=8600, num_players=10000 ) ]
   > results <- metawards$run(model=wards, additional=5)

.. note::

   R does not support adding individual ward objects together to get Wards

