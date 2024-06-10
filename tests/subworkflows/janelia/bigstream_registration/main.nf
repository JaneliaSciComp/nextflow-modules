include { BIGSTREAM_REGISTRATION } from '../../../../subworkflows/janelia/bigstream_registration/main'

workflow test_registration_with_dask {
    def meta = [
        id: 'test-registration-with-dask',
    ]

    def global_output = params.global_output ? file(params.global_output) : ''
    def local_output = file(params.local_output)

    def registration_input = Channel.of(
        [
            meta,
            file(params.global_fix), params.global_fix_subpath,
            file(params.global_mov), params.global_mov_subpath,
            params.use_mask && params.global_fix_mask ? file(params.global_fix_mask) : '', params.use_mask && params.global_fix_mask ? params.global_fix_mask_subpath : '',
            params.use_mask && params.global_mov_mask ? file(params.global_mov_mask) : '', params.use_mask && params.global_mov_mask ? params.global_mov_mask_subpath : '',
            params.global_steps,
            global_output, // global transform output
            params.global_transform_name,
            global_align, // global align output
            params.global_align_name, params.global_align_subpath,
            file(params.local_fix), params.local_fix_subpath,
            file(params.local_mov), params.local_mov_subpath,
            params.use_mask && params.local_fix_mask ? file(params.local_fix_mask) : '', params.use_mask && params.local_fix_mask ? params.local_fix_mask_subpath : '',
            params.use_mask && params.local_mov_mask ? file(params.local_mov_mask) : '', params.use_mask && params.local_mov_mask ? params.local_mov_mask_subpath : '',
            params.local_steps,
            local_output, // local transform output
            params.local_transform_name,
            params.local_transform_subpath,
            params.local_inv_transform_name,
            params.local_inv_transform_subpath,
            local_output, // local align output
            params.local_align_name, params.local_align_subpath,
            [], // additional deformations
            params.with_dask,
            params.dask_work_dir ? file(params.dask_work_dir) : '',
            params.dask_config ? file(params.dask_config) : '',
            params.local_align_workers,
            params.local_align_min_workers,
            params.local_align_worker_cpus,
            params.local_align_worker_mem_gb,
        ]
    )

    BIGSTREAM_REGISTRATION(
        registration_input,
        params.bigstream_config ? file(params.bigstream_config): '',
        params.global_align_cpus,
        params.global_align_mem_gb,
        params.local_align_worker_cpus,
        params.local_align_worker_mem_gb,
    )
}

workflow test_global_registration_only {
    def meta = [
        id: 'test-global-registration-only',
    ]

    def global_output = params.global_output ? file(params.global_output) : ''

    def registration_input = Channel.of(
        [
            meta,
            file(params.global_fix), params.global_fix_subpath,
            file(params.global_mov), params.global_mov_subpath,
            params.global_fix_mask ? file(params.global_fix_mask) : '', params.global_fix_mask_subpath,
            params.global_mov_mask ? file(params.global_mov_mask) : '', params.global_mov_mask_subpath,
            params.global_steps,
            global_output, // global transform output
            params.global_transform_name,
            global_output, // global align output
            params.global_align_name, params.global_align_subpath,
            '', '', // local fix
            '', '', // local mov
            '', '', // local fix mask
            '', '', // local mov mask
            params.local_steps, // local steps
            '', // local transform output
            '', '', // local transform
            '', '', // local inverse transform
            '', // local align output
            '', '', // local align
            [],
            params.with_dask,
            params.dask_work_dir ? file(params.dask_work_dir) : '',
            params.dask_config ? file(params.dask_config) : '',
            params.local_align_workers,
            params.local_align_min_workers,
            params.local_align_worker_cpus,
            params.local_align_worker_mem_gb,
        ]
    )

    BIGSTREAM_REGISTRATION(
        registration_input,
        params.bigstream_config ? file(params.bigstream_config): '',
        params.global_align_cpus,
        params.global_align_mem_gb,
        params.local_align_worker_cpus,
        params.local_align_worker_mem_gb,
    )
}

workflow test_local_registration_only_with_dask {
    def meta = [
        id: 'test-local-registration-only-with-dask',
    ]

    def local_output = file(params.local_output)

    def registration_input = Channel.of(
        [
            meta,
            '', '', // global fix image
            '', '', // global mov image
            '', '', // global fix mask
            '', '', // global mov mask
            '', // no global steps
            '', // global transform output
            '', // global transform name,
            '', // global align output
            '', '', // global align name,
            file(params.local_fix), params.local_fix_subpath,
            file(params.local_mov), params.local_mov_subpath,
            params.local_fix_mask ? file(params.local_fix_mask) : '', params.local_fix_mask_subpath,
            params.local_mov_mask ? file(params.local_mov_mask) : '', params.local_mov_mask_subpath,
            params.local_steps,
            local_output, // local transform output
            params.local_transform_name,
            params.local_transform_subpath,
            params.local_inv_transform_name,
            params.local_inv_transform_subpath,
            local_output, // local align output
            params.local_align_name, params.local_align_subpath,
            [],
            params.with_dask,
            params.dask_work_dir ? file(params.dask_work_dir) : '',
            params.dask_config ? file(params.dask_config) : '',
            params.local_align_workers,
            params.local_align_min_workers,
            params.local_align_worker_cpus,
            params.local_align_worker_mem_gb,
        ]
    )

    BIGSTREAM_REGISTRATION(
        registration_input,
        params.bigstream_config ? file(params.bigstream_config): '',
        params.global_align_cpus,
        params.global_align_mem_gb,
        params.local_align_worker_cpus,
        params.local_align_worker_mem_gb,
    )
}

workflow test_registration_with_additional_deformations {
    def meta = [
        id: 'test_registration_with_additional_deformations',
    ]

    def global_output = params.global_output ? file(params.global_output) : ''
    def local_output = file(params.local_output)

    def registration_input = Channel.of(
        [
            meta,
            file(params.global_fix), params.global_fix_subpath,
            file(params.global_mov), params.global_mov_subpath,
            params.global_fix_mask ? file(params.global_fix_mask) : '', params.global_fix_mask_subpath,
            params.global_mov_mask ? file(params.global_mov_mask) : '', params.global_mov_mask_subpath,
            params.global_steps,
            global_output, // global transform
            params.global_transform_name,
            global_output, // global align output
            params.global_align_name, params.global_align_subpath,
            file(params.local_fix), params.local_fix_subpath,
            file(params.local_mov), params.local_mov_subpath,
            params.local_fix_mask ? file(params.local_fix_mask) : '',
            params.local_fix_mask_subpath,
            params.local_mov_mask ? file(params.local_mov_mask) : '',
            params.local_mov_mask_subpath,
            params.local_steps,
            local_output, // transform_output
            params.local_transform_name,
            params.local_transform_subpath,
            params.local_inv_transform_name,
            params.local_inv_transform_subpath,
            local_output, // align_output
            params.local_align_name, params.local_align_subpath,
            [
                [
                    file(params.local_fix), "${params.additional_warped_channel}/${params.additional_warped_scale}", '',
                    file(params.local_mov), "${params.additional_warped_channel}/${params.additional_warped_scale}", '',
                    file("${local_output}/${params.local_align_name}"), '',
                ],
            ],
            params.with_dask,
            params.dask_work_dir ? file(params.dask_work_dir) : '',
            params.dask_config ? file(params.dask_config) : '',
            params.local_align_workers,
            params.local_align_min_workers,
            params.local_align_worker_cpus,
            params.local_align_worker_mem_gb,
        ]
    )

    BIGSTREAM_REGISTRATION(
        registration_input,
        params.bigstream_config ? file(params.bigstream_config): '',
        params.global_align_cpus,
        params.global_align_mem_gb,
        params.local_align_worker_cpus,
        params.local_align_worker_mem_gb,
    )
}

workflow test_registration_without_warp_but_with_additional_deformations {
    def meta = [
        id: 'test_registration_without_warp_but_with_additional_deformations',
    ]

    def global_output = params.global_output ? file(params.global_output) : ''
    def local_output = file(params.local_output)

    def registration_input = Channel.of(
        [
            meta,
            file(params.global_fix), params.global_fix_subpath,
            file(params.global_mov), params.global_mov_subpath,
            params.global_fix_mask ? file(params.global_fix_mask) : '', params.global_fix_mask_subpath,
            params.global_mov_mask ? file(params.global_mov_mask) : '', params.global_mov_mask_subpath,
            params.global_steps,
            global_output, // global transform output
            params.global_transform_name,
            global_output, // global align output
            params.global_align_name, params.global_align_subpath,
            file(params.local_fix), params.local_fix_subpath,
            file(params.local_mov), params.local_mov_subpath,
            params.local_fix_mask ? file(params.local_fix_mask) : '',
            params.local_fix_mask_subpath,
            params.local_mov_mask ? file(params.local_mov_mask) : '',
            params.local_mov_mask_subpath,
            params.local_steps,
            file(params.local_output),
            params.local_transform_name,
            params.local_transform_subpath,
            params.local_inv_transform_name,
            params.local_inv_transform_subpath,
            '', '', // local align
            [
                [
                    file(params.local_fix), params.local_fix_subpath, '',
                    file(params.local_mov), "${params.additional_warped_channel}/${params.additional_warped_scale}", '',
                    file("${params.local_output}/${params.local_align_name}"), '',
                ],
            ],
            params.with_dask,
            params.dask_work_dir ? file(params.dask_work_dir) : '',
            params.dask_config ? file(params.dask_config) : '',
            params.local_align_workers,
            params.local_align_min_workers,
            params.local_align_worker_cpus,
            params.local_align_worker_mem_gb,
        ]
    )

    BIGSTREAM_REGISTRATION(
        registration_input,
        params.bigstream_config ? file(params.bigstream_config): '',
        params.global_align_cpus,
        params.global_align_mem_gb,
        params.local_align_cpus,
        params.local_align_mem_gb,
    )
}