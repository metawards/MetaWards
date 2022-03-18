================
User input files
================

The user input file is used to set the initial values of any parameter
that you could set in a :doc:`design file <design>`. It uses an almost
identical parsing code, and indeed, a design file with a single
row of data is also a valid user input file.

However, while you can read column-orientated data, a user input file
is best written as a row-orientated file. This file has one variable
per row, using either a space, comma, colon or equals sign to
separate the name of the variable from its initial value.

Examples
--------

::

  .isolate_ndays = 7
  .isolate_stage = 3

Set the initial value of ``isolate_ndays`` to ``7`` and
``isolate_stage`` to ``3``.

::

  # Number of days to isolate
  .isolate_ndays: 7

  # Stage at which to start isolating 
  .isolate_stage: 3

Same, except using colon as the separator, and adding comments and blank
lines to improve legibility.

::

  hospital:beta["ICU"]: 0.3
  .lockdown_start: d"next week"

Setting the initial beta parameter of the ``ICU`` stage in the ``hospital``
demographic to ``0.3``, while setting lockdown to start using the
fuzzy date ``next week``.
