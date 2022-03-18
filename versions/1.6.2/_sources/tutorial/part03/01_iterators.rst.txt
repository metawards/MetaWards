=====================
How a day is modelled
=====================

You have now used multiple *model runs* to refine the disease parameters
for the lurgy. However, these parameters have been refined for the
model that ``metawards`` uses to represent interactions of individuals.

Work and play
-------------

``metawards`` models disease transmission via two main modes;

1. Infections at "work"

  These are random infections that individuals acquire in the electoral
  ward in which they "work", based on random interactions with others
  who are also in that "work" ward. In this nomenclature, "work" means
  any regular (daily), predictable travel that an individual makes.

1. Infections at "play"

  These are random infections that individuals acquire in the
  electoral ward in which they live, based on random interactions
  with others who are also in their ward. In this nomenclature, "play"
  means random, unpredictable interactions that are not regular.

.. warning::
  Do not read too much into the definitions of "work" and "play". They
  have very broad meanings in ``metawards``, and, in essence, capture
  the difference between predicatable daily travel and interactions
  (commuting, colleagues in an office, students in a school), and
  the random interations (partying, shopping, playing in the park).
  Most of the hard data science behind ``metawards`` is constructing
  the information in
  `MetaWardsData <https://github.com/metawards/MetaWardsData>`__
  to gain this very broad overview of how individuals move and interact.

What is a normal day?
---------------------

``metawards`` uses an ``iterator`` to iterate the model outbreak forward
day by day. All of the iterators are in the
:doc:`metawards.iterators <../../api/index_MetaWards_iterators>` module.
The default iterator is :class:`~metawards.iterators.iterate_default`.

An iterator applies a sequence of functions that advance the disease step
by step through each day. These ``advance_functions`` control exactly
what happens in each electoral ward on each day.

The :func:`~metawards.iterators.iterate_default` iterator applies the
following ``advance_functions`` in sequence;

1. :func:`~metawards.iterators.advance_additional` is applied to
   add any additional seeds of the disease in the ward,
   which leads to new infections. These additional seeds represent, e.g.
   new sources of infection arriving in the ward via outside travel.

2. :func:`~metawards.iterators.advance_foi` is applied to advance the
   calculation of the *force of infection (foi)* for each ward. This must
   be called at the beginning of the day after
   :func:`~metawards.iterators.advance_additional`, as the *foi* parameters
   are used to guide the path of the outbreak in each ward for the
   rest of the day.

3. :func:`~metawards.iterators.advance_recovery` is applied to all
   individuals in a ward who are infected. This will see whether an
   individual progresses from one stage of the disease to the next.
   This decision is based on the **progress** disease parameter for the stage
   that the individual is at.

4. :func:`~metawards.iterators.advance_infprob` is applied to recalculate
   the infection probabilities needed to guide new infections. These are
   based on the *foi* parameters for each ward and the number of
   individuals who are at each stage of the disease (based on the
   **contrib_foi** disease parameter).

5. :func:`~metawards.iterators.advance_fixed` is applied to advance
   all infections that are based on fixed (predictable) movements
   of individuals (the so-called "work" mode). Infected individuals
   continue to "work" unless they become too symptomatic
   (**too_ill_to_move**, based on the parameter for the stage of the
   disease at which the individual is at).

6. Finally :func:`~metawards.iterators.advance_play` is applied to
   advance all infections that are based on random movements of
   individuals (the so-called "play" mode). Infected individuals
   continue to "play" unless they become too symptomatic
   (again controlled by the **too_ill_to_move** disease parameters).

Once all of these functions have been applied, then a day is considered
complete. The statistics for the day, e.g. numbers of individuals
who are in the **S**, **E**, **I**, **IW**, and **R** states are
collected and printed, and then the next day begins and all of
these functions are applied again.
