process BIGSTREAM_DEFORM {
    container { task.ext.container ?: 'janeliascicomp/bigstream:1.2.9-dask2023.10.1-py11' }
    cpus { bigstream_cpus }
    memory "${bigstream_mem_in_gb} GB"

    input:
    tuple val(meta),
          path(fix_image),
          val(fix_image_subpath),
          path(mov_image),
          val(mov_image_subpath),
          path(affine_transforms), // one or more affine transformations (paths to the corresponding affine.mat)
          path(deform_dir), // location of the displacement vector
          val(deform_subpath), // displacement vector subpath
          path(output_dir),
          val(output_subpath)
    tuple val(dask_scheduler),
          path(dask_config) // this is optional - if undefined pass in as empty list ([])
    val(bigstream_cpus)
    val(bigstream_mem_in_gb)

    output:
    tuple val(meta),
          path(fix_image), val(fix_image_subpath),
          path(mov_image), val(mov_image_subpath),
          path(output_dir), val(output_subpath)  , emit: results

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def fix_image_subpath_arg = fix_image_subpath ? "--fixed-subpath ${fix_image_subpath}" : ''
    def mov_image_subpath_arg = mov_image_subpath ? "--moving-subpath ${mov_image_subpath}" : ''
    def affine_transforms_arg = affine_transforms ? "--affine-transformations ${affine_transform_name}"
    def local_transform_arg = deform_dir ? "--local-transform ${deform_dir}" : ''
    def local_transform_subpath_arg = deform_dir && deform_subpath ? "--local-transform-subpath ${deform_subpath}" : ''
    def output_subpath_arg = output_subpath ? "--output-subpath ${output_subpath}" : ''
    def dask_scheduler_arg = dask_scheduler ? "--dask-scheduler ${dask_scheduler}" : ''
    def dask_config_arg = dask_scheduler && dask_config ? "--dask-config ${dask_config}" : ''

    """
    output_fullpath=\$(readlink ${output_dir})
    mkdir -p \${output_fullpath}
    python /app/bigstream/scripts/main_apply_local_transform.py \
        --fixed ${fix_image} ${fix_image_subpath_arg} \
        --moving ${mov_image} ${mov_image_subpath_arg} \
        ${affine_transforms_arg} \
        ${local_transform_arg} ${local_transform_subpath_arg} \
        --output ${output_dir} ${output_subpath_arg} \
        ${dask_scheduler_arg} \
        ${dask_config_arg} \
        ${args}
    """

}