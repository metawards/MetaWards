==========
Model data
==========

Getting the data
================

MetaWards uses a large amount of data to describe the network over which
the model is run. This data is stored in a separate
`MetaWardsData <https://github.com/metawards/MetaWardsData>`__ repository.

You can download this data in one of two ways;

Direct download
    Download one of the data releases from the
    `releases page <https://github.com/metawards/MetaWardsData/releases>`__.
    It is best to choose the latest release unless you are trying to
    reproduce an earler calculation.

    You can download the data as a ``zip`` or a ``tar.gz`` archive, and
    can unpack it using either;

    .. code-block:: bash

        tar -zxvf MetaWardsData-0.2.0.tar.gz

    if you downloaded the 0.2.0 release tar.gz file, or

    .. code-block:: bash

        unzip MetaWardsData-0.2.0.zip

    if you downloaded the zip file.

Git clone
    You can clone the data repository using

    .. code-block:: bash

        git clone https://github.com/metawards/MetaWardsData

Finding the data
================

Once you have downloaded the data you will need to tell metawards
where the data is located. This can be done in one of three ways;

1. Set the ``METAWARDSDATA`` environment variable equal to the full path
   to the data, e.g.

   .. code-block:: bash

        export METAWARDSDATA=$HOME/MetaWardsData

   (assuming you have placed it in your home directory)

2. Pass the full path to the data to metawards using the command line argument
   ``--repository``, e.g.

   .. code-block:: bash

        metawards --repository $HOME/MetaWardsData

    (again assumes you have placed it in your home directory)

3. Move the data to ``$HOME/GitHub/MetaWardsData`` as this is the default
   search location, e.g.

   .. code-block:: bash

        mkdir $HOME/GitHub
        mv $HOME/MetaWardsData $HOME/GitHub/

Versioning the data
===================

Provenance is very important for MetaWards. It is important to know what
inputs were used for a model run so that it is possible to recreate the
calculation and thus reproduce the result.

To aid this, MetaWardsData has a small script that you should run after
you have downloaded the data. This will version the data by finding the
git tag of the data. Run this script using;

.. code-block:: bash

    cd $METAWARDSDATA
    ./version

This will create a small file called ``version.txt`` which will look
something like this;

.. code-block:: bash

    {"version": "0.2.0","repository": "https://github.com/metawards/MetaWardsData","branch": "main"}

This file will be read by metawards during a run to embed enough information
in the outputs to enable others to download the same MetaWardsData input
as you.

Understanding the data
======================

The MetaWardData repository contains four types of data;

model_data
    The ``model_data`` directory contains the data needed to construct
    a network of wards and links. Currently the 2011 model is included,
    in the ``2011Data`` directory. The manifest of files that
    comprise this model is ``2011Data/description.json``. This json
    file is read by metawards to find and load all of the files that
    are needed for this model.

diseases
    The ``diseases`` directory contains the parameters for different
    diseases. Each disease is described in its own json file, e.g.
    the parameters for SARS-Cov-2 are in ``diseases/ncov.json``.
    Once of the main purposes of metawards is to perform parameter
    sweeps to adjust these disease parameters so that a model epidemic
    can more closely follow what is observed in reality. From there,
    more meaningful predictions should be able to be made.

parameters
    The ``parameters`` directory contains parameters used to control
    metawards model runs. These represent "good defaults" for the
    values of the parameters, and are stored in the MetaWardsData
    repository to make it easier to version control and track
    provenance of the parameters used for different jobs.
    The parameters used for jobs in March 2020 (and correct as
    of March 29th) are in ``parameters/march29.json``.

extra_seeds
    The ``extra_seeds`` directory contains files that can be used
    to seed new model disease clusters at different wards during
    a model run. Each file can contain as many additional seeds
    as needed. The format is three numbers per line;
    ``t   num   loc``, where ``t`` is the step (day) on which
    the additional infection will be seeded, ``num`` is the number
    of additional infections, and ``loc`` is the index of the
    ward in the model network in which the infection will occur.
