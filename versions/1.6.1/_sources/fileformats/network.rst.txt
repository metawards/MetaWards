=============
Network Files
=============

Network files are those that define the nodes (wards) of the network,
and the links (communiting/movement) of individuals between nodes.

The Network files are a collection of files that must all exist in the
same directory. They comprise;

* ``description.json``: This file must exist in the directory, and provides
  the metadata needed to locate all of the other necessary files.
* ``work_size / play_size``: These files list the index and population of
   workers (in ``work_size``) and players (in ``play_size``) in
   each ward in the network. The total population in each ward (node) is
   the sum of the work and play populations.
* ``work``: This file lists all of the work connections between nodes, giving
  the population of workers who commute from the source node to the
  destination.
* ``play``: This file lists all of the play connections between nodes, giving
  the **proportion** of players who make random movements from the source
  node to the destination node.
* ``position``: This file contains the coordinates of the centre of each node.
  These coordinates can be X/Y or latitude/longitude coordinates.
* ``lookup``: This file contains the names and other metadata about each
  node, e.g. the name, local authority, region etc.

These files are all described below.

description.json
----------------

This is a JSON-formatted file that provides metadata about the network model
that is contained in the directory. The file describes a simple dictionary
of the following key-value pairs;

* ``work``: Filename of the ``work`` file.
* ``work_size``: Filename of the ``work_size`` file.
* ``play``: Filename of the ``play`` file.
* ``play_size``: Filename of the ``play_size`` file.
* ``position``: Filename of the ``position`` file.
* ``coordinates``: Whether the coordinates in the ``position`` file are
  in x/y (``x/y``) or latitude/longitude (``lat/long``) format.
* ``coordinate_units``: (Optional) - the units for x/y coordinates. This should
  be either ``m`` for meters, or ``km`` for kilometers. Distances in
  ``metawards`` are always reported as kilometers.
* ``lookup``: (Optional) Filename of the ``lookup`` file.
* ``lookup_columns``: (Optional) A dictionary that gives the column numbers
  (zero-indexed)for the ``code``, ``name``, ``alternate_code``,
  ``alternate_name``, ``authority_code`` and ``authority_name`` fields for
  the ward metadata.

work
----

The ``work`` file contains the list of all work connections between nodes,
giving the number of individuals who commute from the source node to the
destination node. This is a column-based file with three columns of numbers
that can be space or comma separated. For example;

::

    1 1 290
    1 2 3
    1 5 139
    1 6 59
    1 7 17
    1 8 119
    1 9 37
    1 10 121

The first number is the (1-indexed) index of the source node, while the
second number is the (1-indexed) index of the destination node. The
third number is the number of individuals who commute from the source
to the destination node.

In this example, this lists workers who commute from ward 1 to wards
1 to 10. 290 workers commute from ward 1 to ward 1 (so work in the same
ward in which they live). 3 workers commute from ward 1 to ward 2,
139 commute from ward 1 to ward 5 etc.

.. note::

   All of the source wards have to be listed contiguously, i.e.
   you must list all of the connections where the source ward is
   equal to ``1`` before you list all of the connections where the
   source ward is equal to ``2`` etc.

work_size
---------

The ``work_size`` file contains the number of workers who reside in each ward.
This is a column-based file with two columns of numbers that can be space or
comma separated. For example;

::

    1 6800
    2 1091
    3 7148
    4 5684
    5 7226
    6 6561
    7 6904
    8 7213
    9 6715
    10 7452

The first number is the (1-indexed) index of the ward, while the second
is the number of workers in that ward. The number of workers in a ward must
equal the sum of the number of workers from the ``work`` file that say
that they commute from that ward.

In this example, ward 1 has 6800 workers, ward 2 has 1091 workers etc.

play
----

The ``play`` file contains the list of play connections between wards.
This is a column-based file with three columns of numbers that can be
space or comma separated. For example;

::

    1 1 0.0426470588235294
    1 2 0.000441176470588235
    1 5 0.0204411764705882
    1 6 0.00867647058823529
    1 7 0.0025
    1 8 0.0175
    1 9 0.00544117647058823
    1 10 0.0177941176470588

The first number is the (1-indexed) index of the source ward, while the
second is the (1-indexed) index of the destination ward. The third number
is the fraction of players who will randomly travel from the source
ward to the destination ward.

In this case, ``0.0426...`` of players will remain in ward 1, while
``0.00044...`` of players will randomly move from ward 1 to ward 2.

.. note::

   Be careful as the third number is a fraction (floating point number
   between 0 and 1) and not the number of players that move. Also note
   that the same ordering requirements as for the ``work`` file apply,
   namely that all connections for source ward 1 have to be listed before
   all connections for source ward 2 etc.

play_size
---------

The ``play_size`` file contains the number of players in each ward.
This is a column-based file with two columns of numbers that can be
space or comma separated. For example:

::

    1 8915
    2 374
    3 7012
    4 10579
    5 8703
    6 12257
    7 10533
    8 11259
    9 8592
    10 10999

The first number is the (1-indexed) index of the ward, while the second
is the number of players in that ward. In this case, there are 8915
players in ward 1, 374 players in ward 2 etc.

position
--------

The ``position`` file contains the coordinates of the center of each ward.
This is a column-based file with three columns of numbers that can be
space or comma separated. For example:

::

    1 524693.890435782 190136.324582048
    2 532169.852194767 181663.72329877
    3 522106.698233411 179737.792519091
    4 533388.404693453 193451.026467071
    5 525973.729674732 188464.548078951
    6 523953.505171282 187729.710513154
    7 520763.019103366 193360.422742775
    8 523100.570665414 189524.60815157
    9 523747.496973864 196638.656771657
    10 523019.549069799 192050.596775831

The coordinates are either x/y or latitude/longitude, depending on what
is set in the ``description.json`` file. If x/y, then the units are also
set in this file.

In this case, this is for x/y coordinates in meters. The first column
is the (1-indexed) index of the ward. The second column is the X coordinate,
while the third is the Y coordinate.

.. note::

  If lat/long was used, then the second column would be the latitude, and
  the third column the longitude.

So ward 1 has its center are (524.7km, 190.1km), while ward 2 has its center
at (532.1km, 181.7km) etc.

lookup
------

The ``lookup`` file contains metadata information about a ward that allows
it to be looked up by name, region etc. This is a column-based file with
a header row, and columns separated by spaces or commas. For example:

::

    WD11CD,WD11NM,WD11NMW,CMWD11CD,CMWD11NM,CMWD11NMW,IND,LAD11CD,LAD11NM,LAD11NMW,FID
    E05002337,Central,,E36000890,Central,,0,E06000039,Slough,,2001
    E05002338,Chalvey,,E36000891,Chalvey,,0,E06000039,Slough,,2002
    E05002339,Cippenham Green,,E36000892,Cippenham Green,,0,E06000039,Slough,,2003
    E05002340,Cippenham Meadows,,E36000893,Cippenham Meadows,,0,E06000039,Slough,,2004
    E05002341,Colnbrook with Poyle,,E36000894,Colnbrook with Poyle,,0,E06000039,Slough,,2005
    E05002342,Farnham,,E36000895,Farnham,,0,E06000039,Slough,,2006
    E05002343,Foxborough,,E36000896,Foxborough,,0,E06000039,Slough,,2007
    E05002344,Haymill,,E36000897,Haymill,,0,E06000039,Slough,,2008
    E05002345,Kedermister,,E36000898,Kedermister,,0,E06000039,Slough,,2009
    E05002346,Langley St Mary's,,E36000899,Langley St Mary's,,0,E06000039,Slough,,2010

The first row provides the names of each of the columns. These are ignored
by the code. Each row gives the information for the ward whose index is equal
to the line number (so line 1 give the information for ward at index 1).

The ``lookup_columns`` field in ``description.json`` specifies which columns
from this file to use for the name, code, authority etc. for each ward.
For example, this has set column 0 for the code, column 1 for the name,
and so the first ward has code ``E05002337`` and name ``Central``.
