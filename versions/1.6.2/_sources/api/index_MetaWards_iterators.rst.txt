===================
MetaWards.iterators
===================

These are the iterator functions that are used by the model to advance
the outbreak from day to day. The functions divide into two main types,
the most important of which are described below;

``iterate_functions`` which control which functions are called to advance the outbreak
    * :meth:`~metawards.iterators.iterate_default`
    * :meth:`~metawards.iterators.iterate_custom`
    * :meth:`~metawards.iterators.iterate_weekday`
    * :meth:`~metawards.iterators.iterate_weekend`
    * :meth:`~metawards.iterators.iterate_working_week`

``advance_functions`` which perform the actual work of advancing the outbreak
    * :meth:`~metawards.iterators.advance_foi`
    * :meth:`~metawards.iterators.advance_additional`
    * :meth:`~metawards.iterators.advance_infprob`
    * :meth:`~metawards.iterators.advance_fixed`
    * :meth:`~metawards.iterators.advance_play`
    * :meth:`~metawards.iterators.advance_work`

All of the above functions (and the many others in metawards.iterators) are
described :doc:`in more detail here <./index_api_MetaWards_iterators>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_iterators
