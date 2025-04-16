#!/bin/bash

# set -e
# set -x

export_env_vars() {
    # echo "Env variables before: $(printenv | grep '^AZP_')"

    check_if_exported=$(printenv | grep '^AZP_')

    if [[ -z "$check_if_exported" ]]; then
        echo "+ + + + + Env variables don't exist, exporting new ones..."

        if [[ -f '.env' ]]; then
            echo "+ + + + + Found .env file, starting to parse it..."

            while IFS='=' read -r key value; do
                if [[ -z "$key" || "$key" == \#* ]]; then
                    continue
                fi

                value="${value%\"}"
                value="${value#\"}"
                
                echo "Exporting: $key=$value"
                export "$key=$value"
            done < .env
        else
                echo "+ + + + + .env file not found!"
        fi
    else
        echo "+ + + + + Env variables exists already, skipping exporting..."
    fi

    # echo "Env variables after: $(printenv | grep '^AZP_')"
}

docker_build_image() {
    if ! docker image inspect $AZP_DOCKER_IMAGE_NAME > /dev/null 2>&1; then
        echo "+ + + + + Building Docker image: $AZP_DOCKER_IMAGE_NAME"

        docker build --no-cache -t $AZP_DOCKER_IMAGE_NAME .
    else
        echo "+ + + + + Docker image already exists, skipping build..."
    fi
}

docker_create_container() {
    running_container_id=$(docker ps -a --filter "ancestor=$AZP_DOCKER_IMAGE_NAME" --format '{{.ID}}')

    if [[ -z "$running_container_id" ]]; then
        echo "+ + + + + Creating agent's container..."

        docker container create \
                    --restart always \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -e AZP_URL="$AZP_URL" \
                    -e AZP_TOKEN="$AZP_TOKEN" \
                    -e AZP_POOL="$AZP_POOL" \
                    -e AZP_AGENT_NAME="Docker Agent - Linux" \
                    --name "azp-agent-linux" \
                    $AZP_DOCKER_IMAGE_NAME
    else
        echo "+ + + + + Some container agent exists already, re-creating a new one..."
        docker stop $running_container_id
        docker container rm $running_container_id
        docker_create_container
    fi
}

docker_start_container() {
    echo "+ + + + + Starting the container..."
    docker start azp-agent-linux
}

export_env_vars
docker_build_image
docker_create_container
docker_start_container
