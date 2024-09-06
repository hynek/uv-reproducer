docker-build *extra:
    docker build \
        {{ extra }} \
        --platform=linux/amd64 \
        --pull \
        --progress=plain \
        --tag {{ file_name(invocation_directory()) }}:local \
        .

dr: docker-build
    docker run \
        --platform=linux/amd64 \
        --entrypoint /usr/bin/bash  \
        --rm \
        -it \
        {{ file_name(invocation_directory()) }}:local
