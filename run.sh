#!/bin/bash

DOCKER_USERNAME=${DOCKER_USERNAME:-twang2218}
IMAGE_NAME=${IMAGE_NAME:-${DOCKER_USERNAME}/zeppelin}
IMAGE_TAG=${IMAGE_TAG:-latest}

# DOCKER_TRIGGER_TOKEN should be set if you want to trigger the Docker Hub build

ZEPPELIN_VERSION=2.2.0

VARIATION="base common all"

function generate_dockerfile() {
  local zeppelin_version=$1
  local interpreter=$2
  local dependencies=$3
  local file=$4

  local run_install_interpreter=""
  if [ -n "$interpreter" ]; then
    install_interpreter="\&\& install-interpreter.sh $interpreter"
  fi

  mkdir -p `dirname $file`
  cat ./template/Dockerfile | sed \
    -e "s/#ZEPPELIN_VERSION#/$zeppelin_version/g" \
    -e "s@#INTERPRETER#@${install_interpreter}@g" \
    -e "s/#DEPENDENCIES#/${dependencies}/g" \
    > $file
}

function generate() {
  # Interpreters category by size
  ##  less than 1MB
  local xsmall="angular,python,shell"
  ##  less than 10MB
  local small="bigquery,file,jdbc,kylin,livy,md,postgresql"
  ##  less than 50MB
  local medium="alluxio,cassandra,elasticsearch,ignite,lens"

  # Dependencies
  local dep_python="python python-pip python-matplotlib python-matplotlib-data"
  local dep_r_base="r-base"
  local dep_r_all="$dep_r_base r-base-dev r-recommended r-cran-knitr r-cran-caret r-cran-data.table r-cran-glmnet"
  # base
  generate_dockerfile $ZEPPELIN_VERSION "--name $xsmall,$small" "$dep_python" base/Dockerfile
  # common
  generate_dockerfile $ZEPPELIN_VERSION "--name $xsmall,$small,$medium" "$dep_python $dep_r_base" common/Dockerfile
  # all
  generate_dockerfile $ZEPPELIN_VERSION "--all" "$dep_python $dep_r_all" all/Dockerfile
}

function build() {
  generate
  for t in $VARIATION; do
    docker build -t ${IMAGE_NAME}:${t} ${t}
  done
}

function run() {
  local version=${1:-$IMAGE_TAG}
  shift
  docker run -it --rm -p 8080:8080 ${IMAGE_NAME}:${version} "$@"
}

function release() {
  for tag in $VARIATION; do
    echo "Publish image '${IMAGE_NAME}:${tag}' to Docker Hub ..."
    docker push ${IMAGE_NAME}:${tag}
  done
}

function trigger_build() {
  local tag=$1
  if [ -n "$DOCKER_TRIGGER_TOKEN" ]; then
    curl --silent \
      --header "Content-Type: application/json" \
      --request POST \
      --data "{\"docker_tag\": \"$tag\"}" \
      https://registry.hub.docker.com/u/${IMAGE_NAME}/trigger/${DOCKER_TRIGGER_TOKEN}
    echo -e "\ndone."
  else
    echo -e "\nDOCKER_TRIGGER_TOKEN is empty"
  fi
}

function ci() {
  if [[ -n "${DOCKER_PASSWORD}" ]]; then
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
  else
    echo "Cannot login to Docker Hub (DOCKER_PASSWORD is empty)"
    return 1
  fi

  # We just trigger the `base` build to refresh the README on the Hub
  trigger_build base

  if [ "$1" == "--force" ]; then
    # build all no matter it's changed or not
    build
    release
  else
    for tag in $VARIATION; do
      if (git show --pretty="" --name-only | grep Dockerfile | grep -q $tag); then
        echo "$tag has been updated, rebuilding ${IMAGE_NAME}:$tag ..."
        docker build -t ${IMAGE_NAME}:${tag} ${tag}
        echo "Publish image '${IMAGE_NAME}:${tag}' to Docker Hub ..."
        docker push ${IMAGE_NAME}:${tag}
      else
        echo "Nothing changed in $tag."
      fi
    done
  fi

  # List all the images
  docker images
}

function main() {
  local command=$1
  shift
  case $command in
    generate) generate "$@" ;;
    build)    build "$@" ;;
    run)      run "$@" ;;
    release)  release "$@" ;;
    ci)       ci "$@" ;;
    *)        echo "Usage: $0 (generate|build|run|release)" ;;
  esac
}

main "$@"