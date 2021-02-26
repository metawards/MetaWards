=================
Scanning lockdown
=================

Now that we can create and scan custom variables, we can write a
proper lockdown iterator that enables us to explore different
scenarios.

Create a file called ``lockdown.inp`` and copy in the below;

::

    # Full lockdown (red)
    .scale_rate[0] = 0.05
    .can_work[0]  = False

    # Relaxed lockdown (yellow)
    .scale_rate[1] = 0.1
    .can_work[1]  = False

    # More relaxed lockdown (green)
    .scale_rate[2] = 0.1
    .can_work[2]  = True

This has defined three lockdown states, ranging from "red" (full lockdown
with strong reduction in transmission rate and working) to
"green" (relaxed lockdown with weaker reduction in transmission rate
and work allowed).

To use this data create an iterator in a file called ``lockdown.py`` and
copy in the below;

.. code-block:: python

    from metawards.iterators import advance_infprob, advance_fixed, \
                                    advance_play, iterate_working_week
    from metawards.utils import Console

    def get_lockdown_state(population):
        if not hasattr(population, "lockdown_state"):
            population.lockdown_state = -1
            population.is_locked_down = False

        if population.total > 5000:
            if population.lockdown_state == -1:
                Console.print(f"Lockdown started on {population.date}")
                population.lockdown_state = 0
                population.is_locked_down = True

            elif population.lockdown_state > 0:
                Console.print(f"Restarting lockdown on {population.date}")
                population.lockdown_state = 0
                population.is_locked_down = True

        elif population.total > 3000:
            if population.lockdown_state == 2:
                Console.print(f"Re-entering relaxed (yellow) on {population.date}")
                population.lockdown_state = 1

        elif population.total < 2000:
            if population.lockdown_state == 0:
                Console.print(f"Entering relaxed (yellow) on {population.date}")
                population.lockdown_state = 1

            elif population.total < 1000:
                if population.lockdown_state == 1:
                    Console.print(f"Entering relaxed (green) on {population.date}")
                    population.lockdown_state = 2

        return population.lockdown_state

    def advance_lockdown(network, population, **kwargs):
        params = network.params
        state = get_lockdown_state(population)
        scale_rate = params.user_params["scale_rate"][state]
        can_work = params.user_params["can_work"][state]
        Console.debug("State", variables=[scale_rate, can_work])

        advance_infprob(scale_rate=scale_rate,
                        network=network, population=population,
                        **kwargs)
        advance_play(network=network, population=population,
                    **kwargs)

        if can_work:
            advance_fixed(network=network, population=population,
                        **kwargs)

    def iterate_custom(network, population, **kwargs):
        params = network.params
        state = get_lockdown_state(population)

        if population.is_locked_down:
            Console.debug("Locked down")
            return [advance_lockdown]
        else:
            Console.debug("Normal working week day")
            return iterate_working_week(network=network,
                                        population=population,
                                        **kwargs)

The ``get_lockdown_state`` function is the most complex and different.
It uses the number of infecteds (``population.total``) to decide which
``lockdown_state`` should be used. This is an integer, with ``-1``
meaning no lockdown, ``0`` being "red", ``1`` "yellow" and ``2`` "green".

Whether or not the population is locked down is stored in the
``population.is_locked_down`` variable. If this is "False" then
``iterate_lockdown`` simply returns the result of
:meth:`~metawards.iterators.iterate_working_week`. Otherwise,
it returns the ``advance_lockdown`` function that we've defined.

This ``advance_lockdown`` function obtains the ``scale_rate`` and
``can_work`` custom user parameters from the
:class:`~metawards.Parameters` objects in the model
:class:`~metawards.Network`.

It calls :meth:`~metawards.iterators.advance_infprob` with
the set ``scale_rate`` scaling factor, before calling
:meth:`~metawards.iterators.advance_play`, and then, if
``can_work`` is "True", :meth:`~metawards.iterators.advance_fixed`.

Run ``metawards`` using the below commands and see what you get;

.. code-block:: bash

   metawards -d lurgy3 -a ExtraSeedsLondon.dat  -u lockdown.inp --iterator lockdown --debug
   metawards-plot -i output/results.csv.bz2

I see;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 36 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                Normal working week day                     lockdown.py:63
    S: 56070689  E: 1663  I: 5889  R: 3836  IW: 1352  POPULATION: 56082077
    Number of infections: 7552

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 37 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Lockdown started on 2020-06-26
                                        Locked down                           lockdown.py:60
                                            State                              lockdown.py:43

            Name │ Value
     ════════════╪═══════
      scale_rate │ 0.05
        can_work │ False

    S: 56070608  E: 2118  I: 7192  R: 2159  IW: 80  POPULATION: 56082077
    Number of infections: 9310
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 51 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Entering relaxed (yellow) on 2020-07-10
                                        Locked down                           lockdown.py:60
                                            State                              lockdown.py:43

            Name │ Value
     ════════════╪═══════
      scale_rate │ 0.1
        can_work │ False

    S: 56069562  E: 36  I: 1518  R: 10961  IW: 55  POPULATION: 56082077
    Number of infections: 1554
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 55 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Entering relaxed (green) on 2020-07-14
                                        Locked down                           lockdown.py:60
                                            State                              lockdown.py:43

            Name │ Value
     ════════════╪═══════
      scale_rate │ 0.1
        can_work │ True

    S: 56069369  E: 46  I: 852  R: 11810  IW: 59  POPULATION: 56082077
    Number of infections: 898
    ...
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 187 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                        Locked down                           lockdown.py:60
                                            State                              lockdown.py:43

            Name │ Value
     ════════════╪═══════
      scale_rate │ 0.1
        can_work │ True

    S: 56068649  E: 0  I: 0  R: 13428  IW: 0  POPULATION: 56082077
    Number of infections: 0
    Infection died ... Ending on day 188

with the overview graph as here;

.. image:: ../../images/tutorial_3_6_1_overview.jpg
   :alt: Overview image of a lockdown with custom parameters

Running on a cluster
--------------------

Now that this is working, we can scan through lots of different lockdown
scenarios by creating an input file that varies the ``scale_rate`` and
``can_work`` parameters. Create an input file called ``scan.csv`` and
copy in the following;

::

    # Adjust "red" state from 0.05 to 0.20
    # while adjusting "yellow" from "green" + 0.05 to 0.25
    # while adjusting "green" from "yellow" if working, or
    #                              "yellow" + 0.05 if not

    .scale_rate[0]  .scale_rate[1]  .scale_rate[2]  .can_work[2]
    # first set allow working in "green"
        0.05           0.10            0.10           True
        0.05           0.15            0.15           True
        0.05           0.20            0.20           True
        0.05           0.25            0.25           True
        0.10           0.15            0.15           True
        0.10           0.20            0.20           True
        0.10           0.25            0.25           True
        0.15           0.20            0.20           True
        0.15           0.25            0.25           True
        0.20           0.25            0.25           True

    # second set prevent working in "green"
        0.05           0.10            0.15           False
        0.05           0.15            0.20           False
        0.05           0.20            0.25           False
        0.05           0.25            0.30           False
        0.10           0.15            0.20           False
        0.10           0.20            0.25           False
        0.10           0.25            0.30           False
        0.15           0.20            0.25           False
        0.15           0.25            0.30           False
        0.20           0.25            0.30           False

.. note::
  Note that we have added comments to this file using '#' - these
  are useful to help your future self understand what you were doing

Copy all of the files onto a cluster and submit the job where you
repeat each adjustable variable set 16 times. I used the PBS
job script;

.. code-block:: bash

    #!/bin/bash
    #PBS -l walltime=12:00:00
    #PBS -l select=4:ncpus=64:mem=64GB
    # The above sets 4 nodes with 64 cores each

    # source the version of metawards we want to use
    source $HOME/envs/metawards-0.8.0/bin/activate

    # change into the directory from which this job was submitted
    cd $PBS_O_WORKDIR

    metawards --additional ExtraSeedsLondon.dat \
            --disease lurgy3 -u lockdown.inp \
            --iterator lockdown \
            --input scan.csv --repeats 16 --nthreads 8 \
            --force-overwrite-output

Submit your job (e.g. ``qsub jobscript.sh``) and then wait for it to
finish. Once it has completed, generate the overview and average
graphs via;

.. code-block:: bash

   metawards-plot -i output/results.csv.bz2
   metawards-plot --animate output/overview*.jpg
   metawards-plot --animate output/average*.jpg

What do you see?

I get a range of scenarios, from outbreaks that are controlled until
they die out, through oscillating outbreaks where the population is
forever moved between the "green" and "yellow" lockdown states,
through to outbreaks that grow despite lockdown. These can all
be seen here;

.. image:: ../../images/tutorial_3_6.gif
   :alt: Overview image of a lockdown with custom parameters
