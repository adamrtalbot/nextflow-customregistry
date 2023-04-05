process TASK_FULLURL {
    tag "${n}.task"

    container "quay.io/biocontainers/fastqc:0.11.9--0"

    input:
        val n

    output:
        path  "image.txt", emit: image

    script:
        """
        CONTAINER=\$(grep 'docker run' .command.run | tr ' ' '\\n' | grep ${task.container})
        echo "${task.process},\$CONTAINER" > image.txt
        """
}

process TASK_CUSTOMREGISTRY {
    tag "${n}.task.custom"

    container "biocontainers/fastqc:0.11.9--0"

    input:
        val n

    output:
        path  "image.txt", emit: image

    script:
        """
        CONTAINER=\$(grep 'docker run' .command.run | tr ' ' '\\n' | grep ${task.container})
        echo "${task.process},\$CONTAINER" > image.txt
        """
}


workflow {

    inputs = Channel.of(1)
    TASK_CUSTOMREGISTRY(inputs)
    TASK_FULLURL(inputs)

    Channel.empty()
        .concat(TASK_CUSTOMREGISTRY.out.image)
        .concat(TASK_FULLURL.out.image)
        .collectFile(name: 'images.txt', storeDir: ".")

}