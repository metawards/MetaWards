===================
Design (scan) files
===================

The design (or scan) file specifies which adjustable variables should be
changed during
a ``metawards`` calculation, and which value(s) they should be changed to.

This is a column-orientated flexible-format file, using one column
per adjustable variable. Like all flexible-format files you can use
commas or spaces to separate columns. The separators used in the first line
will be assumed to be used for the rest of the file.

Column headers
--------------

You should name the variables you want to adjust in the column headers.
The format of these is;

* ``variable`` : Just the variable name will adjust that single variable
  for all copies in all demographics
* ``demographic:variable`` : This will adjust the single variable in only
  the demographic named ``demographic``.
* ``variable[1]`` : This will adjust index ``1`` of the named variable
  in all demographics.
* ``variable["E"]`` : This will adjust key ``E`` of the named variable,
  e.g. where the key refers to the disease stage.
* ``demographic:variable["KEY"]`` : This will adjust key ``KEY`` of the
  named variable in the named demographic.
* ``user.myvariable`` : This will adjust a custom user variable called
  ``myvariable`` in all demographics.
* ``.myvariable`` : This will also adjust a custom user variable called
  ``myvariable`` in all demographic (we can drop the ``user`` to save
  space).
* ``demographic:.myvariable[0]`` : This will adjust index 0 of the custom
  user variable ``myvariable`` in the demographic called ``demographic``.

The full list of in-built parameters you can adjust are listed below;

.. program-output:: python get_variableset_help.py

In addition, you can create as many custom-user parameters to adjust
as you would like.

Special columns
---------------

There are two special columns;

* ``repeats`` : Specify the number of repeats of this row of values. This
  should be an integer (whole number) and gives more fine-grained control
  to specifying the number of repeats for different rows in a design.
* ``output``: Specify the output directory in which to place the output
  of the model run using this row of adjustable variables. This overrides
  the default output directory, which is named using the fingerprint
  for this set of adjustable parameters. Use this if you want to have
  control over where all of the output is written. Note that ``metawards``
  does not allow output for multiple model runs to be written to the
  same file, and will append numbers (e.g. ``x002``, ``x003``) to
  any duplicated names.

Default columns
---------------

We highly recommend that you name the columns in your design file. If you
don't, then the default columns will be used. These are;

::

   beta[2]  beta[3]  progress[1]  progress[2]  progress[3]

.. note::

   These defaults came from the original C version of MetaWards, and are
   retained so we keep backwards compatibility with the original
   input files.


Column data
-----------

Values in each column will be interpreted using :class:`metawards.Interpret`.
The code will try to guess the most appropriate data type, moving through
simple numbers,
then isoformat dates, then number expressions (including random number),
then booleans, before returning the data as a string.

You can force the type of the data using numpy-style quote characters. The
type characters recognised are;

* ``d"value"`` : forces ``value`` to be interpreted as a date (isoformat or
  fuzzy date via the `Python dateparser module <https://dateparser.readthedocs.io/en/latest/>`__).
* ``f"value"`` : forces ``value`` to be interpreted as a number (floating point
  or integer)
* ``i"value"`` : forces ``value`` to be interpreted as an integer (whole number)
* ``b"value"`` : forces ``value`` to be interpreted as a boolean (true or
  false) value. The code recognises ``true/false``, ``on/off`` and ``yes/no``,
  as well as ``1/0`` (all case-insensitive).
* ``s"value"`` : forces ``values`` to be a string. Use this if you really want
  a string or want to interpret the value yourself in your plugin code.

Examples
--------

::

  beta[1]  beta[2]  beta[3]
    0.5      0.5      0.5
    0.6      0.7      0.8

Two sets of variables, setting ``beta[1]``, ``beta[2]`` and ``beta[3]`` to
``0.5`` in the first set, and ``0.6``, ``0.7`` and ``0.8`` in the second
set.

::

   beta["I1"]  beta["I2"]  beta["I3"]
   # initial baseline
     0.5        0.5        0.5

   # increasing infectivitiy
     0.6        0.7        0.8

Same, except using the names of the disease stages and adding comments
and extra whitespace to aid legibility.

::

   .lockdown_start    .scale_rate   repeats   output
    d"March 15 2020"      0.2         5       lockdown_march
    d"April 1 2020"       0.1         3       lockdown_april

Setting the user parameters ``lockdown_start`` and ``scale_rate``
to either March 15th 2020 / 0.2 or April 1st 2020 / 0.1. Asking for
5 repeats of the March 15 data, outputting the results to directories
called ``lockdown_march``, and 3 repeats of the April lockdown,
outputting the data to ``lockdown_april``.

.. note::

   The first repeats will be written to ``lockdown_march`` and
   ``lockdown_april``, while the remainder will be written to
   numbered directories, e.g. ``lockdown_marchx002`` etc.

::

   beta[2], beta[3], progress[1], progress[2], progress[3]
    0.95,   0.95,     0.19,        0.91,         0.91
    0.90,   0.93,     0.18,        0.92,         0.90

Named columns, using comma separators, and adding extra spaces for
improved legibility.
