# Using docker.registry in nf-core pipelines

This repo highlights how we can change the container definiton in nf-core modules to make them more flexible to other docker registries. At the moment, the full path to the container is hard-coded in the modules which means the only way to override this behaviour is by using a custom config file that overwrites the container definition for all processes in the pipeline.

However, we can specify a custom container registry using the Nextflow config `docker.registry` option (default: `docker.io`). This behaves in the same way as the default container registry when running `docker pull`, i.e.:

## Repo contents

- [main.nf](main.nf) contains a single process that prints the value of `docker.registry` and the resolved container path to stdout.
- [nextflow.config](nextflow.config) includes profiles for `docker` and `podman` which initialises the appropriate settings.
- [custom.config](custom.config) contains a process selector to highlight how we can override the default container used by the pipeline via custom configuration.
- [run.sh](run.sh) contains a series of commands to show what happens when we use different permutations to change the default container used by the pipeline via different registries.

## Running the tests

If you clone this repo locally and `cd` into it, you should just need to execute `./run.sh` to run all of the different test permutations.

The output from each of the commands in `run.sh` are listed below:

- :x: `nextflow run . -profile docker`

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

- :white_check_mark: `nextflow run . -profile docker --registry 'quay.io/biocontainers'`

  This tests correctly downloads the container when `docker.registry = 'quay.io/biocontainers'`.

  ```console
  N E X T F L O W  ~  version 23.04.0
  Launching `./main.nf` [kickass_miescher] DSL2 - revision: e19cf9f99d
  executor >  local (1)
  [65/e856af] process > ECHO_CONTAINER [100%] 1 of 1 ✔

  docker.registry = quay.io/biocontainers
  container uri = quay.io/biocontainers/fastqc:0.11.9--0
  ```

- :white_check_mark: `nextflow run . -profile docker --registry 'public.ecr.aws/biocontainers'`

  This tests correctly downloads the container when `docker.registry = 'public.ecr.aws/biocontainers'`.

  ```console
  N E X T F L O W  ~  version 23.04.0
  Launching `./main.nf` [pensive_yonath] DSL2 - revision: e19cf9f99d
  [12/4391f1] Submitted process > ECHO_CONTAINER

  docker.registry = public.ecr.aws/biocontainers
  container uri = public.ecr.aws/biocontainers/fastqc:0.11.9--0
  ```

- :white_check_mark: `nextflow run . -profile docker -c custom.config`

  This test uses the container definition defined in `custom.config` and overrides the path hard-coded in the pipeline as expected.

  ```console
  N E X T F L O W  ~  version 23.04.0
  Launching `./main.nf` [lonely_northcutt] DSL2 - revision: e19cf9f99d
  executor >  local (1)
  [bb/993332] process > ECHO_CONTAINER [100%] 1 of 1 ✔

  docker.registry = null
  container uri = biocontainers/fastqc:v0.11.9_cv8
  ```

## Podman

Podman requires a full URI to be supplied (by default). Therefore the registry needs to be supplied for full functionality (i.e. `docker.io` is not supplied as a default registry). We add an additional profile in [nextflow.config](nextflow.config) to activate Podman and set the `podman.registry` to `params.registry`.

We can now run the pipeline with the same settings and config as before:

- :white_check_mark: `nextflow run . -profile podman --registry quay.io/biocontainers`

  ```
  N E X T F L O W  ~  version 23.04.0
  Launching `./main.nf` [thirsty_bardeen] DSL2 - revision: e19cf9f99d
  Monitor the execution with Nextflow Tower using this URL: https://tower.nf/user/adamtalbot/watch/mj4aYqgZc8QaA
  [ff/ad42ac] Submitted process > ECHO_CONTAINER
  docker.registry = quay.io/biocontainers
  container uri =
  ```

## Implications for nf-core/modules

In order to benefit from this approach we would need to:

- Update all nf-core/modules to provide `<CONTAINER>:<TAG>` instead of `<REGISTRY>/<CONTAINER>:<TAG>` for any Docker containers specified in the process.
- Add `docker.registry = 'quay.io/biocontainers'` as default to the `nextflow.config` in the pipeline.
- Manually define any custom containers not coming from `quay.io/biocontainers` in the pipeline configuration i.e. `base.config`.
- Update nf-core/tools where required e.g. module template, linting etc
- These changes shouldn't have any impact on `nf-core download` because we will be leaving Singularity image paths unchanged in nf-core/modules.
