include { BIGSTREAM_GLOBAL_ALIGN } from '../../../modules/janelia/bigstream_global_align/main'
include { BIGSTREAM_LOCAL_ALIGN  } from '../../../modules/janelia/bigstream_local_align/main'
include { DASK_START             } from '../dask_start/main'

workflow BIGSTREAM_REGISTRATION {
    take:
    registration_input // [
                       //  meta,
                       //  global_fix, global_fix_subpath, 
                       //  global_mov, global_mov_subpath,
                       //  global_fix_mask, global_fix_mask_subpath
                       //  global_mov_mask, global_mov_mask_subpath
                       //  global_steps
                       //  global_output
                       //  global_transform_name
                       //  global_align_name
                       //  local_fix, local_fix_subpath, 
                       //  local_mov, local_mov_subpath,
                       //  local_fix_mask, local_fix_mask_subpath
                       //  local_mov_mask, local_mov_mask_subpath
                       //  local_steps
                       //  local_output
                       //  local_transform_name
                       //  local_transform_subpath
                       //  local_inv_transform_name
                       //  local_inv_transform_subpath
                       //  local_align_name
                       //  with_dask
                       //  dask_work_dir
                       //  dask_config
                       //  dask_total_workers
                       //  dask_min_workers
                       //  dask_worker_cpus
                       //  dask_worker_mem_gb
                       //  ]
    global_align_cpus
    global_align_mem_gb
    local_align_cpus
    local_align_mem_gb
    do_not_destroy_cluster  // if this is true the caller is responsible for destroying the cluster

    main:    
    def global_align_input = registration_input
    | map {
        def (meta,
             global_fix, global_fix_subpath, 
             global_mov, global_mov_subpath,
             global_fix_mask, global_fix_mask_subpath,
             global_mov_mask, global_mov_mask_subpath,
             global_steps,
             global_output,
             global_transform_name,
             global_align_name
            ) = it // there's a lot more in the input but we only look at what we are interested here
        def r = [
            meta,
            global_fix, global_fix_subpath,
            global_mov, global_mov_subpath,
            global_fix_mask, global_fix_mask_subpath,
            global_mov_mask, global_mov_mask_subpath,
            global_steps,
            global_output,
            global_transform_name,
            global_align_name,
        ]
        log.info "Prepare global alignment: $it -> $r"
        return r
    }

    def global_align_results = BIGSTREAM_GLOBAL_ALIGN(
        global_align_input,
        global_align_cpus,
        global_align_mem_gb,
    )

    global_align_results.subscribe {
        log.info "Completed global alignment -> $it"
    }

    def cluster_input = registration_input
    | multiMap {
        def (meta,
             global_fix, global_fix_subpath, 
             global_mov, global_mov_subpath,
             global_fix_mask, global_fix_mask_subpath,
             global_mov_mask, global_mov_mask_subpath,
             global_steps,
             global_output,
             global_transform_name,
             global_align_name,
             local_fix, local_fix_subpath,
             local_mov, local_mov_subpath,
             local_fix_mask, local_fix_mask_subpath,
             local_mov_mask, local_mov_mask_subpath,
             local_steps,
             local_output,
             local_transform_name,
             local_transform_subpath,
             local_inv_transform_name,
             local_inv_transform_subpath,
             local_align_name,
             with_dask,
             dask_work_dir,
             dask_config,
             dask_total_workers,
             dask_min_workers,
             dask_worker_cpus,
             dask_worker_mem_gb
             ) = it

        def cluster_files =
            [ 
                global_output, local_fix, local_mov, local_output
            ] + 
            (local_fix_mask ? [local_fix_mask] :[]) +
            (local_mov_mask ? [local_mov_mask] :[])

        def cluster_files_set = cluster_files as Set
        log.info "Cluster files: ${cluster_files_set}"

        def cluster_resources = [
            with_dask,
            with_dask ? dask_work_dir : [],
            with_dask ? dask_total_workers : 0,
            with_dask ? dask_min_workers : 0,
            with_dask ? dask_worker_cpus : 0,
            with_dask ? dask_worker_mem_gb : 0
        ]

        log.info "Cluster resources: $cluster_resources"

        cluster_files: [ meta, cluster_files_set ]
        cluster_resources: cluster_resources
    }

    def cluster_info = DASK_START(
        cluster_input.cluster_files,
        // all the other args will be converted to a value channel
        // by getting the first element only
        cluster_input.cluster_resources.map { it[0] /*with dask*/ }.first(),
        cluster_input.cluster_resources.map { it[1] /* work_dir */ }.first(),
        cluster_input.cluster_resources.map { it[2] /* total_workers */ }.first(),
        cluster_input.cluster_resources.map { it[3] /* min_workers */ }.first(),
        cluster_input.cluster_resources.map { it[4] /* worker_cpus */ }.first(),
        cluster_input.cluster_resources.map { it[5] /* worker_mem_gb */ }.first(),
    )

    def local_align_input = cluster_info
    | join (registration_input, by: 0)
    | multiMap {
        def (meta,
             cluster_context,
             global_fix, global_fix_subpath, 
             global_mov, global_mov_subpath,
             global_fix_mask, global_fix_mask_subpath,
             global_mov_mask, global_mov_mask_subpath,
             global_steps,
             global_output,
             global_transform_name,
             global_align_name,
             local_fix, local_fix_subpath,
             local_mov, local_mov_subpath,
             local_fix_mask, local_fix_mask_subpath,
             local_mov_mask, local_mov_mask_subpath,
             local_steps,
             local_output,
             local_transform_name,
             local_transform_subpath,
             local_inv_transform_name,
             local_inv_transform_subpath,
             local_align_name,
             with_dask,
             dask_work_dir,
             dask_config
            ) = it
        def data = [
            meta,
            local_fix, local_fix_subpath,
            local_mov, local_mov_subpath,
            local_fix_mask ?: [],
            local_fix_mask_subpath,
            local_mov_mask ?: [],
            local_mov_mask_subpath,
            global_output,
            global_transform_name,
            local_steps,
            local_output,
            local_transform_name,
            local_transform_subpath,
            local_inv_transform_name,
            local_inv_transform_subpath,
            local_align_name,
        ]
        def cluster = [
            cluster_context.scheduler_address,
            dask_config ?: [],
        ]
        log.info "Prepare local alignment: $it -> $data, $cluster"
        data: data
        cluster: cluster
    }

    def local_align_results = BIGSTREAM_LOCAL_ALIGN(
        local_align_input.data,
        local_align_input.cluster,
        local_align_cpus,
        local_align_mem_gb,
    )

    local_align_results.subscribe {
        log.info "Completed local alignment -> $it"
    }

    if (do_not_destroy_cluster) {
        cluster = cluster_info
    } else {
        // destroy the cluster when the local alignment is complete
        cluster = cluster_info
        | join(local_align_results, by: 0)
        | map {
            def (meta, cluster_context) = it
            [ meta, cluster_context ]
        }
        | DASK_STOP
        | map {
            def (meta, cluster_work_dir) = it
            [
                meta, [:],
            ]
        }
    }

    emit:
    global = global_align_results 
    local = local_align_results
    cluster
}
