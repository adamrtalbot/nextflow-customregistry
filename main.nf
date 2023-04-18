process ECHO_CONTAINER {
    debug true
    
    // container "quay.io/biocontainers/fastqc:0.11.9--0" // Current nf-core container definition
    container "biocontainers/fastqc:0.11.9--0"

    """
    echo docker.registry = $params.registry
    echo container uri   = \$(grep 'docker run' .command.run | tr ' ' '\\n' | grep ${task.container})
    """
}

workflow {
    ECHO_CONTAINER()
}