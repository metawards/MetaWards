=============================
Accumulating into a Workspace
=============================

The default function that is always called by
:meth:`~metawards.utils.extract` is
:meth:`metawards.extractors.output_core`.

This core extractor performs the bulk of the work of accumulating all of
the infection data into a single :class:`metawards.Workspace` object.

This :class:`metawards.Workspace` object contains;

* :meth:`~metawards.Workspace.inf_tot`: The total population size at each
  of the different disease stages from the ``work`` infections.

* :meth:`~metawards.Workspace.pinf_tot`: The total population size at each
  of the different disease stages from the ``play`` infections.

* :meth:`~metawards.Workspace.n_inf_wards`: The number of wards with at
  least one member for each disease stage.

* :meth:`~metawards.Workspace.total_inf_ward`: The size of the infected
  population in each ward (the prevalence).

* :meth:`~metawards.Workspace.total_new_inf_ward`: The number of new infections
  on this day in each ward.

* :meth:`~metawards.Workspace.incidence`: The incidence of infection in each
  ward.

Output incidence
----------------

This :class:`~metawards.Workspace` contains data that can be easily output,
e.g. the :meth:`metawards.extractors.output_incidence` supplied extractor
writes the incidence to a file called ``incidence.dat.bz2``. For example,
you can call this from your ``population.py`` extractor by changing it
to read;

.. code-block:: python

    from metawards.utils import Console

    def output_population(population, output_dir, **kwargs):
        Console.debug("Hello output_population")

        # create an output file called 'population.dat'
        popfile = output_dir.open("population.dat",
                                  headers=["day", "date", "S", "E",
                                           "I", "R"])

        # write the population to this file
        popfile.write(f"{population.day} {population.date.isoformat()} "
                    f"{population.susceptibles} {population.latent} "
                    f"{population.total} {population.recovereds}\n")


    def extract_population(population, **kwargs):
        Console.debug("hello extract_population")

        from metawards.extractors import output_incidence

        if population.day % 2 == 0:
            return [output_population, output_incidence]
        else:
            return [output_incidence]

.. note::
   See how we are calling ``output_incidence`` on every day, but
   ``output_population`` only on even days.

If you run this extractor using

.. code-block:: bash

   metawards --extractor population

You will now see that you get a file called ``incidence.dat.bz2``
in the output directory. This will be a big matrix of mostly zeroes,
as no infection has been seeded.

Default outputs
---------------

The default extractor is :meth:`~metawards.extractors.extract_default`.
This returns;

* :meth:`~metawards.extractors.output_basic`: Writes out basic information
  to the files ``NumberWardsInfected.dat``, ``TotalInfections.dat`` etc.

* :meth:`~metawards.extractors.output_dispersal`: Calculates and writes out
  the geographic disperal of the outbreak to ``MeanXY.dat``, ``VarXY.day``
  and ``Dispersal.dat``

* :meth:`~metawards.extractors.output_prevalence`: Writes the (large)
  prevalence matrix to ``prevalence.dat``.

* :meth:`~metawards.extractors.output_incidence`: Writes the (large) incidence
  matrix to ``incidence.dat``.

You can use :meth:`~metawards.extractors.extract_default`
either by not supplying an extractor
via the ``--extractor`` command line argument, or by specifying
``--extract-default``.

Have a go using;

.. code-block:: bash

   metawards --extractor extract_default

As well as :meth:`~metawards.extractors.extract_default`, there is also
:meth:`~metawards.extractors.extract_small` (only extracting the
"small" files),
"meth:`~metawards.extractors.extract_large` (extract everything, including
producing large trajectory files) and
:meth:`~metawards.extractors.extract_none` (extract nothing - useful if
you want to restrict output only to ``results.csv.bz2``).
