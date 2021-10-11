================
MetaWards.mixers
================

These are the mixer functions that are used to mix and merge data
between demographics during a multi-demographic *model run*.
The functions divide into two main types;


``mix_functions``, which control which functions will be called to merge data
    * :meth:`~metawards.mixers.mix_default`
    * :meth:`~metawards.mixers.mix_custom`
    * :meth:`~metawards.mixers.mix_evenly`
    * :meth:`~metawards.mixers.mix_none`

``merge_functions``, which perform the actual work of merging data across demographics
    * :meth:`~metawards.mixers.merge_evenly`

All of the above functions (and the many others in
:mod:`metawards.mixers`) are
described :doc:`in more detail here <index_api_MetaWards_mixers>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_mixers
