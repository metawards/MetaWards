====================
Adjustable Variables
====================

We have now adjusted the **disease file** for the lurgy, which has
resulted in a *model run* that has involved a larger section of the
population in the disease outbreak. However, the values we chose
for the parameters in the **disease file** were made up. They had
no basis in reality, which means that it is difficult to use this
model to make good predictions.

``metawards`` is designed to support parameter searches that seek to
adjust the disease parameters so that predictions from *model runs*
can be matched to observed reality. The idea is that variables are
adjusted until the *model runs* can reliably capture the observed
behaviour of an outbreak, at which point the model may then act
as a good prediction of the future.

Choosing what to adjust
-----------------------

In the last section we introduced a new stage to the lurgy in which
infected individuals were very mobile (**too_ill_to_move** was 0.0),
but also very infectious (**beta** was 0.5).

This was introduced as stage 3 of the lurgy. We need therefore to tune
the **beta[2]** and **too_ill_to_move[2]** parameters (remembering that
we count from zero). What we want to do is vary these two parameters
and see how they affect the model outbreak.

To do this, in your current directory create a file called ``lurgyparams.csv``
and copy in the text below;

::

  beta[2]  too_ill_to_move[2]
    0.3         0.00
    0.4         0.00
    0.5         0.00
    0.3         0.25
    0.4         0.25
    0.5         0.25
    0.3         0.50
    0.4         0.50
    0.5         0.50

This file has two columns of numbers; ``beta[2]`` which shows how to
adjust the **beta[2]** value, and ``too_ill_to_move[2]`` which shows
how to adjust the **too_ill_to_move[2]** value. Each row of this file
represents a single model run using this pair of values. For example,
the line ``0.3       0.00`` will set **beta[2]** to 0.3 and
**too_ill_to_move[2]** to 0.0.

.. note::
   The format of this file is very flexible. Columns can be space-separated
   or comma-separated, as long as this is consistent in the entire file.
   You can choose to adjust any of the parameters for any stage
   of a disease. Simply title the column with the parameter name, e.g.
   ``beta``, ``progress``, ``too_ill_to_move`` or ``contrib_foi``, and
   add the stage number in square brackets, e.g. ``beta[0]``. Remember
   that we count from zero, so stage one has index zero.

You can pass ``metawards`` this input file using the ``--input``
(or ``-i``) command-line option. This input file has nine pairs
of values of **beta[2]** and **too_ill_to_move[2]**, which means that
nine *model runs* need to be performed. To run them all, use this command;

.. code-block:: bash

   metawards -d lurgy2 -a ExtraSeedsLondon.dat --input lurgyparams.csv

This will run all nine jobs. If you have nine or more processor cores
on your computer then all of them will be run in parallel (with
individual *model runs* then using any other cores you have). If, like me,
you are running this on your laptop, then this may take 10+ minutes
to complete.

.. note::
  If you want to distribute this work over a set of disconnected
  computers, you can tell ``metawards`` to only adjust parameters
  from a subset of the lines of the input file. To do this,
  use the ``--line`` (or ``-l``) command line argument to specify
  the line or lines to process. Lines are counted from 0 being the
  top line (containing the header), and multiple lines or ranges
  can be specified, e.g. ``-l 1 2 3`` will use lines one to three,
  while ``-l 4-6`` would use lines four to six (inclusive).

.. warning::
  We are only going to use one repeat of each pair of values, which means
  that our results will suffer from a lot of random error. Ideally you
  should ask for multiple repeats using the ``--repeats`` command-line
  argument. A good value would be at least eight repeats. In this case,
  eight repeats would require 72 *model runs*. If you parallelise
  each run over 16 cores then this needs 1152 cores. Fortunately, for
  these jobs, ``metawards`` runs well in parallel
  :doc:`across a slurm or PBS cluster <../../cluster_usage>`.

Once the jobs are complete (which took 15 minutes on my laptop), you
should have output that looks similar to this;

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ MULTIPROCESSING ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 1 of 9                                                                  │
    │  (beta[2]=0.3, too_ill_to_move[2]=0)[repeat 1]                                         │
    │  2020-12-15: DAY: 209 S: 7978312    E: 0    I: 0    R: 48103765    IW: 1   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 2 of 9                                                                  │
    │  (beta[2]=0.4, too_ill_to_move[2]=0)[repeat 1]                                         │
    │  2020-11-28: DAY: 192 S: 7046459    E: 0    I: 0    R: 49035618    IW: 0   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 3 of 9                                                                  │
    │  (beta[2]=0.5, too_ill_to_move[2]=0)[repeat 1]                                         │
    │  2020-11-17: DAY: 181 S: 6221586    E: 0    I: 0    R: 49860491    IW: 1   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 4 of 9                                                                  │
    │  (beta[2]=0.3, too_ill_to_move[2]=0.25)[repeat 1]                                      │
    │  2020-12-13: DAY: 207 S: 8010218    E: 0    I: 0    R: 48071859    IW: 0   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 5 of 9                                                                  │
    │  (beta[2]=0.4, too_ill_to_move[2]=0.25)[repeat 1]                                      │
    │  2020-12-02: DAY: 196 S: 7071208    E: 0    I: 0    R: 49010869    IW: 1   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 6 of 9                                                                  │
    │  (beta[2]=0.5, too_ill_to_move[2]=0.25)[repeat 1]                                      │
    │  2020-12-01: DAY: 195 S: 6260263    E: 0    I: 0    R: 49821814    IW: 0   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 7 of 9                                                                  │
    │  (beta[2]=0.3, too_ill_to_move[2]=0.5)[repeat 1]                                       │
    │  2021-01-01: DAY: 226 S: 8031161    E: 0    I: 0    R: 48050916    IW: 0   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 8 of 9                                                                  │
    │  (beta[2]=0.4, too_ill_to_move[2]=0.5)[repeat 1]                                       │
    │  2020-11-27: DAY: 191 S: 7103861    E: 0    I: 0    R: 48978216    IW: 0   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    Computing model run ✔
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Completed job 9 of 9                                                                  │
    │  (beta[2]=0.5, too_ill_to_move[2]=0.5)[repeat 1]                                       │
    │  2020-11-16: DAY: 180 S: 6293958    E: 0    I: 0    R: 49788119    IW: 0   UV: 1.0     │
    │  TOTAL POPULATION 56082077                                                             │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                        │
    │  Writing a summary of all results into the csv file                                    │
    │  /Users/chris/GitHub/tutorial/test/output/results.csv.bz2. You can use this to         │
    │  quickly look at statistics across all runs using e.g. R or pandas                     │
    │                                                                                        │
    └────────────────────────────────────────────────────────────────────────────────────────┘


Output directories
------------------

The output files for each repeat are placed into subdirectories of the
main output directory. By default, these subdirectories are named
according to the fingerprint of the adjustable variables used for each
run, e.g. listing the contents of the output directory using;

.. code-block:: bash

   $ ls output
   0i3v0i0x001     0i3v0i5x001     0i4v0i25x001    0i5v0i0x001     0i5v0i5x001     console.log.bz2
   0i3v0i25x001    0i4v0i0x001     0i4v0i5x001     0i5v0i25x001    config.yaml     results.csv.bz2

The fingerprint is a unique key used for each run, e.g.
``0i3v0i0x001`` refers to the run using values ``0.3 0.0``, and the
first repeat. The ``i`` represents a decimal point, ``v`` is used to
separate values, and ``x001`` means the first repeat.

Similarly, ``0i4v0i25x001`` refers to the first repeat of the values
``0.4 0.25``.

Sometimes you may want to specify the names of the output directories
yourself. You can do this by adding a ``output`` column to your scan file,
e.g.

::

  beta[2]  too_ill_to_move[2]      output
    0.3         0.00           beta_0i3_ill_0i00
    0.4         0.00           beta_0i4_ill_0i00
    0.5         0.00           beta_0i5_ill_0i00
    0.3         0.25           beta_0i3_ill_0i25
    0.4         0.25           beta_0i4_ill_0i25
    0.5         0.25           beta_0i5_ill_0i25
    0.3         0.50           beta_0i3_ill_0i50
    0.4         0.50           beta_0i4_ill_0i50
    0.5         0.50           beta_0i5_ill_0i50

Running ``metawards`` with this file would place output in the following
directories;

.. code-block:: bash

   $ ls output
   beta_0i3_ill_0i00 beta_0i4_ill_0i00 beta_0i5_ill_0i00 config.yaml
   beta_0i3_ill_0i25 beta_0i4_ill_0i25 beta_0i5_ill_0i25 console.log.bz2
   beta_0i3_ill_0i50 beta_0i4_ill_0i50 beta_0i5_ill_0i50 results.csv.bz2

If you run multiple repeats of these jobs, e.g. using the ``--repeats``
keyword via;

.. code-block:: bash

   metawards -d lurgy2 -a ExtraSeedsLondon.dat --input lurgyparams.csv --repeats 2

then the repeat number will be automatically added to the directory names,
e.g.

.. code-block:: bash

   $ ls output
   beta_0i3_ill_0i00     beta_0i4_ill_0i00     beta_0i5_ill_0i00     config.yaml
   beta_0i3_ill_0i00x002 beta_0i4_ill_0i00x002 beta_0i5_ill_0i00x002 console.log.bz2
   beta_0i3_ill_0i25     beta_0i4_ill_0i25     beta_0i5_ill_0i25     results.csv.bz2
   beta_0i3_ill_0i25x002 beta_0i4_ill_0i25x002 beta_0i5_ill_0i25x002
   beta_0i3_ill_0i50     beta_0i4_ill_0i50     beta_0i5_ill_0i50
   beta_0i3_ill_0i50x002 beta_0i4_ill_0i50x002 beta_0i5_ill_0i50x002
