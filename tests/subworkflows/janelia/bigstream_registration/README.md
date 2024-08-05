nextflow run tests/subworkflows/janelia/bigstream_registration/main.nf \
    -c tests/subworkflows/janelia/bigstream_registration/nextflow.config \
    -c tests/subworkflows/janelia/bigstream_registration/bigstream-testdata3.config \
    -profile docker \
    -entry test_registration_and_additional_deformations
