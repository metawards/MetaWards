========================
Extracting rates by ward
========================

One of the major applications of a custom extractor is to enable you
to add your own live-analysis that is performed while the simulation
is running. This is much faster than having ``metawards`` write all
data to disk, and then running analysis in a post-processing step.

To analyse data, you need to understand the
:class:`~metawards.Workspace` class.

Workspace
---------

The :class:`~metawards.Workspace` class provides a workspace in which data
is accumulated and analysis performed. It is cleared between iterations,
and holds the following information;

Data indexed by disease stage:
    * ``inf_tot``: The total number of workers in each disease stage, summed over all wards.

    * ``pinf_tot``: The total number of players in each disease stage, summed over all wards.

    * ``n_inf_wards``: The number of wards which have at least one individual in the disease stage,

Data indexed by ward:
    * ``total_inf_ward``: The total number of infections in each ward

    * ``total_new_inf_ward``: The total number of new infections in each ward

    * ``incidence``: The incidence of infection in each ward

    * ``S_in_wards``: The total population in the ``S`` state in each ward

    * ``E_in_wards``: The total population in the ``E`` state in each ward

    * ``I_in_wards``: The total population in the ``I`` state in each ward

    * ``R_in_wards``: The total population in the ``R`` state in each ward

Data indexed by disease stage and then by ward
   * ``ward_inf_tot``: The total population in each disease stage in each ward

Extracting the population in I1
-------------------------------

We can use a custom extractor to report the total number of individuals
who are in the first ``I`` stage (I1) for each ward for each day.

To do this, create a new extractor called ``extract_i1.py`` and copy
in the below;

.. code-block:: python

    from metawards.extractors import extract_default


    def output_i1(population, workspace, output_dir, **kwargs):
        # Open the file "total_i1.csv" in the output directory
        FILE = output_dir.open("total_i1.csv")

        ward_inf_tot = workspace.ward_inf_tot

        # The I1 state is stage 2
        I1_inf_tot = ward_inf_tot[2]

        FILE.write(str(population.day) + ",")
        FILE.write(",".join([str(x) for x in I1_inf_tot]) + "\n")


    def extract_i1(**kwargs):
        # return all of the functions from "extract_default"
        # plus our new "output_i1"
        funcs = extract_default(**kwargs)
        funcs.append(output_i1)
        return funcs

This defines a new output function called ``output_i1``. This calls the
``open`` function of the :class:`~metawards.OutputFiles` object held
in ``output_dir`` to open the file ``total_i1.csv`` in the output
directory.

.. note::

   The :class:`~metawards.OutputFiles` class is clever enough to only
   open the file once, and will automatically close it when needed. It
   will also ensure that the file is opened in the correct output
   directory for a *model run* and will compress the file using bz2
   if the ``--auto-bzip`` command-line option has been passed (the default),
   or will disable automatic compression if ``--no-auto-bzip`` is set.

The function then gets ``I1_inf_tot`` from the third disease stage data
held in ``workspace.ward_inf_tot``. The third stage is the first ``I``
stage as the first stage (``ward_inf_tot[0]``) is a special ``*`` stage,
used for advanced bookkeeping, while the second stage (``ward_inf_tot[1]``)
is the latent, ``E`` stage.

.. note::

   The ``*`` stage is used to help evaluate how many wards see new infections.
   Individuals are moved into the ``*`` stage at the point of infection,
   and are moved into the ``E`` stage on the day after infection. By default,
   individuals in the ``*`` stage are counted into ``R``, which is why this
   does not appear to rise continuously. You can control how individuals
   in the ``*`` stage are counted using either ``--star-is-E`` to count them
   as ``E`` (additional latent stage), ``--star-is-R`` to count them as
   ``R`` (default behaviour) or ``--disable-star`` to remove the ``*``
   stage and instead treat this first stage as the one and only ``E`` stage.
   Note that if you do this, you will need to update the disease files to
   remove the ``*`` stage, and to update your above extractor as now
   stage 1 will be the first ``I`` stage.

Now that we have the population in the ``I1`` stage in each ward in
``I1_inf_tot``, we write this as a comma-separated line to the file,
starting each line with the day number obtained from the passed
:class:`~metawards.Population` typed ``population`` object.

To use your extractor run ``metawards`` using;

.. code-block:: bash

   metawards -d lurgy3 --extract extract_i1 -a ExtraSeedsLondon.dat --nsteps 30

.. note::

   Note that we've set ``nsteps`` to 30 for illustration only,
   just to limit the runtime and the size of the file. In a real production
   run you wouldn't need to set the number of steps.

You should see that your file called ``total_i1.csv.bz2`` has been created
in the output directory, and that this contains the populations of the ``I1``
state for each ward.

Calculating rates
-----------------

As well as outputting raw data, you can also perform some simple analysis
that is run live during the *model run*. For example, you may want to record
the number of individuals entering each state, so that you can calculate
the rate of progress across states.

To do this, you will need to save the ``ward_inf_tot`` data from the previous
day's state. You can do this by adding it as a custom attribute to the
workspace.

Create a new extractor by creating ``extract_rate.py`` and copying in the below;

.. code-block:: python

    from metawards.extractors import extract_default
    from copy import deepcopy


    def output_rate(population, workspace, output_dir, **kwargs):
        if not hasattr(workspace, "output_rate_previous"):
            # This is the first day, so we cannot calculate the rate.
            # Instead, just save today's data so that it can be
            # be used tomorrow
            workspace.output_rate_previous = deepcopy(workspace.ward_inf_tot)
            return

        # get yesterday's data
        ward_inf_previous = workspace.output_rate_previous

        # get today's data
        ward_inf_tot = workspace.ward_inf_tot

        # calculate and write the difference between the two to files for
        # each disease stage...
        for i in range(0, workspace.n_inf_classes):
            FILE = output_dir.open(f"rate_{i}.csv")

            FILE.write(str(population.day))

            # loop over the data for each ward and write the
            # difference to the file
            for old, new in zip(ward_inf_previous[i], ward_inf_tot[i]):
                FILE.write("," + str(new - old))

            FILE.write("\n")

        # save today's data so that it can be used tomorrow
        workspace.output_rate_previous = deepcopy(ward_inf_tot)


    def extract_rate(**kwargs):
        funcs = extract_default(**kwargs)
        funcs.append(output_rate)
        return funcs

This extractor looks a little more complex, but it builds on what you have
seen before. It defines ``output_rate``, which if the function that will
output the rates, and ``extract_rate`` which returns all of the functions
from ``extract_default``, plus your new ``output_rate`` function.

The first job of ``output_rate`` is to determine if it has been called on
the first day of the model. If it has, then there is no previous data
from "yesterday" that can be used to calculate the rate. The function
detects if this is the case by checking for a new custom attribute
that will be under the control of this function. We will call this
attribute ``output_rate_previous``, so to minimise the risk of a name
collision. If this attribute doesn't exist, then we must be on the first
day. We this save today's data so that it can be used tomorrow.

If the attribute does exist, then we can calculate a rate. We do that by
getting yesterday's data from ``output_rate_previous`` and todays data
from ``workspace.ward_inf_tot``. We then loop over all of the disease
stages, and open an output file for each stage (called ``rate_{i}.csv``).
We then write into this file the day, then the difference between today's
and yesterday's population in ward, for this ``ith`` disease stage.

Finally, we save today's data into ``workspace.output_rate_previous``, so
that it can be used tomorrow as yesterday's data.

Run this extractor in ``metawards`` using;

.. code-block:: bash

   metawards -d lurgy3 --extract extract_rate -a ExtraSeedsLondon.dat --nsteps 30

(again, we are limiting this to 30 steps just for demonstration reasons)

You should see that you have files ``rate_0.csv.bz2``, ``rate_1.csv.bz2`` etc.
now created in the output directory. If you look at these files you should
see that they contain the differences between the populations in each ward
for each disease stage between each day.

Writing to a database
---------------------

In the last example we wrote rates to a large number of files. While this has
worked, the data is beginning to get so large and multi-dimensional that
we are reaching the limits of what a CSV or other data file can
reasonably support. As data sizes get larger, it is better to start
writing data to a database.

The :class:`~metawards.OutputFiles` class has in-built support for opening
connections to `SQLite3 <https://docs.python.org/3/library/sqlite3.html>`__
databases. To use this, we call the function
:meth:`~metawards.OutputFiles.open_db`. For example, let's now create a new
extractor that will output the size of the population at each disease stage
for each day, and the change compared to the previous day. To do this,
open a file called ``extract_db.py`` and copy in the below;

.. code-block:: python

    from metawards.extractors import extract_default


    def create_tables(N_INF_CLASSES):
        # return a function that creates the tables
        # for the specified number of disease classes

        def initialise(conn):
            # create a table for the values...
            values = ",".join([f"stage_{i} int" for i in range(0, N_INF_CLASSES)])
            c = conn.cursor()
            c.execute(f"create table totals(day int, S int, {values})")

            # create a table for the rates...
            c.execute(f"create table deltas(day int, S int, {values})")

            conn.commit()

        return initialise


    def output_db(population, workspace, output_dir, **kwargs):
        have_yesterday = hasattr(workspace, "output_rate_previous")

        # get today's data
        inf_tot = workspace.inf_tot
        pinf_tot = workspace.pinf_tot
        S = population.susceptibles

        N_INF_CLASSES = workspace.n_inf_classes

        # open a database to hold the data - call the 'create_tables'
        # function on this database when it is first opened
        conn = output_dir.open_db("stages.db",
                                initialise=create_tables(N_INF_CLASSES))

        c = conn.cursor()

        # get the values for today
        today = [population.day, S] + [inf+pinf for inf, pinf in zip(inf_tot, pinf_tot)]

        # convert this to a string
        today_str = ",".join([str(t) for t in today])

        # write these to the database
        c.execute(f"insert into totals VALUES ({today_str})")

        if hasattr(workspace, "output_rate_db"):
            yesterday = workspace.output_rate_db

            # calculate the difference in all columns of today and yesterday
            deltas = [t - y for t, y in zip(today, yesterday)]
            # (except for the day, which should be today)
            deltas[0] = today[0]

            delta_str = ",".join([str(d) for d in deltas])

            # write this to the database
            c.execute(f"insert into deltas values ({delta_str})")

        conn.commit()

        # save today's data so that it can be used tomorrow
        workspace.output_rate_db = today


    def extract_db(**kwargs):
        funcs = extract_default(**kwargs)
        funcs.append(output_db)
        return funcs

Here, we have created a new function called ``create_tables`` that is called
to create a function that is returned and passed to
:meth:`~metawards.OutputFiles.open_db`. This function creates two tables
in the database; ``totals`` which contains the total population at each
disease stage, and ``deltas``, which contains the difference from the
previous day.

Next, we have ``output_db``. This function calls
:meth:`~metawards.OutputFiles.open_db` to create the connection, ``conn``
to the SQLite3 database. This connection is a standard Python
`sqlite3 connection object <https://docs.python.org/3/library/sqlite3.html>`__.

We calculate the total population in each stage as the sum of
``inf_tot`` (the workers at each stage) and ``pinf_tot`` (the players
at each stage). We prepend the number of susceptibles and also the
day number.

We then write this, as today's data, to the database via a cursor.

Next, we check if there is any data from yesterday by looking for the
custom attribute ``workspace.output_rate_db``. If there is, then we
get this data, and then calculate the difference from the previous day.
This is then written to the ``deltas`` table via the cursor.

Finally, we commit the changes to the database, and then save today's
data to ``workspace.output_rate_db`` so that it can be used tomorrow.

Run this extractor by typing;

.. code-block:: bash

   metawards -d lurgy3 --extract extract_db -a ExtraSeedsLondon.dat --nsteps 30

(again, we limit to 30 days just for illustration purposes)

Once this has finished, you should see a file called ``output/stages.db.bz2``.

Uncompress this file and then examine it using any SQLite3 database viewer,
e.g.

.. code-block:: bash

    # sqlite3 output/stages.db
    SQLite version 3.31.1 2020-01-27 19:55:54
    Enter ".help" for usage hints.
    sqlite> .dump
    PRAGMA foreign_keys=OFF;
    BEGIN TRANSACTION;
    CREATE TABLE totals(day int, S int, stage_0 int,stage_1 int,stage_2 int,stage_3 int,stage_4 int,stage_5 int);
    INSERT INTO totals VALUES(0,56082077,0,0,0,0,0,0);
    INSERT INTO totals VALUES(1,56082072,0,5,0,0,0,0);
    INSERT INTO totals VALUES(2,56082072,0,0,5,0,0,0);
    INSERT INTO totals VALUES(3,56082067,5,0,3,2,0,0);
    INSERT INTO totals VALUES(4,56082064,3,5,2,1,2,0);
    INSERT INTO totals VALUES(5,56082061,3,3,6,1,2,1);
    INSERT INTO totals VALUES(6,56082051,10,3,8,1,3,1);
    INSERT INTO totals VALUES(7,56082039,12,10,9,3,2,2);
    INSERT INTO totals VALUES(8,56082026,13,12,17,4,2,3);
    INSERT INTO totals VALUES(9,56082002,24,13,26,4,4,4);
    INSERT INTO totals VALUES(10,56081982,20,24,34,8,3,6);
    INSERT INTO totals VALUES(11,56081950,32,20,55,5,8,7);
    INSERT INTO totals VALUES(12,56081887,63,32,66,10,6,13);
    INSERT INTO totals VALUES(13,56081827,60,63,76,30,6,15);
    INSERT INTO totals VALUES(14,56081733,94,60,128,25,20,17);
    INSERT INTO totals VALUES(15,56081588,145,94,169,31,21,29);
    INSERT INTO totals VALUES(16,56081405,183,145,222,58,22,42);
    INSERT INTO totals VALUES(17,56081131,274,183,317,78,42,52);
    INSERT INTO totals VALUES(18,56080808,323,274,434,105,57,76);
    INSERT INTO totals VALUES(19,56080318,490,323,618,144,82,102);
    INSERT INTO totals VALUES(20,56079687,631,490,798,229,96,146);
    INSERT INTO totals VALUES(21,56078886,801,631,1134,273,159,193);
    INSERT INTO totals VALUES(22,56077748,1138,801,1539,356,224,271);
    INSERT INTO totals VALUES(23,56076190,1558,1138,2028,488,301,374);
    INSERT INTO totals VALUES(24,56074172,2018,1558,2759,652,388,530);
    INSERT INTO totals VALUES(25,56071530,2642,2018,3760,883,525,719);
    INSERT INTO totals VALUES(26,56067981,3549,2642,4997,1226,714,968);
    INSERT INTO totals VALUES(27,56063321,4660,3549,6723,1522,961,1341);
    INSERT INTO totals VALUES(28,56057020,6301,4660,8943,2095,1221,1837);
    INSERT INTO totals VALUES(29,56048552,8468,6301,11808,2834,1631,2483);
    CREATE TABLE deltas(day int, S int, stage_0 int,stage_1 int,stage_2 int,stage_3 int,stage_4 int,stage_5 int);
    INSERT INTO deltas VALUES(1,-5,0,5,0,0,0,0);
    INSERT INTO deltas VALUES(2,0,0,-5,5,0,0,0);
    INSERT INTO deltas VALUES(3,-5,5,0,-2,2,0,0);
    INSERT INTO deltas VALUES(4,-3,-2,5,-1,-1,2,0);
    INSERT INTO deltas VALUES(5,-3,0,-2,4,0,0,1);
    INSERT INTO deltas VALUES(6,-10,7,0,2,0,1,0);
    INSERT INTO deltas VALUES(7,-12,2,7,1,2,-1,1);
    INSERT INTO deltas VALUES(8,-13,1,2,8,1,0,1);
    INSERT INTO deltas VALUES(9,-24,11,1,9,0,2,1);
    INSERT INTO deltas VALUES(10,-20,-4,11,8,4,-1,2);
    INSERT INTO deltas VALUES(11,-32,12,-4,21,-3,5,1);
    INSERT INTO deltas VALUES(12,-63,31,12,11,5,-2,6);
    INSERT INTO deltas VALUES(13,-60,-3,31,10,20,0,2);
    INSERT INTO deltas VALUES(14,-94,34,-3,52,-5,14,2);
    INSERT INTO deltas VALUES(15,-145,51,34,41,6,1,12);
    INSERT INTO deltas VALUES(16,-183,38,51,53,27,1,13);
    INSERT INTO deltas VALUES(17,-274,91,38,95,20,20,10);
    INSERT INTO deltas VALUES(18,-323,49,91,117,27,15,24);
    INSERT INTO deltas VALUES(19,-490,167,49,184,39,25,26);
    INSERT INTO deltas VALUES(20,-631,141,167,180,85,14,44);
    INSERT INTO deltas VALUES(21,-801,170,141,336,44,63,47);
    INSERT INTO deltas VALUES(22,-1138,337,170,405,83,65,78);
    INSERT INTO deltas VALUES(23,-1558,420,337,489,132,77,103);
    INSERT INTO deltas VALUES(24,-2018,460,420,731,164,87,156);
    INSERT INTO deltas VALUES(25,-2642,624,460,1001,231,137,189);
    INSERT INTO deltas VALUES(26,-3549,907,624,1237,343,189,249);
    INSERT INTO deltas VALUES(27,-4660,1111,907,1726,296,247,373);
    INSERT INTO deltas VALUES(28,-6301,1641,1111,2220,573,260,496);
    INSERT INTO deltas VALUES(29,-8468,2167,1641,2865,739,410,646);
    COMMIT;
