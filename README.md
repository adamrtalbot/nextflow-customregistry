# Nextflow Custom Container Registry

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
    N E X T F L O W  ~  version 23.04.0
    Launching `./main.nf` [chaotic_torricelli] DSL2 - revision: e19cf9f99d
    executor >  local (1)
    [d2/684d87] process > ECHO_CONTAINER [  0%] 0 of 1
    executor >  local (1)
    [d2/684d87] process > ECHO_CONTAINER [100%] 1 of 1, failed: 1 ✘
    ERROR ~ Error executing process > 'ECHO_CONTAINER'

    Caused by:
      Process `ECHO_CONTAINER` terminated with an error exit status (125)

    Command executed:

      echo docker.registry = null
      echo container uri   = $(grep 'docker run' .command.run | tr ' ' '\n' | grep fastqc:0.11.9--0)

    Command exit status:
      125

    Command output:
      (empty)

    Command error:
      Unable to find image 'fastqc:0.11.9--0' locally
      docker: Error response from daemon: pull access denied for fastqc, repository does not exist or may require 'docker login': denied: requested access to the resource is denied.
      See 'docker run --help'.

    Work dir:
      work/d2/684d8727f51e27c2c92a4fe10fedbf

    Tip: view the complete command output by changing to the process work dir and entering the command `cat .command.out`

    -- Check '.nextflow.log' file for details
    ```

- :white_check_mark: `nextflow run . --registry 'quay.io/biocontainers'`

    This tests correctly downloads the container when `docker.registry = 'quay.io/biocontainers'`.

    ```console
    N E X T F L O W  ~  version 23.04.0
    Launching `./main.nf` [kickass_miescher] DSL2 - revision: e19cf9f99d
    executor >  local (1)
    [65/e856af] process > ECHO_CONTAINER [100%] 1 of 1 ✔

    docker.registry = quay.io/biocontainers
    container uri = quay.io/biocontainers/fastqc:0.11.9--0
    ```

- :white_check_mark: `nextflow run . --registry 'public.ecr.aws/biocontainers'`

    This tests correctly downloads the container when `docker.registry = 'public.ecr.aws/biocontainers'`.

    ```console
    N E X T F L O W  ~  version 23.04.0
    Launching `./main.nf` [pensive_yonath] DSL2 - revision: e19cf9f99d
    [12/4391f1] Submitted process > ECHO_CONTAINER

    docker.registry = public.ecr.aws/biocontainers
    container uri = public.ecr.aws/biocontainers/fastqc:0.11.9--0
    ```

- :white_check_mark: `nextflow run . -c custom.config`

    This test uses the container definition defined in `custom.config` and overrides the path hard-coded in the pipeline as expected.

    ```console
    N E X T F L O W  ~  version 23.04.0
    Launching `./main.nf` [lonely_northcutt] DSL2 - revision: e19cf9f99d
    executor >  local (1)
    [bb/993332] process > ECHO_CONTAINER [100%] 1 of 1 ✔

    docker.registry = null
    container uri = biocontainers/fastqc:v0.11.9_cv8
    ```
