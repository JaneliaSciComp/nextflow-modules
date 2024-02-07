The test can be run using nf-core command:

`nf-core modules test cellpose`

or using:
```bash
nextflow run ./tests/modules/janelia/cellpose/main.nf -entry test_distributed_cellpose_with_dask -c ./tests/config/nf-test.config -c ./tests/modules/janelia/cellpose/nextflow.config -profile docker
```

on an M1 Mac use:
```bash
nextflow run ./tests/modules/janelia/cellpose/main.nf -entry test_distributed_cellpose_with_dask -c ./tests/config/nf-test.config -c ./tests/modules/janelia/cellpose/nextflow.config -profile docker --runtime_opts "--platform linux/arm64"
```
