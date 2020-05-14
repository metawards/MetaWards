
from typing import Union as _Union
from typing import List as _List

from cython.parallel import parallel, prange

from libc.math cimport ceil

from .._networks import Networks
from .._infections import Infections
from .._demographics import DemographicID, DemographicIDs

from ..utils._profiler import Profiler
from ..utils._get_array_ptr cimport get_int_array_ptr, get_double_array_ptr

__all__ = ["go_to", "go_to_serial", "go_to_parallel"]


def go_to_parallel(go_from: _Union[DemographicID, DemographicIDs],
                   go_to: DemographicID,
                   network: Networks,
                   infections: Infections,
                   profiler: Profiler,
                   nthreads: int,
                   fraction: float = 1.0,
                   **kwargs) -> None:
    """This go function will move individuals from the "from"
       demographic(s) to the "to" demographic. This can move
       a subset of individuals is 'fraction' is less than 1, e.g.
       0.5 would move 50% of individuals.

       Parameters
       ----------
       from: DemographicID or DemographicIDs
         ID (name or index) or IDs of the demographics to scan for
         infected individuals
       to: DemographicID
         ID (name or index) of the demographic to send infected
         individuals to
       network: Networks
         The networks to be modelled. This must contain all of the
         demographics that are needed for this go function
       fraction: float
         The fraction of individuals to move, e.g. 0.75 would move
         75% of the individuals
    """

    if fraction < 0 or fraction > 1:
        raise ValueError(
            f"The move fraction {fraction} should be from 0 to 1")

    if fraction == 0:
        # nothing to do
        return

    # make sure that all of the needed demographics exist, and
    # convert them into a canonical form (indexes, list[indexes])
    if not isinstance(go_from, list):
        go_from = [go_from]

    subnets = network.subnets
    demographics = network.demographics
    subinfs = infections.subinfs

    go_from = [demographics.get_index(x) for x in go_from]

    go_to = demographics.get_index(go_to)

    if go_to in go_from:
        raise ValueError(
            f"You cannot move to {go_to} as it is also in {go_from}")

    to_subnet = subnets[go_to]
    to_subinf = subinfs[go_to]

    cdef int N_INF_CLASSES = infections.N_INF_CLASSES

    cdef double frac = fraction

    cdef int nnodes_plus_one = 0
    cdef int nlinks_plus_one = 0

    cdef int * work_infections_i
    cdef int * play_infections_i

    cdef int * to_work_infections_i
    cdef int * to_play_infections_i

    cdef double * links_suscept
    cdef double * links_weight

    cdef double * nodes_play_suscept
    cdef double * nodes_save_play_suscept

    cdef double * to_links_suscept = get_double_array_ptr(
                                            to_subnet.links.suscept)
    cdef double * to_links_weight = get_double_array_ptr(
                                            to_subnet.links.weight)

    cdef double * to_nodes_play_suscept = get_double_array_ptr(
                                            to_subnet.nodes.play_suscept)
    cdef double * to_nodes_save_play_suscept = get_double_array_ptr(
                                            to_subnet.nodes.save_play_suscept)

    cdef int nsubnets = len(subnets)

    cdef int num_threads = nthreads

    cdef int ii = 0
    cdef int i = 0
    cdef int j = 0

    cdef int to_move = 0
    cdef double to_move_d = 0.0

    for ii in go_from:
        subnet = subnets[ii]
        subinf = subinfs[ii]
        nnodes_plus_one = subinf.nnodes + 1
        nlinks_plus_one = subinf.nlinks + 1

        # move the susceptibles
        links_suscept = get_double_array_ptr(subnet.links.suscept)
        links_weight = get_double_array_ptr(subnet.links.weight)
        nodes_play_suscept = get_double_array_ptr(subnet.nodes.play_suscept)
        nodes_save_play_suscept = get_double_array_ptr(
                                                subnet.nodes.save_play_suscept)

        with nogil, parallel(num_threads=num_threads):
            if frac == 1.0:
                for j in prange(1, nlinks_plus_one, schedule="static"):
                    to_move_d = links_suscept[j]

                    if to_move_d > 0:
                        to_links_suscept[j] = to_links_suscept[j] + \
                                              to_move_d
                        links_suscept[j] = links_suscept[j] - to_move_d

                        to_links_weight[j] = to_links_suscept[j]
                        links_weight[j] = links_suscept[j]

                for j in prange(1, nnodes_plus_one, schedule="static"):
                    to_move_d = nodes_play_suscept[j]

                    if to_move_d > 0:
                        to_nodes_play_suscept[j] = to_nodes_play_suscept[j] + \
                                                   to_move_d
                        nodes_play_suscept[j] = nodes_play_suscept[j] - \
                                                to_move_d

                        to_nodes_save_play_suscept[j] = \
                                                    to_nodes_play_suscept[j]
                        nodes_save_play_suscept[j] = nodes_play_suscept[j]
            else:
                for j in prange(1, nlinks_plus_one, schedule="static"):
                    to_move_d = ceil(frac * links_suscept[j])

                    if to_move_d > 0:
                        to_links_suscept[j] = to_links_suscept[j] + \
                                              to_move_d
                        links_suscept[j] = links_suscept[j] - to_move_d

                        to_links_weight[j] = to_links_suscept[j]
                        links_weight[j] = links_suscept[j]

                for j in prange(1, nnodes_plus_one, schedule="static"):
                    to_move_d = ceil(frac * nodes_play_suscept[j])

                    if to_move_d > 0:
                        to_nodes_play_suscept[j] = to_nodes_play_suscept[j] + \
                                                   to_move_d
                        nodes_play_suscept[j] = nodes_play_suscept[j] - \
                                                to_move_d

                        to_nodes_save_play_suscept[j] = \
                                                    to_nodes_play_suscept[j]
                        nodes_save_play_suscept[j] = nodes_play_suscept[j]

        # move infected / recovered individuals
        for i in range(0, N_INF_CLASSES):
            work_infections_i = get_int_array_ptr(subinf.work[i])
            play_infections_i = get_int_array_ptr(subinf.play[i])

            to_work_infections_i = get_int_array_ptr(to_subinf.work[i])
            to_play_infections_i = get_int_array_ptr(to_subinf.play[i])

            with nogil, parallel(num_threads=num_threads):
                if frac == 1.0:
                    for j in prange(1, nlinks_plus_one, schedule="static"):
                        to_move = work_infections_i[j]

                        if to_move > 0:
                            to_work_infections_i[j] = \
                                                to_work_infections_i[j] + \
                                                to_move
                            work_infections_i[j] = \
                                                work_infections_i[j] - \
                                                to_move

                    for j in prange(1, nnodes_plus_one, schedule="static"):
                        to_move = play_infections_i[j]

                        if to_move > 0:
                            to_play_infections_i[j] = \
                                                to_play_infections_i[j] + \
                                                to_move

                            play_infections_i[j] = \
                                                play_infections_i[j] - \
                                                to_move
                else:
                    # only move a fraction of the population
                    for j in prange(1, nlinks_plus_one, schedule="static"):
                        to_move = <int>(ceil(frac * work_infections_i[j]))

                        if to_move > 0:
                            to_work_infections_i[j] = \
                                                to_work_infections_i[j] + \
                                                to_move
                            work_infections_i[j] = \
                                                work_infections_i[j] - \
                                                to_move

                    for j in prange(1, nnodes_plus_one, schedule="static"):
                        to_move = <int>(ceil(frac * work_infections_i[j]))

                        if to_move > 0:
                            to_play_infections_i[j] = \
                                                to_play_infections_i[j] + \
                                                to_move

                            play_infections_i[j] = \
                                                play_infections_i[j] - \
                                                to_move


def go_to_serial(**kwargs):
    raise NotImplementedError()


def go_to(nthreads: int = 1, **kwargs) -> None:
    """This go function will move individuals from the "from"
       demographic(s) to the "to" demographic. This can move
       a subset of individuals is 'fraction' is less than 1, e.g.
       0.5 would move 50% of individuals.

       Parameters
       ----------
       from: DemographicID or DemographicIDs
         ID (name or index) or IDs of the demographics to scan for
         infected individuals
       to: DemographicID
         ID (name or index) of the demographic to send infected
         individuals to
       network: Networks
         The networks to be modelled. This must contain all of the
         demographics that are needed for this go function
       fraction: float
         The fraction of individuals to move, e.g. 0.75 would move
         75% of the individuals
    """

    if nthreads > 1:
        go_to_parallel(nthreads=nthreads, **kwargs)
    else:
        go_to_serial(**kwargs)
