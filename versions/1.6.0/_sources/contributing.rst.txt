============
Contributing
============

We welcome all helpful contributions to improving the quality of
MetaWards. Ways you can help include;

* Finding and fixing documentation bugs and typos
* Creating more tests and adding them to the pytest library in the
  ``tests`` directory
* Taking on some of the tasks in the :doc:`snaglist`.
* Porting and testing MetaWards on different computers
* Writing new features

We accept pull requests to the devel branch and are happy to discuss
ideas via
`GitHub issues on the repo <https://github.com/metawards/MetaWards/issues>`__.

When contributing, please keep in mind our
`code of conduct <https://github.com/metawards/MetaWards/blob/devel/CODE_OF_CONDUCT.md>`__.

Before contributing we encourage everyone to
:doc:`complete the tutorial <tutorial/index>`, as this gives a good
grounding in how the model works and how the code is laid out. If you have
any problems running the tutorial then please
`raise and issue <https://github.com/metawards/MetaWards/issues>`__.

Contributing new code
---------------------

We welcome developers who want to join us to help reduce bugs and add
new functionality. Please bear in mind the following;

* We use `semantic versioning <https://semver.org>`__ and take care
  not to cause breaking changes in the public API. The public API
  consists of the core :mod:`metawards` module only - it does not
  cover :mod:`metawards.utils` or any plugins that are in
  :mod:`metawards.iterators`, :mod:`metawards.extractors`,
  :mod:`metawards.mixers` or :mod:`metawards.movers` (although,
  the core plugin interface API will not change). We will
  endeavour to retain backwards compatibility outside of
  the core :mod:`metawards` module, but cannot guarantee it.

* The core :mod:`metawards` module and data structures are now
  quite fixed, and we endeavour not to make large or breaking changes.
  This means that new functionality should ideally be added via
  one of the pluging interfaces, e.g.
  :doc:`iterators <api/index_MetaWards_iterators>`,
  :doc:`extractors <api/index_MetaWards_extractors>`,
  :doc:`mixers <api/index_MetaWards_mixers>` and
  :doc:`movers <api/index_MetaWards_movers>`. If you can't fit your code
  into a plugin then please
  `raise an issue <https://github.com/metawards/MetaWards/issues>`__
  to discuss your idea with the core developers, so that a way
  forward can be found. We really appreciate your help, and want
  to make sure that your ideas can be included in the most compatible
  way in the code.

We've :doc:`added features <devsupport>` to ``metawards`` that we hope
will make it easier to develop new code. This includes tools to make
simplify profiling and "printf" debugging, and full pytest integration.
Please feel free to
`raise an issue <https://github.com/metawards/MetaWards/issues>`__ if there
is something else you think would help make development easier.

Finally, we have a :doc:`very detailed developer guide <development>` that
we hope will help you get up to speed with development. We strive to
be a helpful, friendly and welcoming community, so if you have any
questions or anything is not clear then please get in touch with
us by `raising an issue <https://github.com/metawards/MetaWards/issues>`__.
