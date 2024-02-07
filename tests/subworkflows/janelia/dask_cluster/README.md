You can run these tests using:

```
nextflow run ./tests/subworkflows/janelia/dask_cluster/main.nf -entry test_one_dask_cluster -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_cluster/nextflow.config -profile docker

nextflow run ./tests/subworkflows/janelia/dask_cluster/main.nf -entry test_two_dask_clusters -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_cluster/nextflow.config -profile docker

```

