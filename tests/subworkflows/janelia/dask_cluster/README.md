## Tests for starting and stopping a dask cluster.

You can run these tests using the following commands:

```
nextflow run ./tests/subworkflows/janelia/dask_cluster/main.nf -entry test_start_stop_dask -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_cluster/nextflow.config -profile docker --distributed false


nextflow run ./tests/subworkflows/janelia/dask_cluster/main.nf -entry test_start_stop_dask -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_cluster/nextflow.config -profile docker --distributed true

nextflow run ./tests/subworkflows/janelia/dask_cluster/main.nf -entry test_two_dask_clusters -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_cluster/nextflow.config -profile docker

```
