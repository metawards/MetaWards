=====================
Where is the weekend?
=====================

It may not have escaped your attention that every day is a work day
in this model. While this may seem unrealistic, we must remember that
these are random, imperfect models, based on very noisy data.
Adding more "realism" may be counter-productive, especially as
modern working patterns mean that there is blurring of the line between
work days and weekends.

This doesn't mean that we can't model a weekend. Indeed, ``metawards``
is really flexible and you can customise exactly what is performed
for each model day.

Creating the weekend
--------------------

Create a new directory called ``weekend`` and copy into it your
``lurgy3.json`` disease parameters. Change into this directory and
create a new file called ``weekend.py``, and copy into it the below
code.

.. code-block:: python

    from metawards.utils import Console

    def iterate_weekend(**kwargs):
        Console.print("Hello iterate_weekend")

        return []

This is a simple function called ``iterate_weekend``. It takes an
unspecified number of
`keyword arguments (**kwargs) <https://book.pythontips.com/en/latest/args_and_kwargs.html>`__
(more about these later). It returns an empty list (``[]``). All it does
is print ``Hello iterate_weekend`` to the screen.

.. note::
   Notice that you *must* print using the
   :meth:`Console.print <metawards.utils.Console.print>` function of
   :meth:`~metawards.utils.Console`. This ensures that all printing
   goes to the right place and stays sane when multiple processes
   and threads all try to print at the same time. It also ensures
   that everything that is printed to the screen also gets printed
   to a file for safekeeping (``output/console.log.bz2``). It is
   very important that information is not lost when running a job.

You can run this function by starting ``ipython`` in this directory
and typing;

.. code-block:: ipython

   In [1]: import weekend
   In [2]: weekend.iterate_weekend()
   Hello iterate_weekend
   Out[2]: []

You can tell ``metawards`` to call this function every iteration
using the ``--iterator`` command-line argument. Type;

.. code-block:: bash

   metawards metawards -d lurgy3 --additional ExtraSeedsLondon.dat --iterator weekend

You should see a very different outbreak to what you have before, e.g.

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    seeding play_infections[0][255] += 5
    S: 56082072  E: 5  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 4  I: 1  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 2  I: 3  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 5

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 2  I: 2  R: 1  IW: 0  POPULATION: 56082077
    Number of infections: 4

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 5 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 1  I: 2  R: 2  IW: 0  POPULATION: 56082077
    Number of infections: 3

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 6 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 0  I: 2  R: 3  IW: 0  POPULATION: 56082077
    Number of infections: 2

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 7 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 0  I: 1  R: 4  IW: 0  POPULATION: 56082077
    Number of infections: 1

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 8 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Hello iterate_weekend
    S: 56082072  E: 0  I: 0  R: 5  IW: 0  POPULATION: 56082077
    Number of infections: 0
    Infection died ... Ending on day 9

What happened here? Well, just as you imported ``weekend`` into ``ipython``
and called the ``iterate_weekend`` function, so too has ``metawards``.
The ``--integrator`` option tells ``metawards`` to import the ``weekend``
module. ``metawards`` then automatically found the first function in that
module whose name started with ``iterate``, in this case ``iterate_weekend``.

Then, ``metawards`` called this function for every iteration of the
**model run**.

You can name your function whatever you want, e.g. edit ``weekend.py``
to read;

.. code-block:: python

  from metawards.utils import Console

  def another_function(**kwargs):
      Console.print("Hello another_function")

      return []


  def iterate_weekend(**kwargs):
      Console.print("Hello iterate_weekend")

      return []

This has added another function called ``another_function``. You can tell
``metawards`` to use this function using
``--iterator weekend::another_function``. Try running this using the
command below;

.. code-block:: bash

  metawards -d lurgy3 --additional ExtraSeedsLondon.dat --iterator weekend::another_function

You should see ``Hello another_function`` is now printed for
every iteration.

.. warning::
   Sometimes you may see ``metawards`` exit with a warning that it can't
   find your iterator function. This is likely because there is a typo
   or syntax error in your iterator. ``metawards`` does its best to
   detect these and report them to you, so check above the error in the
   output to see if there is anything helpful. If not, then run your
   iterator in python to see if you get any errors, e.g. if your iterator
   is in a file called ``iterator.py`` then type ``python iterator.py``.
   If there is an error, then that will be printed to the screen.

Printing debug output
---------------------

In general, you should only print things to the screen if they will be useful
for the user of the program. Sometimes when developing you want to print
some debugging output that can verify that everything is working. To do this,
using :meth:`Console.debug <metawards.utils.Console.debug>`. For example,
change your iterator to;

.. code-block:: python

    from metawards.utils import Console

    def iterate_weekend(**kwargs):
        Console.debug("Hello iterate_weekend")

        return []

Now, you will only see this print output if the ``--debug`` option is passed
to ``metawards``, e.g.

.. code-block:: bash

    metawards -d lurgy2 --iterator weekend --debug

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [15:23:08]                       Hello iterate_weekend                       weekend.py:5
    S: 56082077  E: 0  I: 0  R: 0  IW: 0  POPULATION: 56082077
    Number of infections: 0

Note that the time of the debug string, and the line and file of the debug
statement are included. You can also easily print the values of variables
using the ``variables`` keyword argument to
:meth:`~metawards.utils.Console.debug`, e.g.

.. code-block:: python

    from metawards.utils import Console

    def iterate_weekend(**kwargs):
        a = 42
        b = "This is a string"

        Console.debug("Hello iterate_weekend", variables=[a, b])

        return []

.. code-block:: bash

    metawards -d lurgy2 --iterator weekend --debug

::

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Day 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [15:25:38]                       Hello iterate_weekend                       weekend.py:8

     Name │ Value
    ══════╪══════════════════
        a │ 42
        b │ This is a string

More information about debug strings, debugging levels, and how you can leave
these debug strings in production code is
:doc:`available here <../../devsupport>`.

Advancing the outbreak
----------------------

You may have noticed that the disease outbreak was not advancing during
any of the runs using your custom weekend iterator. The output showed
that five initial infections were seeded. These progressed through
the disease stages until all five individuals moved into the **R**
state.

The reason the disease hasn't advanced is because you haven't supplied
any functions that are used to advance the outbreak. The job of
the iterator function is to return the functions that are needed to
advance an outbreak (so-called ``advance functions``).

You can write an advance function by editing ``weekend.py`` to contain;

.. code-block:: python

  from metawards.iterators import advance_infprob, advance_play
  from metawards.utils import Console

  def iterate_weekend(**kwargs):
      Console.debug("Hello iterate_weekend")

      return [advance_infprob, advance_play]

In this code you have imported the :meth:`~metawards.iterators.advance_infprob`
and :meth:`~metawards.iterators.advance_play` advance functions.
These were described on the :doc:`last page <01_iterators>`. By returning
them from ``iterate_weekend`` you have told ``metawards`` to call them,
one after another, to advance the outbreak. If you now run
``metawards`` using this new ``weekend.py`` via;

.. code-block:: bash

   metawards -d lurgy3 --additional ExtraSeedsLondon.dat --iterator weekend

you will see that the outbreak now advances throughout the population.
However, each day now only progresses new infections using the "play" mode
:meth:`~metawards.iterators.advance_play`. The "work" mode
:meth:`~metawards.iterators.advance_fixed`, is not used, meaning
that every day is now modelled as like a weekend.

Create an overview graph of your "weekend only" run and compare it to
the results from the "weekday only" runs in
:doc:`part 2 <../part02/05_refining>`. Do you see a difference?

My graph is shown below;

.. image:: ../../images/tutorial_3_2_1_overview.jpg
   :alt: Overview image of a weekend only run

It is clear that the outbreak is now much smaller, peaking at 7 million
as opposed to nearly 20 million. The peak is also broadened
out, with the outbreak lasting months rather than weeks.

Changing iterators with time
----------------------------

A week of only weekends is also not realistic. We can however create
a function that can choose which advance functions to return based
on the day of the outbreak.

To do this, create a new python file called ``week.py`` and copy into
it the code below;

.. code-block:: python

  from metawards.iterators import advance_infprob, \
                                  advance_fixed, \
                                  advance_play
  from metawards.utils import Console


  def iterate_week(population, **kwargs):
      date = population.date

      Console.debug(f"Creating functions for {date}")

      if date.weekday() < 5:
          Console.debug("This is a weekday")
          return [advance_infprob,
                  advance_fixed,
                  advance_play]
      else:
          Console.debug("This is a weekend")
          return [advance_infprob,
                  advance_play]

This has created an ``iterate_week`` function. This has a slightly
different signature to ``iterate_weekend``, in that it accepts
the ``population`` argument. Every iterator is passed a lot of
arguments, most of which are ignored by the ``**kwarg`` variables.

When you need an argument you name it in the function. In this case,
we need the ``population`` argument. This is a
:class:`~metawards.Population` object, which contains the distribution
of the population across the different **S**, **E**, **I** states,
plus the current date of the outbreak (
:meth:`Population.date <~metawards.Population.date>`).

The ``date`` is a standard `Python date object <https://docs.python.org/3/library/datetime.html>`__.
The ``.weekday()`` function returns a number from 0-6 to correspond
with Monday to Sunday (0 is Monday, 6 is Sunday).

If the weekday is less than 5, then the day must be a weekday. Hence
the ``iterate_week`` function returns the infprob, fixed and play
advance functions. Otherwise, the day must be a weekend, and so
only the infprob and play advance functions are returned.

Run ``metawards`` using this new iterator and see what happens;

.. code-block:: bash

  metawards -d lurgy3 --additional ExtraSeedsLondon.dat --iterator week
  metawards-plot -i output/results.csv.bz2 --format jpg --dpi 150

You should see something similar to this;

.. image:: ../../images/tutorial_3_2_2_overview.jpg
   :alt: Overview image of a weekend only run

There is a significant spread in the infection during weekdays,
but then this growth falls back at weekends.

.. note::
  This "week" iterator is so important that it is supplied
  as the :meth:`metawards.iterators.iterate_working_week`
  iterator. You can use this via the command line option
  ``--iterator iterate_working_week``. Similarly there
  is :meth:`metawards.iterators.iterate_weekday` function
  to iterate as a weekday only, and
  :meth:`metawards.iterators.iterate_weekend` to iterate
  as weekends only.

.. note::
  By default the outbreak is modelled to start from today.
  You can control the start date using the ``--start-date``
  command line option.
