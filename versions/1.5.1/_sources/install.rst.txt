=========================
Installation instructions
=========================

MetaWards is a Python package, but it does come with R wrappers. This
means that you can choose to install MetaWards either via Python or
via R.

Installation via Python
=======================

MetaWards is compiled and
`tested on Windows, Linux and OS X <https://github.com/metawards/MetaWards/actions>`__,
but should be able to compile and install on any operating system
with a working Python >= 3.7 and a C compiler.

To install MetaWards, you first need to install Python >= 3.7. To check
if you have Python 3.7 installed type;

.. code-block:: bash

    python -V

This should print out the version number of the Python you have available.
If the version number is ``2.???`` then you have a very old Python 2. If
this is the case, try;

.. code-block:: bash

    python3 -V

and see if you have a Python 3 that has a version number >= 3.7. If so,
please use ``python3`` instead of ``python``.

If you don't have Python >=3.7 installed, then you can install Python
either via your package manager, or more simply, by using
`anaconda <https://anaconda.org>`__.

Once you have a working Python >= 3.7, the easiest way to install
MetaWards is using
`pip <https://pip.pypa.io/en/stable/>`__.

.. code-block:: bash

    pip install metawards

(if this doesn't work, then you may need to use the command ``pip3``,
or you may have to `install pip <https://pip.pypa.io/en/stable/installing/>`__.
If you have trouble installing pip then we recommend that you download
and install `anaconda <https://anaconda.org>`__, which has pip included)

To install a specific version, e.g. 1.4.0, type

.. code-block:: bash

    pip install metawards==1.4.0

This will install a binary version of metawards if it is avaiable for your
operating system / processor / version of python. If not, then
the metawards pyx code that was compiled into C using
`cython <https://cython.org>`__,
will be compiled into an executable using your system C compiler
(e.g. `gcc <https://gcc.gnu.org>`__ or `clang <https://clang.llvm.org>`__).
You can control which C compiler to use by setting the ``CC`` environment
variable, e.g.

.. code-block:: bash

    CC=gcc pip install metawards

MetaWards is written in standard C, using
`OpenMP <https://www.openmp.org>`__ for parallelisation,
and it has no external dependencies, so
it should compile without issue. Note that the system C compiler on
OS X (Mac) does not support OpenMP. In this case you the code will
compile with OpenMP disabled. If you want to use all of the cores
of your computer than you will need to install
a different compiler, e.g. installing clang via
`homebrew <https://brew.sh>`__. If you have any problems then please
`post an issue on GitHub <https://github.com/metawards/MetaWards/issues>`__.

Installation via R
==================

MetaWards can be used within R via the `reticulate <https://rstudio.github.io/reticulate/>`_
package. We have built a MetaWards R package that simplifies this use.

First, open R or RStudio and install the MetaWards R package from GitHub;

.. code-block:: R

   > library(devtools)
   > install_github("metawards/rpkg")

Next, load the ``metawards`` package and use the ``py_install_metawards``
function to install metawards into the Python that is supplied
with reticulate.

.. code-block:: R

   > metawards::py_install_metawards()

This may take a few minutes. If it works, then you can check that
metawards is available by calling the ``py_metawards_available`` function,
e.g.

.. code-block:: R

   > metawards::py_metawards_available()
   [1] TRUE

.. note::

   If you want to use a different Python environment, then this can be
   set using ``reticulate::use_python("/path/to/python", required = TRUE)``
   before you call any of the metawards functions.

This will install the latest version of metawards. You can check if there
are any updates available via;

.. code-block:: R

   > metawards::py_metawards_update_available()

and you can update to the lastest version using;

.. code-block:: R

   > metawards::py_update_metawards()

Source install
==============

You can download a source release of MetaWards from the
`project release page <https://github.com/metawards/MetaWards/releases>`__.

Once you have downloaded the file you can unpack it and change into
that directory using;

.. code-block:: bash

   tar -zxvf MetaWards-X.Y.Z.tar.gz
   cd MetaWards-X.Y.Z

where ``X.Y.Z`` is the version you downloaded. For the 1.4.0 release
this would be;

.. code-block:: bash

    tar -zxvf MetaWards-1.4.0.tar.gz
    cd MetaWards-X.Y.Z

Next you need to install the dependencies of MetaWards. Do this by typing;

.. code-block:: bash

    pip install -r requirements.txt

Now you are ready to compile and install MetaWards itself;

.. code-block:: bash

    make
    make install

You can choose the C compiler to use by setting the ``CC`` environment
variable, e.g.

.. code-block:: bash

    CC=clang make
    CC=clang make install

MetaWards is written in standard C, using
`OpenMP <https://www.openmp.org>`__ for parallelisation,
and it has no external dependencies, so
it should compile without issue. Note that the system C compiler on
OS X (Mac) does not support OpenMP. In this case you the code will
compile with OpenMP disabled. If you want to use all of the cores
of your computer than you will need to install
a different compiler, e.g. installing clang via
`homebrew <https://brew.sh>`__. If you have any problems then please
`post an issue on GitHub <https://github.com/metawards/MetaWards/issues>`__.

For developers
==============

You can clone the MetaWards repository to your computer and install from
there;

.. code-block:: bash

    git clone https://github.com/metawards/MetaWards
    cd MetaWards
    pip install -r requirements-dev.txt

From this point you can compile as if you have downloaded from source.
As a developer you may want to run the tests and create the website.
To do this type;

.. code-block:: bash

    pytest tests
    make doc

There are shortcuts for running the quick or slow tests, e.g.

.. code-block:: bash

   make test
   make quicktest

Note that the tests assume that you have already downloaded the
model data from `MetaWardsData <https://github.com/metawards/MetaWardsData>`__
and configured this as `described here <model_data.html>`__.
