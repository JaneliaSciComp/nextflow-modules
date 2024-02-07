include { DASK_TERMINATE } from '../../../modules/janelia/dask/terminate/main'

workflow DASK_STOP {
    take:
    meta_and_context     // channel: [val(meta), dask_context]

    main:
    def cluster_info = meta_and_context 
    | filter { meta, dask_context ->
        log.info "Dask context for ${meta}: ${dask_context}"
        dask_context.cluster_work_dir
    }
    | map { meta, dask_context ->
        [ meta, dask_context.cluster_work_dir ]
    }
    | DASK_TERMINATE

    emit:
    done = cluster_info // [ meta, dask_work_dir ]
}
