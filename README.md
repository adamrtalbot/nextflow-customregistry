# Using docker.registry in nf-core pipelines

This repo highlights how we can change the container definiton in nf-core modules to make them more flexible to other docker registries. At the moment, the full path to the container is hard-coded in the modules which means the only way to override this behaviour is by using a custom config file that overwrites the container definition for all processes in the pipeline.

However, we can specify a custom container registry using the Nextflow config `docker.registry` option (default: `docker.io`). This behaves in the same way as the default container registry when running `docker pull`, i.e.:

## Repo contents

- [main.nf](main.nf) contains a single process that prints the value of `docker.registry` and the resolved container path to stdout.
- [nextflow.config](nextflow.config) initialises the appropriate settings for `docker`.
- [custom.config](custom.config) contains a process selector to highlight how we can override the default container used by the pipeline via custom configuration.
- [run.sh](run.sh) contains a series of commands to show what happens when we use different permutations to change the default container used by the pipeline via different registries.

## Running the tests

If you clone this repo locally and `cd` into it, you should just need to execute `./run.sh` to run all of the different test permutations. 

The output from each of the commands in `run.sh` are listed below:

- :x: `nextflow run .`

    This test is expected to fail because `docker.registry = null` by default and the container won't be found.

    ```console
    N E X T F L O W  ~  version 22.10.7
    Launching `./main.nf` [clever_panini] DSL2 - revision: 587ccc8122
    [96/399f40] Submitted process > ECHO_CONTAINER
    Error executing process > 'ECHO_CONTAINER'

    Caused by:
      Process `ECHO_CONTAINER` terminated with an error exit status (125)

    Command executed:

      echo docker.registry = null
      echo container uri   = $(grep 'docker run' .command.run | tr ' ' '\n' | grep biocontainers/fastqc:0.11.9--0)

    Command exit status:
      125

    Command output:
      (empty)

    Command error:
      Unable to find image 'biocontainers/fastqc:0.11.9--0' locally
      docker: Error response from daemon: manifest for biocontainers/fastqc:0.11.9--0 not found: manifest unknown: manifest unknown.
      See 'docker run --help'.

    Work dir:
      work/96/399f403e65c7181c5c793d138f9792

    Tip: you can replicate the issue by changing to the process work dir and entering the command `bash .command.run`
    ```

- :white_check_mark: `nextflow run . --registry 'quay.io'`

    This tests correctly downloads the container when `docker.registry = 'quay.io'`.

    ```console
    N E X T F L O W  ~  version 22.10.7
    Launching `./main.nf` [curious_pasteur] DSL2 - revision: 587ccc8122
    [1e/a2af04] Submitted process > ECHO_CONTAINER

    docker.registry = quay.io
    container uri = quay.io/biocontainers/fastqc:0.11.9--0
    ```

- :white_check_mark: `nextflow run . --registry 'public.ecr.aws'`

    This tests correctly downloads the container when `docker.registry = 'public.ecr.aws'`.

    ```console
    N E X T F L O W  ~  version 22.10.7
    Launching `./main.nf` [sleepy_euclid] DSL2 - revision: 587ccc8122
    [44/241e55] Submitted process > ECHO_CONTAINER

    docker.registry = public.ecr.aws
    container uri = public.ecr.aws/biocontainers/fastqc:0.11.9--0
    ```

- :white_check_mark: `nextflow run . -c custom.config`

    This test uses the container definition defined in `custom.config` and overrides the path hard-coded in the pipeline as expected.

    ```console
    N E X T F L O W  ~  version 22.10.7
    Launching `./main.nf` [disturbed_gates] DSL2 - revision: 587ccc8122
    [fc/394cc1] Submitted process > ECHO_CONTAINER

    docker.registry = null
    container uri = biocontainers/fastqc:v0.11.9_cv8
    ```

## Implications for nf-core/modules

In order to benefit from this approach we would need to:
- Update all nf-core/modules to provide `<CONTAINER>:<TAG>` instead of `<REGISTRY>/<CONTAINER>:<TAG>` for any Docker containers specified in the process.
- Add `docker.registry = 'quay.io'` as default to the `nextflow.config` in the pipeline.
- Manually define any custom containers not coming from `quay.io` in the pipeline configuration e.g. `base.config`.
- Update nf-core/tools where required e.g. module template, linting etc
- These changes shouldn't have any impact on `nf-core download` because we will be leaving Singularity image paths unchanged in nf-core/modules.
