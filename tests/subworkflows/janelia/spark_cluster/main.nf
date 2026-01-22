include { SPARK_START } from '../../../../subworkflows/janelia/spark_start/main.nf'
include { SPARK_STOP  } from '../../../../subworkflows/janelia/spark_stop/main.nf'

params.distributed = true

workflow test_start_stop_spark {
    def spark_cluster_input = [
        [id: 'test_local_spark'],
        [/* empty data paths */],
    ]
    def spark_config = [
        'spark.driver.userClassPathFirst': true,
        'spark.executor.userClassPathFirst': true,
    ]
    def spark_cluster_info = SPARK_START(
        channel.of(spark_cluster_input),
        spark_config,
        params.distributed,
        params.spark_work_dir instanceof String && params.spark_work_dir ? file(params.spark_work_dir) : '',
        3,     // spark workers
        3,     // required workers
        1,     // worker cpus
        1,     // worker mem gb
        1,     // executor cpus
        0.5,   // executor mem gb
        0.2,   // executor memory overhead
        1,     // driver cpus
        1,     // driver memory in GB
        1,     // gb_per_cpu
    )

    spark_cluster_info.subscribe {
        log.info "Cluster info: $it"
    }

    def terminated_cluster = SPARK_STOP(spark_cluster_info, params.distributed)

    terminated_cluster.subscribe {
        log.info "Terminated cluster info: $it"
    }

}
