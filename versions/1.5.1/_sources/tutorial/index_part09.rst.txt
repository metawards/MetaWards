=====================================
Part 9 - Advanced Moves and Scenarios
=====================================

In this ninth part of the tutorial you will;

* Discover :class:`~metawards.movers.MoveGenerator` and
  :func:`~metawards.movers.go_ward`, and learn how this can be
  used to get full control to define very intricate movements
  of individuals.
* Use :meth:`Disease.is_infected <metawards.Disease.is_infected>` to
  create the non-infected Vaccinated (V) stage, and use
  :func:`~metawards.movers.go_ward` to model vaccination, both nationally
  and on a ward-by-ward basis.
* Use :class:`~metawards.movers.MoveGenerator` to create advanced moves
  that model individuals losing immunity due to vaccination or
  recovery after a period of time.
* Use :class:`~metawards.movers.MoveGenerator` to model movement of
  individuals from their home to their university ward at the start
  of the university year. This can include movements between
  workers and players.
* Use :meth:`Ward.bg_foi <metawards.Ward.bg_foi>` to set a background
  force of infection in wards, and use this to model hyperthetical
  foreign holiday destinations with different background rates of
  infection. Use :func:`~metawards.movers.go_ward` to model individuals
  going on holiday to these destinations, and the effect of different
  numbers of days of quarantine on return.

.. toctree::
   :maxdepth: 2

   part09/01_move_ward
   part09/02_vaccinate
   part09/03_fading_immunity
   part09/04_university
   part09/05_holidays
