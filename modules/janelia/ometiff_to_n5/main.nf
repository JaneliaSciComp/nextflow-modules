process OMETIFF_TO_N5 {
    container { task.ext.container ?: 'janeliascicomp/n5-tools-dask:dev' }
    cpus { ncpus }
    memory "${mem_gb} GB"

    input:
    tuple val(meta),
          path(input_path),
          path(output_path),
          val(output_name),
          val(scale_subpath)
    tuple val(dask_scheduler),
          path(dask_config)
    val(data_crop_start)
    val(data_crop_size)
    val(ncpus)
    val(mem_gb)

    output:
    tuple val(meta), path(input_path), path("${output_path}/${output_name}/c*"), val(output_name), val(scale_subpath), emit: results
    path('versions.yml')                                                                                             , emit: versions

    script:
    def args = task.ext.args ?: ''
    def data_crop_start_arg = data_crop_start ? "--cropped_data_start ${data_crop_start}" : ''
    def data_crop_size_arg = data_crop_size ? "--cropped_data_size ${data_crop_size}" : ''
    def dask_scheduler_arg = dask_scheduler ? "--dask-scheduler ${dask_scheduler}" : ''
    def dask_config_arg = dask_config ? "--dask-config ${dask_config}" : ''

    """
    output_fullpath=\$(readlink ${output_path})
    mkdir -p \${output_fullpath}

    python /opt/scripts/n5-tools/ometif_to_n5.py \
        -i ${input_path} \
        -o ${output_path}/${output_name} -d ${scale_subpath} \
        ${data_crop_start_arg} \
        ${data_crop_size_arg} \
        ${dask_scheduler_arg} \
        ${dask_config_arg} \
        ${args}

    cat <<-END_VERSIONS > versions.yml
    OMETIFF_TO_N5: 0.0.1
    END_VERSIONS
    """
}
