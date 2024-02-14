# Nextflow modules

This repository holds reusable modules, subworkflows that are used in Janelia Nextflow pipelines.

The repository is formatted to be compatible with [nf-core tooling](https://nf-co.re/), in particular the [module system](https://github.com/nf-core/modules/tree/master).

## Prerequisites

You  must [install nf-core tools](https://nf-co.re/tools) in your environment before you can install modules from this repository.

## List modules

```bash
nf-core modules -g JaneliaSciComp/nextflow-modules list remote
```

## Installing a module

To install a module into a pipeline, use the `modules install` command, e.g.:

```bash
nf-core modules -g JaneliaSciComp/nextflow-modules install spark/prepare
```

## Installing a subworkflow

```bash
nf-core subworkflows -g JaneliaSciComp/nextflow-modules install spark_start
```

This will install the subworkflow and all of its dependencies including the **spark_cluster** subworkflow and all necessary modules.

