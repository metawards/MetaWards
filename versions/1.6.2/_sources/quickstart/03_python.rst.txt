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

First, we need to save the current version of the lurgy to a file called
``lurgy.json.bz2``.

.. code-block:: python

   >>> lurgy.to_json("lurgy.json.bz2")

Next, we must create a milder version of the lurgy and save this to
``mild_lurgy.json.bz2`` using;

.. code-block:: python

   >>> mild_lurgy = mw.Disease("mild_lurgy")
   >>> mild_lurgy.add("E", progress=0.25, beta=0.0)
   >>> mild_lurgy.add("I", progress=0.5, beta=0.2)
   >>> mild_lurgy.add("R")
   >>> mild_lurgy.to_json("mild_lurgy.json.bz2")

Creating the networks
---------------------

We now need to create the three networks for the three demographics.
We will start with the students, who will move between home and school.
This will be saved to ``students.json.bz2``.

.. code-block:: python

   >>> home = mw.Ward("home")
   >>> school = mw.Ward("school")
   >>> home.add_workers(3000, destination=school)
   >>> students = mw.Wards()
   >>> students.add(home)
   >>> students.add(school)
   >>> students.to_json("students.json.bz2")

We will next do the same for the teachers, who will also move between
home and school (saving to ``teachers.json.bz2``).

.. code-block:: python

   >>> home = mw.Ward("home")
   >>> school = mw.Ward("school")
   >>> home.add_workers(200, destination=school)
   >>> teachers = mw.Wards()
   >>> teachers.add(home)
   >>> teachers.add(school)
   >>> teachers.to_json("teachers.json.bz2")

Next, we will create the default network. This will consist of some players
who stay at home, and workers who go to work.

.. code-block:: python

   >>> home = mw.Ward("home")
   >>> work = mw.Ward("work")
   >>> home.set_num_players(10000)
   >>> home.add_workers(7000, destination=work)
   >>> default = mw.Wards()
   >>> default.add(home)
   >>> default.add(work)
   >>> default.to_json("default.json.bz2")

Creating the demographics
-------------------------

Next, we create the demographics. We do this by creating
:class:`~metawards.Demographic` objects for each demographic that
specify the network and disease to use for each group. These are then
combined into a single :class:`~metawards.Demographics` object.

.. code-block:: python

   >>> students = mw.Demographic("students",
                                 disease="mild_lurgy.json.bz2",
                                 network="students.json.bz2")
   >>> teachers = mw.Demographic("teachers",
                                 disease="lurgy.json.bz2",
                                 network="teachers.json.bz2")
   >>> default = mw.Demographic("default",
                                disease="lurgy.json.bz2",
                                network="default.json.bz2")
   >>> demographics = mw.Demographics()
   >>> demographics.add(default)
   >>> demographics.add(teachers)
   >>> demographics.add(students)
   >>> print(demographics)

   [
     Demographic(name='default', work_ratio=0.0, play_ratio=0.0, disease=lurgy.json.bz2, network='default.json.bz2')
     Demographic(name='teachers', work_ratio=0.0, play_ratio=0.0, disease=lurgy.json.bz2, network='teachers.json.bz2')
     Demographic(name='students', work_ratio=0.0, play_ratio=0.0, disease=mild_lurgy.json.bz2, network='students.json.bz2')
   ]

Running the model
-----------------

We can run the model by passing in the demographics. Note that we don't need
to specify the model as this is now fully specified in the demographics.

.. code-block:: python

   >>> results = mw.run(disease=lurgy, demographics=demographics,
                        additional="1, 5, home, default", silent=True)

.. note::

   We have added ``default`` to the additional seeding to specify that the
   initial infections will be in this demographic. This is needed as a current
   limitation of MetaWards is that you can only seed infections in players,
   and only the default demographic in this example has players.

You can then process and graph the results as before;

.. code-block:: python

   >>> df = pd.read_csv(results)
   >>> df.plot.line(x="day", y=["S","E","I","IR","R"])

When you do this, you will notice that the number of susceptibles falls
until it reaches a number above 3200. This is because we seeded the outbreak
in the ``default`` demographic. By default, demographics do not mix with
each other, and so the outbreak does not spread to the teachers or
students.

We can control the amount of mixing of demographics using the ``mixer``
argument. This specifies a mixing function to use. We will use
:func:`~metawards.mixers.mix_evenly`, which sets that all demographics will
mix evenly with each other.

.. code-block:: python

   >>> results = mw.run(disease=lurgy, demographics=demographics,
                        additional="1, 5, home, default",
                        mixer="mix_evenly", silent=True)
   >>> df = pd.read_csv(results)
   >>> df.plot.line(x="day", y=["S","E","I","IR","R"])

Now you should see that the outbreak spreads through the entire population.

.. note::

   The ``trajectory.csv.bz2`` file in the output directory of the run
   contains the trajectory for each of the demographics in each
   disease state. You can load this to generate demographic graphs.

Complete code
-------------

The complete Python code for this part of the getting started guide is
re-copied below (this continues from the code in the last part);

.. code-block:: python

   # save the lurgy to disk
   lurgy.to_json("lurgy.json.bz2")

   # create a milder lurgy and save to disk
   mild_lurgy = mw.Disease("mild_lurgy")
   mild_lurgy.add("E", progress=0.25, beta=0.0)
   mild_lurgy.add("I", progress=0.5, beta=0.2)
   mild_lurgy.add("R")
   mild_lurgy.to_json("mild_lurgy.json.bz2")

   # create the students network
   home = mw.Ward("home")
   school = mw.Ward("school")
   home.add_workers(3000, destination=school)
   students = mw.Wards()
   students.add(home)
   students.add(school)
   students.to_json("students.json.bz2")

   # create the teachers network
   home = mw.Ward("home")
   school = mw.Ward("school")
   home.add_workers(200, destination=school)
   teachers = mw.Wards()
   teachers.add(home)
   teachers.add(school)
   teachers.to_json("teachers.json.bz2")

   # create the default network
   home = mw.Ward("home")
   work = mw.Ward("work")
   home.set_num_players(10000)
   home.add_workers(7000, destination=work)
   default = mw.Wards()
   default.add(home)
   default.add(work)
   default.to_json("default.json.bz2")

   # now create the demographics
   students = mw.Demographic("students",
                             disease="mild_lurgy.json.bz2",
                             network="students.json.bz2")
   teachers = mw.Demographic("teachers",
                             disease="lurgy.json.bz2",
                             network="teachers.json.bz2")
   default = mw.Demographic("default",
                            disease="lurgy.json.bz2",
                            network="default.json.bz2")
   demographics = mw.Demographics()
   demographics.add(default)
   demographics.add(teachers)
   demographics.add(students)

   # run the model
   results = mw.run(disease=lurgy, demographics=demographics,
                    additional="1, 5, home, default",
                    mixer="mix_evenly", silent=True)

   # graph the results
   df = pd.read_csv(results)
   df.plot.line(x="day", y=["S","E","I","IR","R"])

What's next?
------------

This was a quick start guide to show some of the capabilities of MetaWards.
To learn more, e.g. how to create custom iterators to model lockdowns,
how to write extractors to get more detailed information output,
how to write mixers for modelling shielding etc., or how to write movers
to model conditional branching, please do now follow the
:doc:`tutorial <../tutorial/index>`.
