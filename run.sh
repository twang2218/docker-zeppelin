#!/bin/sh

IMAGE_NAME=twang2218/zeppelin
IMAGE_TAG=test

ZEPPELIN_VERSION=2.2.0

VARIATION="base common all"

function generate_dockerfile() {
  local zeppelin_version=$1
  local interpreter=$2
  local file=$3

  local run_install_interpreter=""
  if [ -n "$interpreter" ]; then
    install_interpreter="\&\& ./bin/install-interpreter.sh $interpreter"
  fi

  mkdir -p `dirname $file`
  cat ./template/Dockerfile | sed \
    -e "s/#ZEPPELIN_VERSION#/$zeppelin_version/g" \
    -e "s@#INTERPRETER#@${install_interpreter}@g" \
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

  # base
  generate_dockerfile $ZEPPELIN_VERSION "--name $xsmall,$small" base/Dockerfile
  # common
  generate_dockerfile $ZEPPELIN_VERSION "--name $xsmall,$small,$medium" common/Dockerfile
  # all
  generate_dockerfile $ZEPPELIN_VERSION "--all" all/Dockerfile
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
    docker push ${IMAGE_NAME}:${tag}
  done
}

function main() {
  local command=$1
  shift
  case $command in
    generate) generate "$@" ;;
    build)    build "$@" ;;
    run)      run "$@" ;;
    release)  release "$@" ;;
    *)        echo "Usage: $0 (generate|build|run|release)" ;;
  esac
}

main "$@"