========================
Staying under quarantine
========================

From the previous page, we saw that at least 90% of individuals needed to
comply with self-isolation to limit the outbreak.
However, that run assumed that everyone who entered self-isolation remained
quarantined for the full seven days. It is important that we also model
the impact of individuals breaking quarantine early.

go_early functions
------------------

We can represent a fraction of individuals
leaving quarantine early each day by passing the keyword
argument ``fraction`` to
:meth:`~metawards.movers.go_to`. Do this by updating your
``move_isolate.py`` to read;

.. code-block:: python

    from metawards import Population
    from metawards import Networks
    from metawards.movers import go_isolate, go_to

    def move_isolate(network: Networks, population: Population, **kwargs):
        user_params = network.params.user_params

        ndays = 7
        isolate_stage = 3
        compliance_fraction = 0.9

        # fraction who remain in isolation, counting from the longest to
        # shortest stay in isolation.
        remain = [0.9, 0.9, 0.95, 0.95, 1.00, 1.00]

        day = population.day % 7
        isolate = f"isolate_{day}"

        go_early = []

        # have to define this functions one-by-one and not in a loop
        # otherwise python will bind all functions to the value of i
        # of the last iteration of the loop
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 1) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[0]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 2) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[1]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 3) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[2]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 4) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[3]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 5) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[4]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 6) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[5]),
                                **kwargs))

        go_isolate_day = lambda **kwargs: go_isolate(
                                            go_from="home",
                                            go_to=isolate,
                                            self_isolate_stage=isolate_stage,
                                            fraction=compliance_fraction,
                                            **kwargs)

        go_released = lambda **kwargs: go_to(go_from=isolate,
                                             go_to="released",
                                             **kwargs)

        return go_early + [go_released, go_isolate_day]


.. note::
   It would be nicer and less error-prone if we could create the
   ``go_early`` functions in a loop. However, this would not work
   because of the way that Python lambda functions bind their arguments.
   If we did this, the arguments from the last iteration of the loop
   would be used for all of the ``go_early`` functions, i.e. we would
   try to move individuals out of the same ``isolate_N`` demographic
   six times.

.. note::
   Note that we've set ``compliance`` to 0.9 based on the results of the
   last scan.

Here, we've created a new set of go functions called ``go_release_early``.
There is one for each ``isolate_N`` demographic *except* for the
demographic to which individuals will be moved on each day.

This ``go_release_early`` function moves a fraction of individuals from
the ``isolate_N`` demographic to ``released``, representing that fraction
breaking their quarantine early. This fraction is taken from the list
``remain``, which counts up from ``0.90`` to ``1.00``. The first value
(``0.90``) is the fraction for individuals that have been isolating the longest
(six days), and that will remain in isolation that day (i.e. 90% will remain,
while 10% will break quarantine early). The last value (``1.00``) is the
fraction for the individuals who only entered isolation the previous day,
i.e. everyone remains in isolation for at least one day. These ``go_early``
functions are then added before ``go_released`` and ``go_isolate_day``.

Now run ``metawards`` using your ``move_isolate.py`` via;

.. code-block:: bash

   metawards -d lurgy4 -D demographics.json -a ExtraSeedsLondon.dat --mixer mix_isolate --mover move_isolate --nsteps 365

You should see that the disease spreads, now both from individuals who
choose not to self-isolate, and now also from individuals who break
their quarantine early. Graphing the output via;

.. code-block:: bash

   metawards-plot -i output/results.csv.bz2

gives an overview plot that should look something like;

.. image:: ../../images/tutorial_6_5_1.jpg
   :alt: Effect of compliance of remaining in quarantine

It is clear that individuals who break quarantine early contribute
significantly to further spread of the outbreak (> 14 million have
experienced infection after one year in this *model run* compared
to ~6 million if all individuals strictly observed the full seven
days of quarantine).

Scanning quarantine
-------------------

The next step is to scan through different compliance levels for
different numbers of days. To do this, update your
``move_isolate.py`` to read;

.. code-block:: python

    from metawards import Population
    from metawards import Networks
    from metawards.movers import go_isolate, go_to

    def move_isolate(network: Networks, population: Population, **kwargs):
        user_params = network.params.user_params

        ndays = 7
        isolate_stage = 3
        compliance_fraction = 0.9

        # fraction who remain in isolation, counting from the longest to
        # shortest stay in isolation.
        remain = user_params["remain"]

        day = population.day % 7
        isolate = f"isolate_{day}"

        go_early = []

        # have to define this functions one-by-one and not in a loop
        # otherwise python will bind all functions to the value of i
        # of the last iteration of the loop
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 1) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[0]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 2) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[1]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 3) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[2]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 4) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[3]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 5) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[4]),
                                **kwargs))
        go_early.append(lambda **kwargs: go_to(
                                go_from=f"isolate_{(day + 6) % 7}",
                                go_to="released",
                                fraction=(1.0 - remain[5]),
                                **kwargs))

        go_isolate_day = lambda **kwargs: go_isolate(
                                            go_from="home",
                                            go_to=isolate,
                                            self_isolate_stage=isolate_stage,
                                            fraction=compliance_fraction,
                                            **kwargs)

        go_released = lambda **kwargs: go_to(go_from=isolate,
                                            go_to="released",
                                            **kwargs)

        return go_early + [go_released, go_isolate_day]

The only change is that we now read the ``remain`` list from the
custom user variable called ``remain``.

Create a scan file called ``scan_remain.dat`` and copy in the below;

::

 .remain[0]  .remain[1]  .remain[2]  .remain[3]  .remain[4]  .remain[5]
    1.00        1.00        1.00        1.00        1.00        1.00

    0.95        1.00        1.00        1.00        1.00        1.00
    0.95        0.95        1.00        1.00        1.00        1.00
    0.95        0.95        0.95        1.00        1.00        1.00
    0.95        0.95        0.95        0.95        1.00        1.00
    0.95        0.95        0.95        0.95        0.95        1.00
    0.95        0.95        0.95        0.95        0.95        0.95

    0.90        0.95        0.95        0.95        0.95        0.95
    0.90        0.90        0.95        0.95        0.95        0.95
    0.90        0.90        0.90        0.95        0.95        0.95
    0.90        0.90        0.90        0.90        0.95        0.95
    0.90        0.90        0.90        0.90        0.90        0.95
    0.90        0.90        0.90        0.90        0.90        0.90

    0.85        0.90        0.90        0.90        0.90        0.90
    0.85        0.85        0.90        0.90        0.90        0.90
    0.85        0.85        0.85        0.90        0.90        0.90
    0.85        0.85        0.85        0.85        0.90        0.90
    0.85        0.85        0.85        0.85        0.85        0.90
    0.85        0.85        0.85        0.85        0.85        0.85

    0.80        0.85        0.85        0.85        0.85        0.85
    0.80        0.80        0.85        0.85        0.85        0.85
    0.80        0.80        0.80        0.85        0.85        0.85
    0.80        0.80        0.80        0.80        0.85        0.85
    0.80        0.80        0.80        0.80        0.80        0.85
    0.80        0.80        0.80        0.80        0.80        0.80

This will scan the percentage of individuals who should remain in quarantine
each day from ``1.00`` (100%) to ``0.80`` (80%). It does this in increments
of 0.05, starting from the longest period of isolation (7 days) and moving
that to the shortest period (less than 1 day).

There are a large number of jobs, and repeats are needed to properly
sample the outbreak. Here are job scripts to run this job on either a
PBS or Slurm cluster;

.. code-block:: bash

    #!/bin/bash
    #PBS -l walltime=12:00:00
    #PBS -l select=4:ncpus=64:mem=64GB
    # The above sets 4 nodes with 64 cores each

    source $HOME/envs/metawards/bin/activate

    # change into the directory from which this job was submitted
    cd $PBS_O_WORKDIR

    metawards -d lurgy4 -D demographics.json -a ExtraSeedsLondon.dat \
            --mixer mix_isolate --mover move_isolate --extractor extract_none \
            --nsteps 365 -i scan_remain.dat --repeats 8 \
            --nthreads 16 --force-overwrite-output --no-spinner --theme simple

.. code-block:: bash

    #!/bin/bash
    #SBATCH --time=01:00:00
    #SBATCH --ntasks=4
    #SBATCH --cpus-per-task=64
    # The above sets 4 nodes with 64 cores each

    source $HOME/envs/metawards/bin/activate

    metawards -d lurgy4 -D demographics.json -a ExtraSeedsLondon.dat \
            --mixer mix_isolate --mover move_isolate --extractor extract_none \
            --nsteps 365 -i scan_remain.dat --repeats 8 \
            --nthreads 16 --force-overwrite-output --no-spinner --theme simple

Analysis
--------

Once you have run the jobs, you can generate the animation of the overview
plots using;

.. code-block:: bash

   metawards-plot -i output/results.csv.bz2
   metawards-plot --animate output/overview*

You should get an animation that looks something like this;


.. image:: ../../images/tutorial_6_5_2.gif
   :alt: Scanning compliance of remaining in quarantine

Reflections on results
----------------------

Again, it is clear that self-isolation only works well if there is very
high compliance with remaining in quarantine for the full seven days.
As 5% of people break quarantine after 2-3 days, the size of the outbreak
grows from ~6 million to ~15 million. This grows to >20 million if 10%
break quarantine.

All of these results suggest that, for the lurgy, that self-isolation and
quarantine are only effective strategies if;

1. they start as quickly as possible once an individual is infectious
   (which may be difficult due to the early stage of the lurgy being largely
   asymptomatic - track and trace systems would likely need to be used
   and be extremely fast and effective),
2. are observed by the vast majority (>90%) of infected individuals, and
3. >95% of individuals remain in quarantine for the full seven days.

As noted at the start of this tutorial, the lurgy is not a serious disease,
so would not warrant the level of social control needed to achieve these
three requirements (and, indeed, a population that does not perceive the
lurgy to be serious would be unlikely to comply to the level needed).

This should not be surprising given where each *model run* starts - just
five infected individuals in one ward. Any disease that is so contagious that
an infection in such a small group of individuals grows quickly into a
widespread outbreak will always be very difficult to control.
