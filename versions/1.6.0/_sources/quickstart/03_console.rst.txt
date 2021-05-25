=============================
Multiple pathways with Python
=============================

MetaWards uses :class:`metawards.Demographics` to model different groups
of individuals in different ways. Individuals can move between
different demographics, and different demographics can experience
different disease models and move within different networks. This
is very powerful, and enables MetaWards to model multiple pathways
for different individuals.

This is explored in more depth in the :doc:`tutorial <../tutorial/index>`.
For this quick start guide, we will create three demographics;

* ``students`` : experience a mild version of the lurgy and travel to school each day
* ``teachers`` : experience the normal version of the lurgy, and also travel to school each day
* ``default`` : experience the normal version of the lurgy and either travel to work each day or stay home and play

Creating a mild disease
-----------------------

We must create a milder version of the lurgy that is written to the file
``mild_lurgy.json.bz2``;

::

  {
    "name": "mild_lurgy",
    "stage": ["E", "I", "R"],
    "beta": [0.0, 0.2, 0.0],
    "progress": [0.25, 0.5, 0.0]
  }

Creating the networks
---------------------

We now need to create the three networks for the three demographics.
We will start with the students, who will move between home and school.
This will be saved to ``students.json``.

::

  [
    {
        "id": 1,
        "info": {
        "name": "home"
        },
        "num_workers": 3000,
        "num_players": 0,
        "workers": {
        "destination": [
            2
        ],
        "population": [
            3000
        ]
        }
    },
    {
        "id": 2,
        "info": {
        "name": "school"
        },
        "num_workers": 0,
        "num_players": 0
    }
  ]

We will next do the same for the teachers, who will also move between
home and school (saving to ``teachers.json.bz2``).

::

  [
    {
        "id": 1,
        "info": {
        "name": "home"
        },
        "num_workers": 200,
        "num_players": 0,
        "workers": {
        "destination": [
            2
        ],
        "population": [
            200
        ]
        }
    },
    {
        "id": 2,
        "info": {
        "name": "school"
        },
        "num_workers": 0,
        "num_players": 0
    }
  ]

Next, we will create the default network. This will consist of some players
who stay at home, and workers who go to work.

::

  [
    {
        "id": 1,
        "info": {
        "name": "home"
        },
        "num_workers": 7000,
        "num_players": 10000,
        "workers": {
        "destination": [
            2
        ],
        "population": [
            7000
        ]
        }
    },
    {
        "id": 2,
        "info": {
        "name": "work"
        },
        "num_workers": 0,
        "num_players": 0
    }
  ]

Creating the demographics
-------------------------

Next, we create the demographics. We do this by creating
a file called ``network.json`` that contains data for each demographic that
specify the network and disease to use for each group.

::

  {
    "demographics": [
        "default",
        "teachers",
        "students"
    ],
    "diseases": [
        "lurgy.json",
        "lurgy.json",
        "mild_lurgy.json"
    ],
    "networks": [
        "default.json",
        "teachers.json",
        "students.json"
    ]
  }

.. note::

   Like before, it is easier to write these json file using the Python
   or R APIs. Any small errors in the file can cause difficult-to-debug
   errors when running metawards.

Running the model
-----------------

We can run the model by passing in the demographics. Note that we don't need
to specify the model as this is now fully specified in the demographics.

.. code-block:: bash

   metawards --disease lurgy.json --demographics demographics.json --additional "1, 100, home, default"

.. note::

   We have added ``default`` to the additional seeding to specify that the
   initial infections will be in this demographic. This is needed as a current
   limitation of MetaWards is that you can only seed infections in players,
   and only the default demographic in this example has players.

You can then process and graph the results as before;

.. code-block:: bash

   metawards-plot -i output/results.csv.bz2

When you do this, you will notice that the number of susceptibles falls
until it reaches a number above 3200. This is because we seeded the outbreak
in the ``default`` demographic. By default, demographics do not mix with
each other, and so the outbreak does not spread to the teachers or
students.

We can control the amount of mixing of demographics using the ``mixer``
argument. This specifies a mixing function to use. We will use
:func:`~metawards.mixers.mix_evenly`, which sets that all demographics will
mix evenly with each other.

.. code-block:: bash

   metawards --disease lurgy.json --demographics demographics.json --additional "1, 100, home, default" --mixer mix_evenly
   metawards-plot -i output/results.csv.bz2

Now you should see that the outbreak spreads through the entire population.

.. note::

   The ``trajectory.csv.bz2`` file in the output directory of the run
   contains the trajectory for each of the demographics in each
   disease state. You can load this to generate demographic graphs.

What's next?
------------

This was a quick start guide to show some of the capabilities of MetaWards.
To learn more, e.g. how to create custom iterators to model lockdowns,
how to write extractors to get more detailed information output,
how to write mixers for modelling shielding etc., or how to write movers
to model conditional branching, please do now follow the
:doc:`tutorial <../tutorial/index>`.
