=========
Snag list
=========

Below is a series of snags with the code that we'd like to fix, but
currently lack the personpower to tackle now. If you'd like to
try and fix one of the below then get in touch with us by
`raising an issue <https://github.com/metawards/MetaWards/issues>`__,
or forking the repo and issuing a pull request when you are done.

Ideally let us know so that we can create a feature branch for your
work, so that no-one else duplicates your effort.

Snags
-----

* [feature_improve_rng] - Random number generator is potentially quite slow

We are using the numpy random number generator in single threaded,
not-vectorised mode. There is a lot of scope for speed-up, so someone
who wants to take a look would be very welcome (and appreciated).

* [feature_multinomial] - Replace ran_binomial loop in advance_foi

We think that a ran_multinomial call can replace the slow and multiple
calls to ran_binomial in advance_foi. If the maths works out, then
this should be significantly quicker.

* [feature_bigtests] - Create a larger test suite full of examples

We'd like to create a repo full of examples of MetaWards runs, which can
serve as both a learning resource and also a fuller suite of regression
and integration tests. The aim would for pushes to this repo to trigger
runs of metawards against a lot of examples. This should be a separate
repo to the main code as the examples will take up a lot of space.

