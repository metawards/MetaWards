=============================================
Different networks for different demographics
=============================================

Custom networks significantly increase the flexibility of ``metawards``.
You can use them to create models for different countries. And you can
use them to use the concept of metapopulations to model different
environments.

For example, we can use a custom network to model ``home``, ``school``
and ``work``, and then use different demographics to model
students, teachers and everyone else. This way
you could explore how closing schools could impact disease spread.

This concept is explored in detail in the
:doc:`quick start guide <../../quickstart/index>`. The key takeaway you should
have now, having worked through this
:doc:`tutorial <../index>` as well as the
:doc:`quick start <../../quickstart/index>`, is that you can create;

* different :class:`~metawards.Disease` objects that contain different
  disease stages and parameters,
* different :class:`~metawards.Demographic` objects that represent
  different groups of individuals, each of which can experience
  different :class:`~metawards.Disease` objects (and thus advance
  along different pathways,
* who can each experience metapopulation movements on different
  :class:`~metawards.Network` networks (built flexibly via the
  :class:`~metawards.Ward` / :class:`~metawards.Wards` objects),
* where each ward in each network can have its own parameters, thereby
  enabling modelling of ward-local behaviour for different demographics at
  different disease stages in different networks.

This flexibility for the model is then enhanced by building custom
:mod:`~metawards.iterators` that enable you to write your own code
to advance individuals from one disease stage to the next, and control
how susceptible individuals are infected.

You can build custom :mod:`~metawards.mixers` to control how the force
of infections calculated for different demographics are mixed and merged
together, thereby controlling how they interact (from not interacting,
to evenly interacting, via custom interactions for the interaction matrix).

You can build custom :mod:`~metawards.movers` to control vertical
movements of individuals between demographics, that complement the
horizontal movement of individuals along disease stages.

And you can write custom :mod:`~metawards.extractors` to analyse the
data from the simulation on the fly, and write whatever data you wish
out to disk or database.

And, from here you can creata custom user parameters that control all
of this model, and write scan/design files that can run multiple
simulations to scan through these custom parameters, as well as
(nearly) all in-built and disease parameters, optionally repeating
runs to check for statistical variance.

And (finally!) you can do all of this from within a single Python or R
script using the Python or R APIs, or you can run from the command line,
or from within a batch script that will automatically parallelise
the runs over a supercomputing cluster.
