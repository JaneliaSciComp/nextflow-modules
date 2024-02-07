include { DASK_START } from '../../../../subworkflows/janelia/dask_start/main.nf'
include { DASK_STOP  } from '../../../../subworkflows/janelia/dask_stop/main.nf'

params.distributed = true

workflow test_start_stop_dask {
    def dask_cluster_input = [
        [id: 'test_local_dask'],
        [/* empty data paths */],
    ]

    def dask_cluster_info = DASK_START(
        Channel.of(dask_cluster_input),
        params.distributed,
        file(params.dask_work_dir),
        3, // dask workers
        2, // required workers
        1, // worker cores
        1.5, // worker mem
    )

    dask_cluster_info.subscribe {
        log.info "Cluster info: $it"
    }

    def terminated_cluster = DASK_STOP(dask_cluster_info)

    terminated_cluster.subscribe {
        log.info "Terminated cluster info: $it"
    }

}
