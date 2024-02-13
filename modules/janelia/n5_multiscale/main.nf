process N5_MULTISCALE {
    container { task.ext.container ?: 'janeliascicomp/n5-tools-dask:dev' }
    cpus { ncpus }
    memory "${mem_gb} GB"

    input:
    tuple val(meta),
          path(input_path),
          val(n5_name),
          val(n5_subpaths),
          val(fullscale_subpath)
    tuple val(dask_scheduler),
          path(dask_config)
    val(ncpus)
    val(mem_gb)

    output:
    tuple val(meta), path(input_path), emit: results
    path('versions.yml')             , emit: versions

    script:
    def args = task.ext.args ?: ''
    def fullscale_subpath_arg = fullscale_subpath
        ? "--fullscale-path ${fullscale_subpath}"
        : ''
    def dask_scheduler_arg = dask_scheduler ? "--dask-scheduler ${dask_scheduler}" : ''
    def dask_config_arg = dask_config ? "--dask-config ${dask_config}" : ''

    """
    # resolve the input symlink because
    # links are not followed in python code
    input_fullpath=\$(readlink ${input_path})

    echo "Build multiscale pyramid for: \${input_fullpath}/${n5_name}"
    python /opt/scripts/n5-tools-dask/n5_multiscale.py \
        -i \${input_fullpath}/${n5_name} \
        --data-sets ${n5_subpaths} \
        ${fullscale_subpath_arg} \
        ${dask_scheduler_arg} \
        ${dask_config_arg} \
        ${args}

    cat <<-END_VERSIONS > versions.yml
    OMETIFF_TO_N5: 0.0.1
    END_VERSIONS
    """
}
