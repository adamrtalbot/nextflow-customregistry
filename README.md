# Nextflow Custom Container Registry

We can specify a custom container registry using the Nextflow config `docker.registry`. This behaves the same as the default container registry when running `docker pull`, i.e.:
 - Pulling a container with a simple name will result in pulling the container from the default registry
 - Using a fully qualified container name will result in pulling the container from the specified registry
 - By default, Dockerhub (docker.io) is the registry URL.

## Overview of Code

The [main.nf](main.nf) file contains two processes, both of which run in the biocontainers FASTQC docker container (v0.11.9). One process, TASK_FULLURL uses a docker container specified with a full URL, `quay.io/biocontainers/fastqc:0.11.9--0`. The second, TASK_CUSTOMREGISTRY uses a container specified by name, `biocontainers/fastqc:0.11.9--0`.

The shell script of each process doesn't run FASTQC, it runs a simple bash script to extract the full URL of the Docker container and writes it to a file. These are gathered and written to `images.txt`.

## Default Operation

By default, `docker.io` is the URL for the container registry. In the workflow, we are trying to use the docker image `biocontainers/fastqc:0.11.9--0` however this does exist on Dockerhub. If we run the workflow we will get an error:

```
nextflow run .

Command error:
  Unable to find image 'biocontainers/fastqc:0.11.9--0' locally
  docker: Error response from daemon: manifest for biocontainers/fastqc:0.11.9--0 not found: manifest unknown: manifest unknown.
  See 'docker run --help'.
```

We could write a correctly specified Docker container on docker.io or we need to provide a default registry by setting `docker.registry`.

## Quay.io

If we use `-profile quay` we set the `docker.registry = quay.io` (see the [config](nextflow.config)). When we run with this profile we should get correct running:

```
nextflow run . -profile quay

N E X T F L O W  ~  version 22.10.7
Launching `./main.nf` [backstabbing_franklin] DSL2 - revision: 9864d8a662
[a7/9f498e] Submitted process > TASK_FULLURL (1.task)
[71/5e1ba0] Submitted process > TASK_CUSTOMREGISTRY (1.task.custom)
```

If we look in the images.txt file created:
```
TASK_CUSTOMREGISTRY,quay.io/biocontainers/fastqc:0.11.9--0
TASK_FULLURL,quay.io/biocontainers/fastqc:0.11.9--0
```

## AWS 

If we set the `-profile ecr` we now set `docker.registry` to the public AWS ECR, `public.ecr.aws`. When running the two processes, the process `TASK_FULLURL` should be unmodified, while the `TASK_CUSTOMREGISTRY` will resolve to using the public AWS ECR instead. 

```
nextflow run . -profile ecr

N E X T F L O W  ~  version 22.10.7
Launching `./main.nf` [marvelous_coulomb] DSL2 - revision: cd3d6d6db3
[9f/d22eba] Submitted process > TASK_FULLURL (1.task)
[8b/bda89b] Submitted process > TASK_CUSTOMREGISTRY (1.task.custom)
```

If we look inside images.txt, we can see that the CUSTOMREGISTRY has been resolved to using the AWS ECR container while the FULLURL has remained as quay.io:

```
TASK_CUSTOMREGISTRY,public.ecr.aws/biocontainers/fastqc:0.11.9--0
TASK_FULLURL,quay.io/biocontainers/fastqc:0.11.9--0
```