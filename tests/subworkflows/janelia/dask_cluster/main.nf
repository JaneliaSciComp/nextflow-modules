include { DASK_START } from '../../../../subworkflows/janelia/dask_start/main.nf'
include { DASK_STOP  } from '../../../../subworkflows/janelia/dask_stop/main.nf'

params.distributed = true

workflow {
    if (params.entry == 'test_start_stop_dask') {
        test_start_stop_dask()
    } else if (params.entry == 'test_two_dask_clusters') {
        test_two_dask_clusters()
    }
}

workflow test_start_stop_dask {
    def dask_cluster_input = [
        [id: 'test_local_dask'],
        [/* empty data paths */],
    ]

    def dask_cluster_info = DASK_START(
        channel.of(dask_cluster_input),
        params.distributed,
        params.dask_config,
        params.dask_work_dir instanceof String && params.dask_work_dir ? file(params.dask_work_dir) : '',
        3,   // dask workers
        2,   // required workers
        1,   // worker cores
        1.5, // worker mem
    )

    dask_cluster_info.view { it ->
        log.info "test_start_stop_dask: cluster info: $it"
    }

    def terminated_cluster = DASK_STOP(dask_cluster_info)

    terminated_cluster.view { it ->
        log.info "test_start_stop_dask: terminated cluster info: $it"
    }

}

workflow test_two_dask_clusters {
    def test_dir = file("output/dask/dummy")
    def test_data_dir = file("output/dask/dummy/data")
    test_data_dir.mkdirs()
    // create a small file in the test_data_dir
    new File("${test_data_dir}/test.txt").text = "Test"

    def dask_cluster_input = [
        [
            [
                id: 'test_two_dask_clusters_1',
            ],
            [test_data_dir],
        ],
        [
            [
                id: 'test_two_dask_clusters_2',
            ], 
            [/* empty data file list*/],
        ],
    ]

    def dask_cluster_info = DASK_START(
        channel.fromList(dask_cluster_input),
        true,
        '',
        test_dir,
        3, // dask workers
        2, // required workers
        0.25, // worker cores
        1, // worker mem
    )

    DASK_STOP(dask_cluster_info)
}
