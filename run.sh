
nextflow run . -profile docker

nextflow run . -profile docker --registry 'quay.io/biocontainers'

nextflow run . -profile docker --registry 'public.ecr.aws/biocontainers'

nextflow run . -profile docker -c custom.config

nextflow run . -profile podman --registry quay.io/biocontainers
