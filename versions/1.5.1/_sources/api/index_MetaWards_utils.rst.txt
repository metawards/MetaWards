===============
MetaWards.utils
===============

These are utility functions that are used by the top-level MetaWards
package to run a model. The functions are heavily inspired by the
C functions from the original program.

The functions divide into four main types, the key functions of which
are described below;

Setting up the network
    * :meth:`~metawards.utils.build_wards_network`
    * :meth:`~metawards.utils.add_wards_network_distance`
    * :meth:`~metawards.utils.initialise_infections`
    * :meth:`~metawards.utils.initialise_play_infections`
    * :meth:`~metawards.utils.move_population_from_play_to_work`
    * :meth:`~metawards.utils.move_population_from_work_to_play`

Performing a model run
    * :meth:`~metawards.utils.run_model`
    * :meth:`~metawards.utils.iterate`
    * :meth:`~metawards.utils.iterate_weekend`

Extracting data from each iteration
    * :meth:`~metawards.utils.extract`

Performing multiple model runs in parallel
    * :meth:`~metawards.utils.run_models`
    * :meth:`~metawards.utils.run_worker`

All of the above functions (and the many others in metawards.utils) are
described :doc:`in more detail here <./index_api_MetaWards_utils>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_utils
