=======================
Input files and formats
=======================

Input data in ``metawards`` is provided via a variety of different files,
many of which are described below.

There are three types of input files:

1. Flexible-format: These are a very flexible format, and support a wide
   range of input data types and layout options. Examples include
   the :doc:`extra seeds <extraseeds>`, :doc:`design <design>`
   and :doc:`user input <userinput>` files.

2. Rigid-format: These have a rigid format, which is specific to their
   type. The main examples of this are the files used to specify
   a model (e.g. :doc:`the network, connections etc. <network>`)

3. JSON-format: These are files that are in standard
   `JSON <https://en.wikipedia.org/wiki/JSON>`__ format. Examples include
   the disease and demographics files, plus many of the files
   in MetaWardsData (e.g. the description of the model data, and the
   static parameters file).

Flexible-format files
---------------------

Flexible-format files are read using the
`Python CSV module <https://docs.python.org/3/library/csv.html>`__.
These files are either column or row based (depending on the file type),
and you are free to use
a comma or spaces as the separator (but must be consistent within a file).
Comments can be added using a ``#`` character, and blank lines are
ignored.

Data within a flexible-format file is interpreted using
:class:`metawards.Interpret`. This can interpret simple data, such as
strings, numbers, booleans (``true`` or ``false``), as well as complex
data such as dates (``next week``, ``January 10 2020``), expressions
(``10.0 / 3.0``, ``pi * 2.3**2``) and random numbers
(``rand(0,10)``, ``rand()``, ``rand(2.5, 2.6)``).

Rigid-format files
------------------

Rigid-format files are read using a custom parser for each file type. As
such, the files have a rigid format that is specified for each file type.
We plan to migrate as many rigid-format files across to either
flexible-format or JSON-format as possible.

JSON-format files
-----------------

JSON-format files are standard `JSON <https://en.wikipedia.org/wiki/JSON>`__
files that are used for small or less-structured files, e.g. specifying
the parameters for a disease, or specifying the data associated with
different demographics. These files are read using the
`Python JSON module <https://docs.python.org/3/library/json.html>`__
into dictionaries, which are interpreted by the classes associated with
each file (e.g. :class:`~metawards.Disease` in the case of disease parameters).
Many of these classes use :class:`metawards.Interpret` to interpret the
data from the JSON file, meaning that these support expressions, random
numbers etc. We plan to ensure that as much data as possible is interpreted
using :class:`metawards.Interpret`, so that there is a consistent
experience across the code.

Detailed descriptions
---------------------

.. toctree::
   :maxdepth: 2

   network
   extraseeds
   design
   userinput
