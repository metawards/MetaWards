================
MetaWards.movers
================

These are the mover functions that are used to move individuals between
different demographics during a multi-demographics *model run*.

The functions divide into two main types;

``move_functions`` that determine which functions are called to move individuals
    * :meth:`~metawards.movers.move_default`
    * :meth:`~metawards.movers.move_custom`

``go_functions`` that perform the work of moving individuals between demographics
    * :meth:`~metawards.movers.go_isolate`

All of the above functions (and the many others in
:mod:`metawards.movers`) are
described :doc:`in more detail here <./index_api_MetaWards_movers>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_movers
