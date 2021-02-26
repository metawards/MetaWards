======================================
Contact probabilities and Demographics
======================================

MetaWards implements the mixing of demographics by merging together
the *force of infections* (FOIs) calculated for each network. By default
this mixing takes no account of the number of individuals (N) in each
ward in each demographic.

The FOI, :math:`F(w)` calculated in each ward, :math:`w` is calculated
separately for each demographic via the equations
:doc:`described here <../part03/07_cutoff>`.

The merged FOI for ward :math:`w` for demographic :math:`i`,
:math:`F_i'(w)`, is calculated as
the sum of the FOIs calculated for ward :math:`w` across
all demographics, :math:`i, j, k...`
scaling by row :math:`i` of the interaction matrix :math:`M` via;

:math:`F_i'(w) = M_{ii} F_i(w) + M_{ij} F_j(w) + M_{ik} F_k(w) + ...`

This is then divided by the number of individuals in ward :math:`w` in
demographic :math:`i`, :math:`N_i(w)` before it is converted into a probability
of infection.

This normalisation by :math:`N_i(w)` means that it is up to you to
account for the contact probability in the interation matrix. The individual
terms should account for both the different infectivity of the different
demographics, as well as the probability that individuals in one
demographic will come into contact with individuals of other demographics.

However, accounting for these different contact rates using just
the interaction matrix is difficult (or impossible) for cases where
you have multiple wards that have different numbers of individuals. This
is because different normalisation factors would be needed for the
FOIs calculated for different wards in different demographics.

Modelling demographics as part of the same population
-----------------------------------------------------

If all demographics are part of the same population then we assume
that any member in a ward of any demographic is equally likely to contact
any other member of the same ward in any other demographic.

In this case, the normalisation factor should be the total number of
individuals in that ward summed over all demographics,
:math:`N(w)`. This is calculated via;

:math:`N(w) = N_i(w) + N_j(w) + N_k(w) + ...`

The merge function :func:`~metawards.mixers.merge_matrix_single_population`
calculates the merged FOI via the equation;

:math:`F_i'(w) = M_{ii} F_i(w) \frac{N_i(w)}{N(w)} + M_{ij} \frac{N_i(w)}{N(w)} F_j(w) + M_{ik} \frac{N_i(w)}{N(w)} F_k(w) + ...`

Because this FOI is divided by :math:`N_i(w)` before it is converted into
an infection probability, this is equivalent to using :math:`N(w)` as the
normalisation factor for ward :math:`w` in all demographics.

This therefore models the demographics as a single population where individuals
in a ward across all demographics have an equal probability of contact with
each other. The interaction matrix has the effect of scaling :math:`\beta`,
i.e. the probability of infection at each contact between members of
different demographics. You can pass in a custom interaction matrix
if you want control of this, or can use the convenience mixer functions
:func:`~metawards.mixers.mix_evenly_single_population`,
and :func:`~metawards.mixers.mix_none_single_population` if you want
to use an interactions matrix of all ones (:math:`M = |1|`) that
represents even infections, or a identity interaction matrix with
a diagonal of 1 and off-diagonal of 0, that represents no infections between
members of different demographics, respectively.

Modelling demographics as multiple populations
----------------------------------------------

It may be that the demographics represent different populations that
have a differnet probability of meeting each other. This would be
the case for the classic use of demographics, e.g. using demographics
to represent different age groups, and having a different contact
probability between individuals of different age groups.

In this case, the FOI calculated from each demographic must be normalised
by the number of individuals in that demographic before it is combined
into the merged demographic. To achieve this,
the merge function :func:`~metawards.mixers.merge_matrix_multi_population`
calculates the merged FOI via the equation;

:math:`F_i'(w) = M_{ii} F_i(w) \frac{N_i(w)}{N_i(w)} + M_{ij} \frac{N_i(w)}{N_j(w)} F_j(w) + M_{ik} \frac{N_i(w)}{N_k(w)} F_k(w) + ...`

Because this FOI is divided by :math:`N_i(w)` before it is converted into
an infection probability, this is equivalent to using :math:`N_x(w)` as the
normalisation factor for ward :math:`w` for demographic :math:`x`.

This therefore models the demographics as being part of separate populations
where the probability of contact between individuals in the same ward
in different demographics depends on the number of individuals in each
demographic.

The interaction matrix has the effect of scaling :math:`\beta`,
i.e. the probability of infection at each contact between members of
different demographics. You can pass in a custom interaction matrix
if you want control of this, or can use the convenience mixer functions
:func:`~metawards.mixers.mix_evenly_multi_population`,
and :func:`~metawards.mixers.mix_none_multi_population` if you want
to use an interactions matrix of all ones (:math:`M = |1|`) that
represents even infections, or a identity interaction matrix with
a diagonal of 1 and off-diagonal of 0, that represents no infections between
members of different demographics, respectively.

Modelling more complex population dynamics
------------------------------------------

For more complex population dynamics you will need to write your own
custom mixer function that accounts for the number of individuals
in each demographic in each ward, :math:`N_x(w)`. Because this will
be potentially an expensive function, you should write it as a
cython plugin using the `.pyx` extension. MetaWards will automatically
compile and load this plugin at runtime.

You should take inspiration from :func:`~metawards.mixers.merge_matrix_single_population`
and :func:`~metawards.mixers.merge_matrix_multi_population`. These show
how the FOIs calculated for each ward are combined with the interaction
matrix and the number of individuals in each ward in each demographic.
Note that the code is slightly more complex than described here, as the
FOIs and number of individuals are calculated separately both for
daytime and nighttime, and the number of individuals is the sum
of the number of players (who make random movements during the day)
and the number of workers (who make predictable movements during the day).

If you have any questions or would like help, please feel free to get
in touch by `raising an issue on the GitHub repository <https://github.com/metawards/MetaWards/issues>`_.
