====================
MetaWards.extractors
====================

These are the extractor functions that are used during a model run
to extract data from the outbreak to process and write live to files.
The functions divide into two main types,
the most important of which are described below;

``extract_functions`` which determine which functions will be called to output data
    * :meth:`~metawards.extractors.extract_default`
    * :meth:`~metawards.extractors.extract_custom`
    * :meth:`~metawards.extractors.extract_large`
    * :meth:`~metawards.extractors.extract_small`
    * :meth:`~metawards.extractors.extract_none`

``output_functions`` which perform the actual work of outputting data
    * :meth:`~metawards.extractors.output_basic`
    * :meth:`~metawards.extractors.output_core`
    * :meth:`~metawards.extractors.output_dispersal`
    * :meth:`~metawards.extractors.output_incidence`
    * :meth:`~metawards.extractors.output_prevalence`

All of the above functions (and the many others in metawards.extractors) are
described :doc:`in more detail here <./index_api_MetaWards_extractors>`;

.. toctree::
   :maxdepth: 1

   index_api_MetaWards_extractors
