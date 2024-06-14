nextflow run tests/subworkflows/janelia/bigstream_registration/main.nf \
    -c tests/subworkflows/janelia/bigstream_registration/nextflow.config \
    -c tests/subworkflows/janelia/bigstream_registration/registration-unit-test.config \
    -profile docker -entry test_registration_with_dask
