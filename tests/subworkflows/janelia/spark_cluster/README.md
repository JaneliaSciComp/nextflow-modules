## Tests for starting and stopping a spark cluster.

You can run these tests using the following commands:

Note: Cleanup the output subdirectory because it leaves dangling terminate files (This needs to be fixed)

```
nextflow run ./tests/subworkflows/janelia/spark_cluster/main.nf -entry test_start_stop_spark -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/spark_cluster/nextflow.config -profile podman --distributed true
```
