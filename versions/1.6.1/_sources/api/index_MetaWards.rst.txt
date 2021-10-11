=========
MetaWards
=========

This is the top-level Python package that provides the core objects to
build and run MetaWards models.

The package centers around a few core objects:

:class:`~metawards.Nodes` / :class:`~metawards.Node`
    These represent the individual electoral wards in
    which progress of the disease is tracked.

:class:`~metawards.Links` / :class:`~metawards.Link`
    These represent the connections between electoral wards,
    including how people commute between wards for work. These
    therefore provide the routes via which the disease
    can spread.

:class:`~metawards.Parameters`
    This is the holder of all model parameters that can describe,
    e.g. the proportion of day versus night, cutoff distance
    for transmission between wards etc.
    Example parameter sets are held in the
    `MetaWardsData <https://github.com/metawards/MetaWardsData>`__
    repository.

:class:`~metawards.Disease`
    This is the holder of disease parameters, used to change the model
    to represent different types of disease outbreaks. Different
    disease models are held in the
    `MetaWardsData <https://github.com/metawards/MetaWardsData>`__
    repository.

:class:`~metawards.InputFiles`
    This holds information about all of the input files that are
    used to build the network of wards and links. All of the
    input data is held in the
    `MetaWardsData <https://github.com/metawards/MetaWardsData>`__
    repository.

:class:`~metawards.Network`
    This is the complete network of :class:`~metawards.Nodes` and
    :class:`~metawards.Links` built using
    the data loaded from the :class:`~metawards.InputFiles`,
    set up to model the
    disease whose parameters are in a
    :class:`~metawards.Disease`, using model run
    parameters held in a :class:`~metawards.Parameters` object.
    A Network is self-contained, containing everything needed for a model run.
    The :meth:`~metawards.Network.run` function runs the model.

:class:`~metawards.VariableSet` / :class:`~metawards.VariableSets`
    The model contains adjustable variables,
    which must be adjusted so that the model can match observed
    real-life data. A :class:`~metawards.VariableSet` contains a set
    of variables to
    be adjusted, while :class:`~metawards.VariableSets` is a collection of such
    changes that should be explored over multiple model runs.

:class:`~metawards.Population` / :class:`~metawards.Populations`
    A model run will result in a trajectory of
    changes in populations of people who have progressed along
    different stages of the disease (e.g. from being
    *susceptible to infection* (S), to being
    *removed from the outbreak* (R) - either because they
    have recovered or have sadly perished). A
    :class:`~metawards.Population` holds
    the numbers in each state for a single day in the outbreak,
    while :class:`~metawards.Populations` holds the full trajectory.

:class:`~metawards.OutputFiles`
    Manages all of the output files that are produced by the program.
    This can be told to auto-compress (bzip2) all files as they
    are being written.

All of the above classes (and others in the top-level package) are
described :doc:`in more detail here <index_api_MetaWards>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards
