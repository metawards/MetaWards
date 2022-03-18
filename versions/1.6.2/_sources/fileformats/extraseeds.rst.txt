=================
Extra seeds files
=================

This file specifies how infections should be seeded in an outbreak.
This is a column-based flexible-format file, with each line of the
file containing information about a specific seeding event.

There should be up to three pieces of information per line;

1. ``day`` : The day or date to seed the infection(s). This should be
   an integer or a date that is interpreted via
   :func:`Interpret.day_or_date <metawards.Interpret.day_or_date>` function.
   This either sets the day number on which to seed, or the exact date
   in which to seed.
2. ``ward`` : The ward (either index or name) in which the infection
   will be seeded. This should either be an integer (whole number) specifying
   the index of the ward (1-indexed), or a string that identifies the
   ward by name, e.g. ``Clifton/Bristol`` would look for the ward called
   ``Clifton`` in the authority ``Bristol``. The ward is looked up by
   name using the :func:`WardInfos.find <metawards.WardInfos.find>`
   function.
3. ``number`` : The number of infections to be seeded. This is an integer
   that is interpreted via the
   :func:`Interpret.integer <metawards.Interpret.integer>` function.
4. ``demographic`` (optional) : The demographic (either index or name)
   in which the infection will be seeded. If this is not specified,
   then the first demographic in the network is seeded. If this is
   the index it is interpreted via
   :func:`Interpret.integer <metawards.Interpret.integer>`, while if this
   is the name then this will direct look-up the demographic by name.

This is a column-formatted file. Like all flexible-format files you can use
commas or spaces to separate columns. The separators used in the first line
will be assumed to be used for the rest of the file. You can order the
columns however you wish, as long as you provide column headers
(``day``, ``ward``, ``number``, and (optionally) ``demographic``). Otherwise
the column orders are ``day``, ``number``, ``ward``,
(optional) ``demographic``.

You can add extra spaces and blank lines to make the file more readable,
and can add comments via the ``#`` character.

Examples
--------

::

   1   5   1

Seed 5 infections on day 1 (first day) of the outbreak in ward 1.

::

   1, 5, 1

Same, but using commas to separate

::

   day, ward, number
   # seed 5 infections on day 1 in ward 1
   1, 5, 1

Same, but naming the columns and adding a comment

::

   # Seeding two locations in Bristol

   day, demographic, ward, number
   tomorrow, 0, Clifton / Bristol, "rand(5, 20)"

   next week, 0, Knowle / Bristol, 5 + 3

Adding comments and changing the order of columns. Seeding by fuzzy dates,
e.g. ``tomorrow`` and ``next week`` in wards identified by
``name / authority``. Number to be seeded is a random number from 5 to 20
(inclusive) in Clifton, Bristol, and the result of the expression
``5 + 3`` (8) in Knowle.

::

   day             ward       number
   2020-12-05      1          5
   2020-12-10      1          5
   2020-12-15      1          5

Seeding using three `isoformat dates <https://pythontic.com/datetime/date/isoformat>`__
dates (5th, 10th and 15th December 2020), all in ward 1, seeding 5 infections
each day.

