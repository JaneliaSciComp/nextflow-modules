include { CELLPOSE   } from '../../../../modules/janelia/cellpose/main'

include { DASK_START } from '../../../../subworkflows/janelia/dask_start/main'
include { DASK_STOP  } from '../../../../subworkflows/janelia/dask_stop/main'

process UNTAR_RAW_INPUT {
    input: path(tarfile, stageAs:'input-data/*')
    output: path('*.n5')

    script:
    """
    tar -xvf $tarfile
    """
}

workflow test_distributed_cellpose_with_dask {
    // retrieve and untar the data from test_datasets repository
    def cellpose_test_data = UNTAR_RAW_INPUT (file(params.test_data['stitched_images']['n5']['r1_n5'])) |
    map { input_image ->
        // if the path to the dask config and to the models dir is specified
        // make sure they are added to the input paths so that 
        // they get mounted in the dask workers
        def path_inputs = [ 
            input_image,
            file(params.output_image_dir).parent, // pass the parent for the output as the output may not exist
        ] +
        (params.cellpose_work_dir ? [ file(params.cellpose_work_dir) ] : []) +
        (params.cellpose_models_dir ? [ file(params.cellpose_models_dir).parent ] : [])
        [
            [
                id: 'test_distributed_cellpose_with_dask',
            ],
            path_inputs,
        ]
    }
    cellpose_test_data.subscribe { log.info "Cellpose path inputs: $it" }
    // create a dask cluster
    def dask_cluster = DASK_START(
        cellpose_test_data,
        params.distributed, // distributed
        params.dask_config ? file(params.dask_config) : [],
        file(params.dask_work_dir),
        params.cellpose_workers,
        params.cellpose_required_workers,
        params.cellpose_worker_cpus,
        params.cellpose_worker_mem_gb,
    )

    dask_cluster.subscribe { it ->
        log.info "Cluster info: $it"
    }

    def cellpose_input = dask_cluster
    | join(cellpose_test_data, by: 0)
    | multiMap { meta, cluster_context, datapaths ->
        def (input_path, output_path) = datapaths
        def cellpose_working_path = params.cellpose_work_dir
            ? file(params.cellpose_work_dir) : []
        def dask_config_path = params.dask_config
            ? file(params.dask_config) : []
        def cellpose_models_path = params.cellpose_models_dir
            ? file(params.cellpose_models_dir) : []

        def data = [
            meta,
            input_path,
            params.input_image_subpath,
            cellpose_models_path,
            params.model,
            output_path,
            params.output_image_name,
            params.output_image_subpath,
            cellpose_working_path,
        ]
        def cluster_info = [
            cluster_context.scheduler_address,
            dask_config_path,
        ]
        log.debug "Cluster data: ${data}"
        log.debug "Cluster info: ${cluster_info}"
        data: data
        cluster: cluster_info
    }

    def cellpose_results = CELLPOSE(
        cellpose_input.data,
        cellpose_input.cluster,
        params.preprocessing_config ? file(params.preprocessing_config) : [],
        params.logging_config ? file(params.logging_config) : [],
        params.cellpose_driver_cpus,
        params.cellpose_driver_mem_gb,
    )

    cellpose_results.results.subscribe {
        log.info "Cellpose results: $it"
    }

    dask_cluster.join(cellpose_results.results, by:0)
    | map {
        def (meta, cluster_context) = it
        [ meta, cluster_context ]
    }
    | groupTuple
    | DASK_STOP

}
