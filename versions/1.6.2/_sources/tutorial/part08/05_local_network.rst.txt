================================
Specifying ward-local parameters
================================

In :doc:`part 3 <../part03/08_local_lockdown>` you learned how to read
and write ward-local parameters, e.g.
:meth:`network.nodes.scale_uv <metawards.Nodes.scale_uv>` and
:meth:`network.nodes.cutoff <metawards.Nodes.cutoff>`.

You can also set these parameters (and custom parameters) using
the :class:`~metawards.Ward` object.

For example, in Python;

.. code-block:: python

   >>> from metawards import Ward
   >>> bristol = Ward(name="bristol")
   >>> bristol.set_position(lat=51.4545, long=2.5879)
   >>> bristol.set_cutoff(15.0)
   >>> bristol.set_scale_uv(0.5)
   >>> bristol.set_custom("in_lockdown", 0.0)
   >>> bristol.set_custom("case_free_days", 21)
   >>> print(bristol.to_json(indent=2))
   {
     "id": null,
     "position": {
       "lat": 51.4545,
       "long": 2.5879
     },
     "info": {
       "name": "Bristol"
     },
     "num_workers": 0,
     "num_players": 0,
     "scale_uv": 0.5,
     "cutoff": 15.0,
     "custom": {
       "in_lockdown": 0.0,
       "case_free_days": 21.0
     }
   }

or in R

.. code-block:: R

   > library(metawards)
   > bristol <- metawards$Ward(name="bristol")
   > bristol$set_position(lat=51.4545, long=2.5879)
   > bristol$set_cutoff(15.0)
   > bristol$set_scale_uv(0.5)
   > bristol$set_custom("in_lockdown", 0.0)
   > bristol$set_custom("case_free_days", 21)
   > print(bristol$to_json(indent=2))
   {
     "id": null,
     "position": {
       "lat": 51.4545,
       "long": 2.5879
     },
     "info": {
       "name": "Bristol"
     },
     "num_workers": 0,
     "num_players": 0,
     "scale_uv": 0.5,
     "cutoff": 15.0,
     "custom": {
       "in_lockdown": 0.0,
       "case_free_days": 21.0
     }
   }

would create a ward called ``bristol``. The position of the centre of the
ward is set to a specified latitude and longitude. The ``cutoff`` distance
is set to 15 kilometers, and the ``scale_uv`` parameter is set to 0.5.
Two custom parameters are added; ``in_lockdown`` which is set to 0 and
``case_free_days`` which is set to 21.

.. note::

   You can set the position of a ward using either X/Y coordinates
   (which should be in kilometers) or latitude / longitude. All wards
   in a single network should use the same coordinates scheme.

.. note::

   You can add as many custom parameters as you like. They will all be
   stored as (double precision) floating point numbers. This means
   that ``True`` will be converted to ``1.0`` and ``42`` will be
   converted to ``42.0``.

Networks with ward-local parameters
-----------------------------------

You can combine individual ward objects together into a single Wards
object, even if they have different ward-local parameters. For example,
continue the above scripts to add a ward called ``london``, e.g. in
Python;

.. code-block:: python

   >>> london = Ward(name="london")
   >>> london.set_position(lat=51.5074, long= 0.1278)
   >>> london.set_custom("in_lockdown", 1)
   >>> bristol.add_workers(50, destination=london)
   >>> wards = bristol + london

You can now convert this into a :class:`metawards.Network`. We can then
read the parameters using the :class:`network.nodes <metawards.Nodes>`
object, as we did in :doc:`part 3 <../part03/08_local_lockdown>`.

.. code-block:: python

   >>> from metawards import Network
   >>> network = Network.from_wards(wards)
   Calculating distances...
   Total links distance equals 273.9213284848716
   Total play distance equals 0.0
   Total distance equals 273.9213284848716
   Network loaded. Population: 50, Workers: 50, Players: 0
   >>> print(network.nodes.x)
   array('d', [0.0, 51.4545, 51.5074])
   >>> print(network.nodes.y)
   array('d', [0.0, 2.5879, 0.1278])
   >>> print(network.nodes.scale_uv)
   array('d', [1.0, 0.5, 1.0])
   >>> print(network.nodes.cutoff)
   array('d', [99999.99, 15.0, 99999.99])
   >>> print(network.nodes.get_custom("in_lockdown"))
   array('d', [0.0, 0.0, 1.0])
   >>> print(network.nodes.get_custom("case_free_days"))
   array('d', [0.0, 21.0, 0.0])

The data has been correctly set (remembering that there is no ward at
index 0). Note that if ``scale_uv`` is not set, then it defaults to ``1.0``.
Similarly, if ``cutoff`` is not set then it defaults to a large distance
that is greater than the distance between two points on Earth (``99999.99``).
Custom parameters are defaulted to ``0.0`` if they are not set, e.g.
note how ``case_free_days`` for ``london`` is ``0.0``.

The same code in R would read;

.. code-block:: R

   > london <- metawards$Ward(name="london")
   > london$set_position(lat=51.5074, long= 0.1278)
   > london$set_custom("in_lockdown", 1)
   > bristol$add_workers(50, destination=london)
   > wards <- metawards$Wards()
   > wards$add(bristol)
   > wards$add(london)
   > network <- metawards$Network$from_wards(wards)
   Calculating distances...
   Total links distance equals 273.9213284848716
   Total play distance equals 0.0
   Total distance equals 273.9213284848716
   Network loaded. Population: 50, Workers: 50, Players: 0
   > print(network$nodes$x)
   array('d', [0.0, 51.4545, 51.5074])
   > print(network$nodes$y)
   array('d', [0.0, 2.5879, 0.1278])
   > print(network$nodes$scale_uv)
   array('d', [1.0, 0.5, 1.0])
   > print(network$nodes$cutoff)
   array('d', [99999.99, 15.0, 99999.99])
   > print(network$nodes$get_custom("in_lockdown"))
   array('d', [0.0, 0.0, 1.0])
   > print(network$nodes$get_custom("case_free_days"))
   array('d', [0.0, 21.0, 0.0])
