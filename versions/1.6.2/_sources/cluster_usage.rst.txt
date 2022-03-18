====================
Running on a cluster
====================

One of the reasons for this Python port is to make it easier to run
MetaWards analyses at scale on a HPC cluster. MetaWards supports
parallelisation using MPI (via `mpi4py <https://mpi4py.readthedocs.io>`__)
or simple networking (via `scoop <https://scoop.readthedocs.io>`__).

MetaWards will automatically detect most of what it needs so that you
don't need to write a complicated HPC job script.

MetaWards will look for a ``hostfile`` via either the PBS environment
variable of ``PBS_NODEFILE``, or the slurm ``SLURM_HOSTFILE``, or
for a ``hostfile`` passed directly via the ``--hostfile`` command
line argument.

It will then use the information combined there, together with the number of
threads per model run requested by the user, and the number of
cores per compute node (set in the environment variable
``METAWARDS_CORES_PER_NODE``, or passed as the command line option
``--cores-per-node``) to work out how many parallel scoop or MPI
processes to start, and will start those in a round-robin fashion
across the cluster. Distribution of work to nodes is via the
scoop or mpi4py work pools.

What this means is that the job scripts you need to write are very simple.

Example PBS job script
======================

Here is an example job script for a PBS cluster;

::

  #!/bin/bash
  #PBS -l walltime=01:00:00
  #PBS -l select=4:ncpus=64:mem=64GB
  # The above sets 4 nodes with 64 cores each

  # source the version of metawards we want to use
  # (assumes your python environments are in $HOME/envs)
  source $HOME/envs/metawards-0.6.0/bin/activate

  # change into the directory from which this job was submitted
  cd $PBS_O_WORKDIR

  # if you need to change the path to the MetaWardsData repository,
  # then update the below line and uncomment
  #export METAWARDSDATA="$HOME/GitHub/MetaWardsData"

  metawards --additional ExtraSeedsBrighton.dat \
            --input ncovparams.csv --repeats 8 --nthreads 16

The above job script will run 8 repeats of the adjustable parameter sets
in ``ncovparams.csv``. The jobs will be run using 16 cores per model run,
over 4 nodes with 64 cores per node (so 256 cores total, running
16 model runs in parallel). The runs will take only a minute or two
to complete, hence why it is not worth requesting more than one hour
of walltime.

The above job script can be submitted to the cluster using the PBS
``qsub`` command, e.g. if the script was called ``submit.sh``, then you
could type;

.. code-block:: bash

  qsub submit.sh

You can see the status of your job using

.. code-block:: bash

  qstat -n

Example slurm job script
========================

Here is an example job script for a slurm cluster;

::

  #!/bin/bash
  #SBATCH --time=01:00:00
  #SBATCH --ntasks=4
  #SBATCH --cpus-per-task=64
  # The above sets 4 nodes with 64 cores each

  # source the version of metawards we want to use
  # (assumes your python environments are in $HOME/envs)
  source $HOME/envs/metawards-0.6.0/bin/activate

  # if you need to change the path to the MetaWardsData repository,
  # then update the below line and uncomment
  #export METAWARDSDATA="$HOME/GitHub/MetaWardsData"

  metawards --additional ExtraSeedsBrighton.dat \
            --input ncovparams.csv --repeats 8 --nthreads 16

This script does the same job as the PBS job script above. Assuming
you name this script ``submit.slm`` you can submit this job using

.. code-block:: bash

  sbatch submit.slm

You can check the status of your job using

.. code-block:: bash

  squeue -u USER_NAME

where ``USER_NAME`` is your cluster username.
