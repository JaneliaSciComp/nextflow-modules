You can run these tests using:

```
nextflow run ./tests/subworkflows/janelia/dask_start/main.nf -entry test_start_stop_dask -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_start/nextflow.config -profile docker --distributed false


nextflow run ./tests/subworkflows/janelia/dask_start/main.nf -entry test_start_stop_dask -c tests/config/nf-test.config -c ./tests/subworkflows/janelia/dask_start/nextflow.config -profile docker --distributed true
```
