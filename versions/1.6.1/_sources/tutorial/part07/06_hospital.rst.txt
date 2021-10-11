====================
Modelling a Hospital
====================

Now you've seen how to use and name different disease stages, we can
put all of this together to fully model a hospital.

Disease files
-------------

First, we will create a set of disease files for the different demographics;

First, ``lurgy_home.json``

::

    {
        "stage"            : [ "E1", "E2", "I1", "I2", "I3", "R" ],
        "beta"             : [  0.0,  0.0,  0.2,  0.5,  0.5, 0.0 ],
        "progress"         : [  1.0,  1.0,  0.2,  0.5,  0.5, 0.0 ],
        "too_ill_to_move"  : [  0.0,  0.0,  0.0,  0.5,  0.8, 1.0 ],
        "contrib_foi"      : [  1.0,  1.0,  1.0,  1.0,  1.0, 0.0 ],
        "start_symptom"    : 3
    }

This is the same as ``lurgy4.json`` except we have now named the individual
disease stages. This will be used to model the disease in the general
population and in hospital staff.

Next, ``lurgy_hospital.json``, used to model hospital patients;

::

    {
        "stage"            : [ "H1", "H2" ],
        "beta"             : [  0.2, 0.2  ],
        "progress"         : [  0.2, 0.2  ],
        "too_ill_to_move"  : [  1.0, 1.0  ],
        "contrib_foi"      : [  1.0, 1.0  ],
        "start_symptom"    : 1
    }

Next, ``lurgy_icu.json``, used to model intensive care patients;

::

    {
        "stage"            : [ "ICU", "R" ],
        "beta"             : [  0.2,  0.0 ],
        "progress"         : [  0.2,  0.0 ],
        "too_ill_to_move"  : [  1.0,  1.0 ],
        "contrib_foi"      : [  1.0,  0.0 ],
        "start_symptom"    : 1
    }

And, finally, we need to have an overall disease file that defines the
stages that we want to use for mapping. This just names the mapping
stages, in the order we want to see them reported. This is in
``lurgy_overall.json``;

::

   { "stage" : ["E", "I", "H", "ICU", "R"] }

.. note::

   We don't need to set any disease parameters as these are set by the
   disease files used by the different demographics.

Demographics
------------

Next, we need to update the ``demographics.json`` file to read;

::

    {
        "demographics" : ["home", "staff", "patients", "icu"],
        "work_ratios"  : [ 0.99,   0.01,     0.00,     0.00 ],
        "play_ratios"  : [ 1.00,   0.00,     0.00,     0.00 ],
        "diseases"     : [ "lurgy_home", "lurgy_home",
                           "lurgy_hospital", "lurgy_icu" ]
    }

Here, we've set the ``home`` and ``staff`` demographics to use ``lurgy_home``,
while ``patients`` will use ``lurgy_hospital`` and ``icu`` will use
``lurgy_icu``.

Mixers, movers and extractors
-----------------------------

We can use the same mixer as before, e.g. ``mix_hospital.py`` should be;

.. code-block:: python

    from metawards.mixers import merge_using_matrix

    def mix_shield(network, **kwargs):
        matrix = [ [1.0, 1.0, 0.0, 0.0],
                   [0.0, 0.1, 0.1, 0.1],
                   [0.0, 0.1, 0.0, 0.0],
                   [0.0, 0.1, 0.0, 0.0] ]

        network.demographics.interaction_matrix = matrix

        return [merge_using_matrix]

We can use the same mover as before, except we can now take advantage
of the named disease stages to specify the moves using demographic and
disease name. This is significantly less error-prone than using indexes,
e.g. update ``move_hospital.py`` to read;

.. code-block:: python

    from metawards.movers import go_stage


    def move_hospital(**kwargs):
        # move 20% of I2 home/staff population to H1 patients
        func1 = lambda **kwargs: go_stage(go_from=["home", "staff"],
                                          go_to="patients",
                                          from_stage="I2",
                                          to_stage="H1",
                                          fraction=0.2,
                                          **kwargs)

        # move 10% of H2 patients to ICU1 ICU
        func2 = lambda **kwargs: go_stage(go_from="patients",
                                          go_to="icu",
                                          from_stage="H2",
                                          to_stage="ICU",
                                          fraction=0.1,
                                           **kwargs)

        # move the remainder of H2 patients to home R
        func3 = lambda **kwargs: go_stage(go_from="patients",
                                          go_to="home",
                                          from_stage="H2",
                                          to_stage="R",
                                          fraction=1.0,
                                          **kwargs)

        # move R ICU and H2 patients to home R
        func4 = lambda **kwargs: go_stage(go_from=["patients", "icu"],
                                          go_to="home",
                                          from_stage=["H2", "R"],
                                          to_stage="R",
                                          fraction=1.0,
                                          **kwargs)

        return [func1, func2, func3, func4]

As for the extractor, well we don't really need to use it now as the
data for each stage will be written already into the summary and
individual output files.

Running the job
---------------

Run ``metawards`` using;

.. code-block:: bash

   metawards -D demographics.json -d lurgy_overall --mixer mix_hospital --mover move_hospital -a ExtraSeedsLondon.dat --nsteps 40

.. note::

  We've limited here to running just 40 steps to enable a quick demonstration.
  Feel free to run the full model if you have time.

You should see that statistics for the mapped disease stages for all of the
demographics are written nicely to the screen, e.g.

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 36 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079510  E: 632  I: 1246  H: 117  ICU: 7  R: 565  IW: 509  POPULATION: 56082077
    ┏━━━━━━━━━━┳━━━━━━━━━━┳━━━━━┳━━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━━━━━━━━┓
    ┃          ┃    S     ┃  E  ┃  I   ┃  H  ┃ ICU ┃  R  ┃ IW  ┃ POPULATION ┃
    ┡━━━━━━━━━━╇━━━━━━━━━━╇━━━━━╇━━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━━━━━━━━┩
    │   home   │ 55975294 │ 626 │ 1240 │     │     │ 560 │ 298 │  55977720  │
    │  staff   │  104216  │  6  │  6   │     │     │  5  │  1  │   104233   │
    │ patients │    0     │     │      │ 117 │     │     │ 86  │    117     │
    │   icu    │    0     │     │      │     │  7  │  0  │  7  │     7      │
    ├──────────┼──────────┼─────┼──────┼─────┼─────┼─────┼─────┼────────────┤
    │  total   │ 56079510 │ 632 │ 1246 │ 117 │  7  │ 565 │ 509 │  56082077  │
    └──────────┴──────────┴─────┴──────┴─────┴─────┴─────┴─────┴────────────┘
    Number of infections: 2002

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 37 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56079060  E: 795  I: 1415  H: 148  ICU: 6  R: 653  IW: 622  POPULATION: 56082077
    ┏━━━━━━━━━━┳━━━━━━━━━━┳━━━━━┳━━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━━━━━━━━┓
    ┃          ┃    S     ┃  E  ┃  I   ┃  H  ┃ ICU ┃  R  ┃ IW  ┃ POPULATION ┃
    ┡━━━━━━━━━━╇━━━━━━━━━━╇━━━━━╇━━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━━━━━━━━┩
    │   home   │ 55974849 │ 789 │ 1405 │     │     │ 645 │ 381 │  55977688  │
    │  staff   │  104211  │  6  │  10  │     │     │  6  │  5  │   104233   │
    │ patients │    0     │     │      │ 148 │     │     │ 103 │    148     │
    │   icu    │    0     │     │      │     │  6  │  2  │  6  │     8      │
    ├──────────┼──────────┼─────┼──────┼─────┼─────┼─────┼─────┼────────────┤
    │  total   │ 56079060 │ 795 │ 1415 │ 148 │  6  │ 653 │ 622 │  56082077  │
    └──────────┴──────────┴─────┴──────┴─────┴─────┴─────┴─────┴────────────┘
    Number of infections: 2364

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 38 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56078586  E: 924  I: 1625  H: 168  ICU: 9  R: 765  IW: 696  POPULATION: 56082077
    ┏━━━━━━━━━━┳━━━━━━━━━━┳━━━━━┳━━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━━━━━━━━┓
    ┃          ┃    S     ┃  E  ┃  I   ┃  H  ┃ ICU ┃  R  ┃ IW  ┃ POPULATION ┃
    ┡━━━━━━━━━━╇━━━━━━━━━━╇━━━━━╇━━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━━━━━━━━┩
    │   home   │ 55974378 │ 916 │ 1614 │     │     │ 758 │ 392 │  55977666  │
    │  staff   │  104208  │  8  │  11  │     │     │  6  │  3  │   104233   │
    │ patients │    0     │     │      │ 168 │     │     │ 115 │    168     │
    │   icu    │    0     │     │      │     │  9  │  1  │  9  │     10     │
    ├──────────┼──────────┼─────┼──────┼─────┼─────┼─────┼─────┼────────────┤
    │  total   │ 56078586 │ 924 │ 1625 │ 168 │  9  │ 765 │ 696 │  56082077  │
    └──────────┴──────────┴─────┴──────┴─────┴─────┴─────┴─────┴────────────┘
    Number of infections: 2726

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 39 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56078059  E: 1001  I: 1914  H: 189  ICU: 11  R: 903  IW: 763  POPULATION: 56082077
    ┏━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━┳━━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━━━━━━━━┓
    ┃          ┃    S     ┃  E   ┃  I   ┃  H  ┃ ICU ┃  R  ┃ IW  ┃ POPULATION ┃
    ┡━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━╇━━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━╇━━━━━━━━━━━━┩
    │   home   │ 55973854 │ 995  │ 1899 │     │     │ 894 │ 440 │  55977642  │
    │  staff   │  104205  │  6   │  15  │     │     │  7  │  3  │   104233   │
    │ patients │    0     │      │      │ 189 │     │     │ 135 │    189     │
    │   icu    │    0     │      │      │     │ 11  │  2  │ 11  │     13     │
    ├──────────┼──────────┼──────┼──────┼─────┼─────┼─────┼─────┼────────────┤
    │  total   │ 56078059 │ 1001 │ 1914 │ 189 │ 11  │ 903 │ 763 │  56082077  │
    └──────────┴──────────┴──────┴──────┴─────┴─────┴─────┴─────┴────────────┘
    Number of infections: 3115

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 40 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    S: 56077432  E: 1154  I: 2225  H: 210  ICU: 12  R: 1044  IW: 874  POPULATION: 56082077
    ┏━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━┳━━━━━━┳━━━━━┳━━━━━┳━━━━━━┳━━━━━┳━━━━━━━━━━━━┓
    ┃          ┃    S     ┃  E   ┃  I   ┃  H  ┃ ICU ┃  R   ┃ IW  ┃ POPULATION ┃
    ┡━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━╇━━━━━━╇━━━━━╇━━━━━╇━━━━━━╇━━━━━╇━━━━━━━━━━━━┩
    │   home   │ 55973231 │ 1147 │ 2208 │     │     │ 1033 │ 525 │  55977619  │
    │  staff   │  104201  │  7   │  17  │     │     │  7   │  4  │   104232   │
    │ patients │    0     │      │      │ 210 │     │      │ 147 │    210     │
    │   icu    │    0     │      │      │     │ 12  │  4   │ 12  │     16     │
    ├──────────┼──────────┼──────┼──────┼─────┼─────┼──────┼─────┼────────────┤
    │  total   │ 56077432 │ 1154 │ 2225 │ 210 │ 12  │ 1044 │ 874 │  56082077  │
    └──────────┴──────────┴──────┴──────┴─────┴─────┴──────┴─────┴────────────┘
    Number of infections: 3601

Equally, you will find the individual ``ICU`` and ``R`` populations for
the ``icu`` demographic is ``output/total_infections_icu.csv.bz2``,
and the individual populations for ``H1`` and ``H2`` in the
``patients`` demographic in ``output/total_infections_patients.csv.bz2``.

In addition, the ``output/results.csv.bz2`` and ``output/trajectory.csv.bz2``
files record the totals in the ``H`` and ``ICU`` stages, as well as the
traditional ``S``, ``E``, ``I`` and ``R``, e.g.

.. code-block:: python

   >>> import pandas as pd
   >>> df = pd.read_csv("output/results.csv.bz2")
   >>> df.head()
      fingerprint  repeat  day        date         S  E  I  H  ICU  R  IW   UV
    0      REPEAT       1    0  2020-06-23  56082077  0  0  0    0  0   0  1.0
    1      REPEAT       1    1  2020-06-24  56082072  5  0  0    0  0   1  1.0
    2      REPEAT       1    2  2020-06-25  56082072  0  5  0    0  0   0  1.0
    3      REPEAT       1    3  2020-06-26  56082071  1  5  0    0  0   1  1.0
    4      REPEAT       1    4  2020-06-27  56082069  3  5  0    0  0   3  1.0
