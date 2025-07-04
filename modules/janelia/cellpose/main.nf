process CELLPOSE {
    container { task && task.ext.container ?: 'janeliascicomp/cellpose:3.1.0-dask2025.1.0-py12' }
    cpus { cellpose_cpus }
    memory "${cellpose_mem_in_gb} GB"
    conda 'modules/janelia/cellpose/conda-env.yml'

    input:
    tuple val(meta),
          path(image, stageAs: 'cellpose-input/*'),
          val(image_subpath),
          path(models_path, stageAs: 'cellpose-models/*'), // this is optional - if undefined pass in as empty list ([])
          path(output_dir),
          val(output_name),
          path(working_dir, stageAs: 'cellpose-work/*') // this is optional
    tuple val(dask_scheduler),
          path(dask_config) // this is optional - if undefined pass in as empty list ([])
    path(logging_config) // this is optional - if undefined pass in as empty list ([])
    val(cellpose_cpus)
    val(cellpose_mem_in_gb)

    output:
    tuple val(meta), env(input_image_fullpath), val(image_subpath), env(output_segmentation_results), emit: results
    tuple val(meta), val(output_name_noext), val(output_name_ext)                                   , emit: result_names
    path('versions.yml')                                                                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def input_image_subpath_arg = image_subpath
                                    ? "--input-subpath ${image_subpath}"
                                    : ''
    def set_models_path = models_path
        ? "models_fullpath=\$(readlink ${models_path}) && \
           mkdir -p \${models_fullpath} && \
           export CELLPOSE_LOCAL_MODELS_PATH=\${models_fullpath}"
        : ''
    def logging_config_arg = logging_config ? "--logging-config ${logging_config}" : ''
    def models_path_arg = models_path ? "--models-dir \${models_fullpath}" : ''
    def working_dir_arg = working_dir ?: output_dir
    def output_image_name = output_name ?: ''
    def dask_scheduler_arg = dask_scheduler ? "--dask-scheduler ${dask_scheduler}" : ''
    def dask_config_arg = dask_config ? "--dask-config ${dask_config}" : ''
    (output_name_noext, output_name_ext) = output_image_name.lastIndexOf('.').with {
        it == -1
            ? [output_image_name, '']
            : [output_image_name[0..<it], output_image_name[(it+1)..-1]]
    }
    log.debug "Output name:ext => ${output_name_noext}:${output_name_ext}"
    """
    input_image_fullpath=\$(readlink ${image})
    # create the output directory using the canonical name
    output_fullpath=\$(readlink ${output_dir})
    mkdir -p \${output_fullpath}
    working_fullpath=\$(readlink ${working_dir_arg})
    mkdir -p \${working_fullpath}
    if [[ "${output_image_name}" == "" ]]; then
        full_outputname=\${output_fullpath}
    else
        full_outputname="\${output_fullpath}/${output_image_name}"
    fi
    ${set_models_path}
    echo "Run: " \
        python /opt/scripts/cellpose/main_distributed_cellpose.py \
        -i \${input_image_fullpath} ${input_image_subpath_arg} \
        -o \${full_outputname} \
        --working-dir \${working_fullpath} \
        ${models_path_arg} \
        ${dask_scheduler_arg} \
        ${dask_config_arg} \
        ${logging_config_arg} \
        ${args}

    python /opt/scripts/cellpose/main_distributed_cellpose.py \
        -i \${input_image_fullpath} ${input_image_subpath_arg} \
        -o \${full_outputname} \
        --working-dir \${working_fullpath} \
        ${models_path_arg} \
        ${dask_scheduler_arg} \
        ${dask_config_arg} \
        ${logging_config_arg} \
        ${args}

    output_segmentation_results=()
    for sr in \$(ls \${output_fullpath} | grep "${output_name_noext}.*${output_name_ext}") ; do
        output_segmentation_results+=("\${output_fullpath}/\${sr}")
    done

    cellpose_version=\$(python /opt/scripts/cellpose/main_distributed_cellpose.py \
                        --version | \
                        grep "cellpose version" | \
                        sed "s/cellpose version:\\s*//")
    echo "Cellpose version: \${cellpose_version}"
    cat <<-END_VERSIONS > versions.yml
    cellpose: \${cellpose_version}
    END_VERSIONS
    """

}
